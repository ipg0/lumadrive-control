import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumadrive_control/controllers/matrix_editor_controller.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/repositories/matrix_editor_repository.dart';

import 'layout_fakes.dart' show layoutSlaveMac;
import 'matrix_editor_fakes.dart';

void main() {
  late MatrixEditorController editor;
  late FakeMatrixEditorRepository repository;
  late MemoryMatrixStore store;
  setUp(() async {
    repository = FakeMatrixEditorRepository();
    store = MemoryMatrixStore();
    editor = MatrixEditorController(
      repository: repository,
      store: store,
      pollInterval: Duration.zero,
    );
    await editor.initialize();
  });
  tearDown(() => editor.dispose());
  test('applying one animation sends it immediately without applying table or library drafts', () async {
    editor.config.entries.single.priority = 256;
    editor.saveEffect(
      MatrixEffect(
        name: 'Only a local draft',
        kind: MatrixEffect_Kind.BLINK,
        red: 255,
        alpha: 255,
      ),
    );
    editor.editing = true;
    final edited = editor.effect(1)!.deepCopy()
      ..red = 0
      ..green = 255;
    expect(await editor.applyEffect(edited), isTrue);
    expect(repository.applied, isNotNull);
    expect(repository.applied!.entries.single.priority, 5);
    expect(repository.applied!.effects.length, 1);
    expect(repository.applied!.effects.single.green, 255);
    expect(editor.config.entries.single.priority, 256);
    expect(editor.effect(2)!.name, 'Only a local draft');
    expect(editor.effect(1)!.green, 255);
    expect(editor.document!.revision, Int64(8));
    expect(editor.dirty, isTrue);
    expect(editor.editing, isTrue);
  });
  test('applying an animation keeps other saved fields and clears only its own dirty state', () async {
    final original = editor.config.deepCopy();
    expect(
      await editor.applyEffect(editor.effect(1)!.deepCopy()..blue = 255),
      isTrue,
    );
    final saved = MatrixConfig.fromBuffer(repository.document.config);
    expect(saved.entries, original.entries);
    expect(saved.sources, original.sources);
    expect(saved.layout, original.layout);
    expect(saved.effects.single.blue, 255);
    expect(editor.dirty, isFalse);
  });
  test(
    'failed animation persistence leaves the device and other drafts intact',
    () async {
      editor.config.entries.single.name = 'Unfinished table edit';
      repository.failApply = true;
      expect(
        await editor.applyEffect(editor.effect(1)!.deepCopy()..green = 255),
        isFalse,
      );
      expect(editor.error, contains('persist'));
      expect(
        MatrixConfig.fromBuffer(repository.document.config)
            .effects
            .single
            .green,
        0,
      );
      expect(editor.config.entries.single.name, 'Unfinished table edit');
      expect(editor.applying, isFalse);
      repository.failApply = false;
      expect(
        await editor.applyEffect(editor.effect(1)!.deepCopy()..green = 255),
        isTrue,
      );
      expect(editor.config.effects.length, 1);
    },
  );
  test('animation Apply respects the revision fence', () async {
    repository.document.revision = Int64(8);
    expect(
      await editor.applyEffect(editor.effect(1)!.deepCopy()..blue = 255),
      isFalse,
    );
    expect(editor.conflict, isTrue);
    expect(repository.applied, isNull);
  });
  test(
    'reading active state preserves the draft and blocks Apply while reading',
    () async {
      editor.saveEffect(editor.effect(1)!.deepCopy()..name = 'My draft');
      final response = Completer<MatrixDocument>();
      repository.readCurrent = () => response.future;
      final pending = editor.readCurrent();
      expect(editor.readingCurrent, isTrue);
      expect(editor.canApply, isFalse);
      response.complete(editorDocument()..revision = Int64(6));
      await pending;
      expect(editor.currentDocument!.revision, Int64(6));
      expect(editor.document!.revision, Int64(7));
      expect(editor.effect(1)!.name, 'My draft');
      expect(editor.dirty, isTrue);
      expect(editor.canApply, isTrue);
    },
  );
  test(
    'adds named parametric animations and saves without changing layout',
    () async {
      final original = editor.config.layout.single.deepCopy();
      editor.saveEffect(
        MatrixEffect(
          name: 'Pulse',
          kind: MatrixEffect_Kind.BREATHE,
          periodMs: 2000,
          blue: 255,
          alpha: 128,
        ),
      );
      expect(editor.config.effects.last.id, 2);
      expect(editor.canApply, isTrue);
      await editor.apply();
      expect(repository.applied!.expectedRevision, Int64(7));
      expect(repository.applied!.masterSession, Int64(10));
      expect(editor.config.layout.single, original);
      expect(editor.dirty, isFalse);
    },
  );
  test('shared triggers are copied when an entry changes', () {
    editor.config.entries.add(
      MatrixEntry(id: 2, effectId: 1, sourceId: 1, conditionId: 1),
    );
    final first = editor.config.entries.first.deepCopy();
    editor.saveEntry(
      first,
      MatrixSource(
        id: 1,
        kind: MatrixSource_Kind.GPIO_EDGE,
        nodeMac: layoutSlaveMac,
        gpio: 12,
        rising: true,
      ),
    );
    expect(
      editor.source(editor.config.entries.first.sourceId)!.nodeMac,
      layoutSlaveMac,
    );
    expect(
      editor.source(editor.config.entries.last.sourceId)!.kind,
      MatrixSource_Kind.DEFAULT_STATE,
    );
    expect(editor.validationError, isNull);
  });
  test('table order and stable entry IDs survive reordering', () {
    editor.saveEntry(
      MatrixEntry(effectId: 1, priority: 5),
      MatrixSource(kind: MatrixSource_Kind.DEFAULT_STATE),
    );
    final added = editor.config.entries.last.id;
    editor.moveEntry(1, -1);
    expect(editor.config.entries.first.id, added);
    expect(editor.config.entries.last.id, 1);
    editor.removeEntry(added);
    expect(editor.config.entries.single.id, 1);
  });
  test(
    'referenced animations cannot be deleted and keyframes survive other edits',
    () {
      final keyframes = MatrixEffect(
        id: 2,
        kind: MatrixEffect_Kind.KEYFRAMES,
        loop: true,
        keyframes: [
          MatrixKeyframe(trackId: 1, timeMs: 0, alpha: 255),
          MatrixKeyframe(trackId: 1, timeMs: 1000, position: 20, alpha: 255),
        ],
      );
      editor.config.effects.add(keyframes);
      editor.deleteEffect(1);
      expect(editor.effect(1), isNotNull);
      expect(editor.error, contains('used by the table'));
      editor.saveEffect(editor.effect(1)!.deepCopy()..name = 'Renamed');
      expect(editor.effect(2), keyframes);
    },
  );
  test('reserved GPIOs, invalid priority and period block Apply', () {
    editor.saveEntry(
      editor.config.entries.single.deepCopy()..priority = 256,
      MatrixSource(
        id: 1,
        kind: MatrixSource_Kind.GPIO_EDGE,
        nodeMac: layoutSlaveMac,
        gpio: 19,
      ),
    );
    expect(editor.validationError, contains('Priorities'));
    expect(editor.canApply, isFalse);
    editor.config.entries.single.priority = 1;
    expect(editor.validationError, contains('not provisioned'));
    editor.config.sources.single.gpio = 12;
    editor.config.effects.single.periodMs = 1;
    expect(editor.validationError, contains('2 ms'));
  });
  test('gradient palettes validate color count, channels and effect kind', () {
    final effect = editor.config.effects.single;
    effect.kind = MatrixEffect_Kind.FLOWING_GRADIENT;
    expect(editor.validationError, contains('2–8'));
    effect.gradientColors.add(MatrixColor(red: 255, alpha: 255));
    expect(editor.validationError, contains('2–8'));
    effect.gradientColors.add(MatrixColor(green: 255, alpha: 128));
    expect(editor.validationError, isNull);
    effect.gradientColors.addAll(
      List.generate(6, (_) => MatrixColor(blue: 255, alpha: 255)),
    );
    expect(editor.validationError, isNull);
    effect.gradientColors.add(MatrixColor());
    expect(editor.validationError, contains('up to 8'));
    effect.gradientColors.removeLast();
    effect.gradientColors.first.red = 256;
    expect(editor.validationError, contains('255'));
    effect.gradientColors.first.red = 255;
    effect.kind = MatrixEffect_Kind.STATIC_COLOR;
    expect(editor.validationError, contains('require a gradient or breathe'));
  });
  test('entry background opacity is saved without creating another entry', () {
    editor.config.modes.add(MatrixMode(id: 1, name: 'Night'));
    final effect = MatrixEffect(
      id: 2,
      name: 'Signal',
      kind: MatrixEffect_Kind.BLINK,
      red: 255,
      alpha: 255,
      durationMs: 1200,
    );
    expect(
      editor.saveEntry(
        MatrixEntry(
          effectId: 2,
          priority: 15,
          name: 'Signal',
          opaqueBackground: true,
        ),
        MatrixSource(kind: MatrixSource_Kind.ON_MODE_SWITCHED),
        newEffects: [effect],
        modeId: 1,
      ),
      isTrue,
    );
    expect(editor.config.entries, hasLength(2));
    expect(editor.config.entries.last.opaqueBackground, isTrue);
    expect(editor.config.effects, hasLength(2));
    expect(editor.config.conditions.last.modeId, 1);
    expect(editor.validationError, isNull);
    editor.config.sources.last.kind = MatrixSource_Kind.DEFAULT_STATE;
    expect(editor.validationError, contains('transparent background'));
  });
  test('saves mode negation and a combined condition', () {
    editor.config.modes.addAll([
      MatrixMode(id: 1, name: 'Day'),
      MatrixMode(id: 2, name: 'Night'),
    ]);
    final entry = editor.config.entries.single.deepCopy();
    final source = editor.config.sources.single.deepCopy();
    expect(
      editor.saveEntry(
        entry,
        source,
        modeId: 1,
        secondModeId: -2,
        conditionOperator: 1,
      ),
      isTrue,
    );
    final group = editor.config.conditions.firstWhere(
      (c) => c.id == editor.config.entries.single.conditionId,
    );
    expect(group.kind, MatrixCondition_Kind.AND);
    final left = editor.config.conditions.firstWhere(
      (c) => c.id == group.leftId,
    );
    final right = editor.config.conditions.firstWhere(
      (c) => c.id == group.rightId,
    );
    expect(left.modeId, 1);
    expect(right.modeId, 2);
    expect(right.inverted, isTrue);
    expect(editor.validationError, isNull);
    group.rightId = group.id;
    expect(editor.validationError, contains('cyclic'));
  });
  test('mode-only refresh preserves and rebases table drafts', () async {
    editor.config.entries.single.name = 'Local draft';
    final saved = MatrixConfig.fromBuffer(repository.document.config);
    saved.modes.add(MatrixMode(id: 1, name: 'Night'));
    saved.activeModeId = 1;
    repository.document.config = saved.writeToBuffer();
    repository.document.revision += Int64.ONE;
    await editor.refresh();
    expect(editor.config.entries.single.name, 'Local draft');
    expect(editor.config.activeModeId, 1);
    expect(editor.config.modes.single.name, 'Night');
    expect(editor.conflict, isFalse);
    expect(editor.dirty, isTrue);
  });
  test('oversized animation libraries cannot be applied', () {
    editor.config.effects
      ..clear()
      ..addAll(
        List.generate(
          32,
          (id) => MatrixEffect(
            id: id + 1,
            name: 'x' * 100,
            kind: MatrixEffect_Kind.KEYFRAMES,
            keyframes: List.generate(
              16,
              (frame) => MatrixKeyframe(
                trackId: 1,
                timeMs: frame * 1000,
                position: frame.toDouble(),
                width: 2,
                wrap: true,
                red: 255,
                green: 255,
                blue: 255,
                alpha: 255,
              ),
            ),
          ),
        ),
      );
    expect(editor.config.writeToBuffer().length, greaterThan(16384));
    expect(editor.validationError, contains('16 KiB'));
    expect(editor.canApply, isFalse);
  });
  test(
    'offline draft restoration retains animations and disables Apply',
    () async {
      editor.saveEffect(editor.effect(1)!.deepCopy()..name = 'Draft');
      await editor.flush();
      repository.disconnected = true;
      final restored = MatrixEditorController(
        repository: repository,
        store: store,
        pollInterval: Duration.zero,
      );
      addTearDown(restored.dispose);
      await restored.initialize();
      expect(restored.effect(1)!.name, 'Draft');
      expect(restored.canApply, isFalse);
      expect(restored.dirty, isTrue);
    },
  );
  test('layout-only changes rebase a draft while competing matrix edits cause a conflict', () async {
    editor.saveEffect(editor.effect(1)!.deepCopy()..name = 'My draft');
    final saved = MatrixConfig.fromBuffer(repository.document.config)
      ..layout.single.to = 30;
    repository.document
      ..config = saved.writeToBuffer()
      ..revision = Int64(8);
    await editor.refresh();
    expect(editor.conflict, isFalse);
    expect(editor.config.layout.single.to, 30);
    expect(editor.effect(1)!.name, 'My draft');
    saved.effects.single.name = 'Another phone';
    repository.document
      ..config = saved.writeToBuffer()
      ..revision = Int64(9);
    await editor.refresh();
    expect(editor.conflict, isTrue);
    expect(editor.canApply, isFalse);
    await editor.refresh(discardDraft: true);
    expect(editor.effect(1)!.name, 'Another phone');
    expect(editor.dirty, isFalse);
  });
  test(
    'failed persistence keeps draft and the running configuration',
    () async {
      editor.saveEffect(editor.effect(1)!.deepCopy()..name = 'Pending');
      repository.failApply = true;
      await editor.apply();
      expect(editor.error, contains('persist'));
      expect(editor.dirty, isTrue);
      expect(
        MatrixConfig.fromBuffer(repository.document.config).effects.single.name,
        'Base lighting',
      );
    },
  );
  test(
    'connection-bound reads and updates reject a replacement connection',
    () async {
      var available = true, uploads = 0;
      final read = Completer<MatrixDocument>();
      final bound = ConnectedMatrixEditorRepository(
        isAvailable: () => available,
        readDocument: () => read.future,
        readActiveDocument: () => read.future,
        readStatus: () async => MatrixStatus(),
        updateMatrix: (_) {
          uploads++;
          return const Stream.empty();
        },
      );
      final pending = bound.read();
      available = false;
      read.complete(editorDocument());
      await expectLater(pending, throwsStateError);
      await expectLater(bound.apply(MatrixUpdate()).toList(), throwsStateError);
      expect(uploads, 0);
    },
  );
}
