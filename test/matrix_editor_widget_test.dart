import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumadrive_control/controllers/matrix_editor_controller.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/widgets/pages/matrix_editor_page.dart';
import 'package:lumadrive_control/widgets/matrix/simple_animation_preview.dart';
import 'package:lumadrive_control/widgets/matrix/keyframe_editor.dart';

import 'matrix_editor_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final font in {
      'Roboto': 'LAYOUT_TEST_FONT',
      'MaterialIcons': 'LAYOUT_TEST_ICONS',
    }.entries) {
      final path = Platform.environment[font.value];
      if (path == null) continue;
      final loader = FontLoader(font.key)
        ..addFont(File(path).readAsBytes().then(ByteData.sublistView));
      await loader.load();
    }
  });
  Future<MatrixEditorController> open(
    WidgetTester tester, {
    double width = 390,
    MatrixConfig? config,
  }) async {
    tester.view.physicalSize = Size(width, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = MatrixEditorController(
      repository: FakeMatrixEditorRepository()
        ..document = editorDocument(config),
      store: MemoryMatrixStore(),
      pollInterval: Duration.zero,
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
          ),
          home: RepaintBoundary(
            key: const ValueKey('matrix-capture'),
            child: MatrixEditorPage(controller: controller),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  testWidgets(
    'creates an animation inside an entry while keeping entry settings',
    (tester) async {
      final empty = editorFixture()
        ..effects.clear()
        ..entries.clear()
        ..sources.clear()
        ..conditions.clear();
      final editor = await open(tester, width: 320, config: empty);
      await tester.tap(find.byKey(const ValueKey('add-entry')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('entry-name')),
        'Brake warning',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('entry-priority')));
      await tester.enterText(
        find.byKey(const ValueKey('entry-priority')),
        '77',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      final create = find.byKey(const ValueKey('create-entry-animation'));
      await tester.ensureVisible(create);
      await tester.pumpAndSettle();
      await tester.tap(create);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('entry-name')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const ValueKey('animation-name')));
      await tester.enterText(
        find.byKey(const ValueKey('animation-name')),
        'Quick pulse',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('animation-kind')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('animation-kind')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Breathe').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      expect(find.text('Use animation'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      expect(editor.config.effects, isEmpty);
      final editAnimation = find.byKey(const ValueKey('edit-entry-animation'));
      await tester.ensureVisible(editAnimation);
      await tester.tap(editAnimation);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('animation-name')));
      await tester.enterText(
        find.byKey(const ValueKey('animation-name')),
        'Edited pulse',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      expect(editor.config.effects, isEmpty);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('entry-name')))
            .controller!
            .text,
        'Brake warning',
      );
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('entry-priority')))
            .controller!
            .text,
        '77',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('save-entry')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('save-entry')));
      await tester.pumpAndSettle();
      expect(editor.config.entries.single.name, 'Brake warning');
      expect(editor.config.entries.single.priority, 77);
      expect(
        editor.config.entries.single.effectId,
        editor.config.effects.single.id,
      );
      expect(editor.config.effects.single.name, 'Edited pulse');
      expect(editor.config.effects.single.kind, MatrixEffect_Kind.BREATHE);
      expect((editor.repository as FakeMatrixEditorRepository).applied, isNull);
      expect(editor.validationError, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('edits a selected library animation without losing entry edits', (
    tester,
  ) async {
    final editor = await open(tester);
    await tester.tap(find.byKey(const ValueKey('matrix-entry-1')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('entry-name')),
      'Entry draft',
    );
    final edit = find.byKey(const ValueKey('edit-entry-animation'));
    await tester.ensureVisible(edit);
    await tester.tap(edit);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('animation-name')));
    await tester.enterText(
      find.byKey(const ValueKey('animation-name')),
      'Updated animation',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-animation')));
    await tester.pumpAndSettle();
    expect(editor.config.effects.single.name, 'Updated animation');
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('entry-name')))
          .controller!
          .text,
      'Entry draft',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('save-entry')));
    await tester.tap(find.byKey(const ValueKey('save-entry')));
    await tester.pumpAndSettle();
    expect(editor.config.entries.single.name, 'Entry draft');
    expect(editor.config.entries.single.effectId, 1);
    expect((editor.repository as FakeMatrixEditorRepository).applied, isNull);
  });

  testWidgets('static color clears legacy modulation when saved', (
    tester,
  ) async {
    final config = editorFixture();
    config.effects.single.modulation = AnimationModulation(
      signalId: 123,
      minimum: 0,
      maximum: 1,
    );
    final editor = await open(tester, config: config);
    await tester.tap(find.text('Animations (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('matrix-animation-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('animation-modulated')), findsNothing);
    await tester.ensureVisible(find.byKey(const ValueKey('animation-kind')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('animation-kind')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Blink').last);
    await tester.pumpAndSettle();
    final modulation = find.byKey(const ValueKey('animation-modulated'));
    await tester.ensureVisible(modulation);
    await tester.pumpAndSettle();
    await tester.tap(modulation);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('animation-kind')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('animation-kind')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Static color').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('animation-modulated')), findsNothing);
    await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-animation')));
    await tester.pumpAndSettle();
    expect(editor.config.effects.single.hasModulation(), isFalse);
  });

  testWidgets('background refresh keeps matrix actions enabled', (
    tester,
  ) async {
    final editor = await open(tester);
    editor.saveEffect(editor.effect(1)!.deepCopy()..name = 'Draft');
    await tester.pump();
    final repository = editor.repository as FakeMatrixEditorRepository;
    final pendingRead = Completer<MatrixDocument>();
    repository.onRead = () => pendingRead.future;
    final refresh = editor.refresh();
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('apply-matrix')))
          .onPressed,
      isNotNull,
    );
    expect(
      tester
          .widget<TextButton>(find.byKey(const ValueKey('read-current-matrix')))
          .onPressed,
      isNotNull,
    );
    repository.onRead = null;
    pendingRead.complete(editorDocument());
    await refresh;
    await tester.pumpAndSettle();
  });

  testWidgets('cancelling an entry discards its unused inline animation', (
    tester,
  ) async {
    final editor = await open(tester);
    await tester.tap(find.byKey(const ValueKey('add-entry')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('create-entry-animation')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-animation')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(editor.config.effects.length, 1);
    expect(editor.config.entries.length, 1);
    expect(editor.dirty, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'primary presets apply through the picker and a failed Apply can be retried',
    (tester) async {
      final editor = await open(tester);
      final repository = editor.repository as FakeMatrixEditorRepository;
      await tester.tap(find.text('Animations (1)'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('matrix-animation-1')));
      await tester.pumpAndSettle();
      final picker = find.byKey(const ValueKey('pick-color-Primary color'));
      await tester.ensureVisible(picker);
      await tester.tap(picker);
      await tester.pumpAndSettle();
      for (final hex in ['FF0000', '0000FF', '00FF00']) {
        final swatch = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.label == 'Color #$hex',
        );
        await tester.ensureVisible(swatch);
        await tester.pumpAndSettle();
        await tester.tap(swatch);
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Use color'));
      await tester.pumpAndSettle();
      repository.failApply = true;
      await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Unable to persist matrix'), findsWidgets);
      expect(find.byKey(const ValueKey('animation-name')), findsOneWidget);
      expect(
        MatrixConfig.fromBuffer(repository.document.config)
            .effects
            .single
            .green,
        0,
      );
      repository.failApply = false;
      await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      expect(repository.applied!.effects.single.red, 0);
      expect(repository.applied!.effects.single.green, 255);
      expect(repository.applied!.effects.single.blue, 0);
      expect(editor.dirty, isFalse);
      expect(find.byKey(const ValueKey('animation-name')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('preview saves the edited animation and requests playback', (
    tester,
  ) async {
    final editor = await open(tester);
    final repository = editor.repository as FakeMatrixEditorRepository;
    await tester.tap(find.text('Animations (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('matrix-animation-1')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('animation-name')),
      'Previewed',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final button = find.byKey(const ValueKey('preview-on-lights'));
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(repository.previewed, 1);
    expect(
      MatrixConfig.fromBuffer(repository.document.config).effects.single.name,
      'Previewed',
    );
    expect(find.byKey(const ValueKey('animation-name')), findsOneWidget);
  });
  testWidgets('reads current MCU state without replacing a draft', (
    tester,
  ) async {
    final editor = await open(tester);
    editor.saveEffect(editor.effect(1)!.deepCopy()..name = 'My draft');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('read-current-matrix')));
    await tester.pumpAndSettle();
    expect(
      find.text('Read from MCU: 1 entries · 1 animations · 1 outputs'),
      findsOneWidget,
    );
    expect(editor.effect(1)!.name, 'My draft');
    expect(editor.dirty, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rainbow offers opacity and shared canvas geometry', (
    tester,
  ) async {
    final editor = await open(tester);
    editor.saveEffect(
      MatrixEffect(
        id: 2,
        name: 'Rainbow',
        kind: MatrixEffect_Kind.RAINBOW,
        alpha: 255,
        periodMs: 8000,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Animations (2)'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('matrix-animation-2')));
    await tester.pumpAndSettle();
    expect(find.text('Opacity'), findsOneWidget);
    expect(find.text('Primary color'), findsNothing);
    await tester.ensureVisible(
      find.byKey(const ValueKey('animation-wavelength')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('animation-wavelength')),
      '30',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
    await tester.tap(find.byKey(const ValueKey('save-animation')));
    await tester.pumpAndSettle();
    expect(editor.effect(2)!.wavelengthPixels, 30);
    expect(editor.effect(2)!.periodMs, 8000);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'creates a simple animation and applies it without changing the layout',
    (tester) async {
      final editor = await open(tester, width: 320);
      await tester.tap(find.text('Animations (1)'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('add-animation')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('animation-name')),
        'Warning blink',
      );
      await tester.tap(find.byKey(const ValueKey('animation-kind')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Blink').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('animation-period')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('animation-period')),
        '500',
      );
      await tester.enterText(
        find.byKey(const ValueKey('animation-duty')),
        '25',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
      await tester.tap(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      expect(editor.config.effects.last.name, 'Warning blink');
      expect(editor.config.effects.last.kind, MatrixEffect_Kind.BLINK);
      expect(editor.config.effects.last.alpha, 255);
      expect(editor.config.effects.last.periodMs, 500);
      expect(editor.config.effects.last.dutyPercent, 25);
      expect(
        (editor.repository as FakeMatrixEditorRepository).applied,
        isNotNull,
      );
      expect(editor.dirty, isFalse);
      expect(editor.config.layout.single.to, 60);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('edits a slave GPIO trigger and rejects invalid priority', (
    tester,
  ) async {
    final editor = await open(tester);
    await tester.tap(find.byKey(const ValueKey('matrix-entry-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('entry-trigger')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('GPIO edge').last);
    await tester.pumpAndSettle();
    final node = find.byWidgetPredicate(
      (w) => w is DropdownButtonFormField<String>,
    );
    await tester.ensureVisible(node);
    await tester.tap(node);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Node ·').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('entry-priority')));
    await tester.enterText(find.byKey(const ValueKey('entry-priority')), '256');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-entry')));
    await tester.tap(find.byKey(const ValueKey('save-entry')));
    await tester.pumpAndSettle();
    expect(find.text('Enter 0–255'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('entry-priority')), '10');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-entry')));
    await tester.tap(find.byKey(const ValueKey('save-entry')));
    await tester.pumpAndSettle();
    final trigger = editor.source(editor.config.entries.single.sourceId)!;
    expect(trigger.kind, MatrixSource_Kind.GPIO_EDGE);
    expect(trigger.nodeMac.first, 4);
    expect(trigger.gpio, 12);
    expect(editor.config.entries.single.priority, 10);
    expect(tester.takeException(), isNull);
  });
  testWidgets('saves and reopens a node GPIO high condition', (tester) async {
    final editor = await open(tester);
    await tester.tap(find.byKey(const ValueKey('matrix-entry-1')));
    await tester.pumpAndSettle();
    final picker = find.byKey(const ValueKey('entry-mode'));
    await tester.ensureVisible(picker);
    await tester.tap(picker);
    await tester.pumpAndSettle();
    await tester.tap(find.text('GPIO state').last);
    await tester.pumpAndSettle();
    final node = find.byWidgetPredicate(
      (w) => w.key.toString().contains('condition-node--1-'),
    );
    await tester.ensureVisible(node);
    await tester.pumpAndSettle();
    await tester.tap(node);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Node ·').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('High'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('High'));
    await tester.pumpAndSettle();
    final save = find.byKey(const ValueKey('save-entry'));
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();
    final condition = editor.config.conditions.firstWhere(
      (c) => c.id == editor.config.entries.single.conditionId,
    );
    expect(condition.kind, MatrixCondition_Kind.GPIO_STATE);
    expect(condition.nodeMac.first, 4);
    expect(condition.gpio, 12);
    expect(condition.high, isTrue);
    await tester.tap(find.byKey(const ValueKey('matrix-entry-1')));
    await tester.pumpAndSettle();
    expect(find.text('GPIO state'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
  });
  testWidgets('edits an AND condition with an inverted mode', (tester) async {
    final editor = await open(tester);
    editor.config.modes.addAll([
      MatrixMode(id: 1, name: 'Day'),
      MatrixMode(id: 2, name: 'Night'),
    ]);
    await tester.tap(find.byKey(const ValueKey('matrix-entry-1')));
    await tester.pumpAndSettle();
    final first = find.byKey(const ValueKey('entry-mode'));
    await tester.ensureVisible(first);
    await tester.tap(first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Combined').last);
    await tester.pumpAndSettle();
    final condition1 = find.byKey(const ValueKey('entry-condition-0-0'));
    await tester.ensureVisible(condition1);
    await tester.tap(condition1);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mode: Day').last);
    await tester.pumpAndSettle();
    final second = find.byKey(const ValueKey('entry-condition-1-0'));
    await tester.ensureVisible(second);
    await tester.tap(second);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Not in mode: Night').last);
    await tester.pumpAndSettle();
    final save = find.byKey(const ValueKey('save-entry'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    final group = editor.config.conditions.firstWhere(
      (c) => c.id == editor.config.entries.single.conditionId,
    );
    expect(group.kind, MatrixCondition_Kind.AND);
    expect(
      editor.config.conditions
          .firstWhere((c) => c.id == group.rightId)
          .inverted,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('selects never and edits a combined list', (tester) async {
    final editor = await open(tester);
    await tester.tap(find.byKey(const ValueKey('matrix-entry-1')));
    await tester.pumpAndSettle();
    final picker = find.byKey(const ValueKey('entry-mode'));
    await tester.ensureVisible(picker);
    await tester.tap(picker);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Never (disabled)').last);
    await tester.pumpAndSettle();
    final save = find.byKey(const ValueKey('save-entry'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(
      editor.config.conditions
          .firstWhere((c) => c.id == editor.config.entries.single.conditionId)
          .kind,
      MatrixCondition_Kind.NEVER,
    );

    await tester.tap(find.byKey(const ValueKey('matrix-entry-1')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(picker);
    await tester.tap(picker);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Combined').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Add condition'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add condition'));
    await tester.pumpAndSettle();
    expect(find.text('Condition 3'), findsOneWidget);
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    final root = editor.config.conditions.firstWhere(
      (c) => c.id == editor.config.entries.single.conditionId,
    );
    expect(root.kind, MatrixCondition_Kind.AND);
    expect(
      editor.config.conditions.firstWhere((c) => c.id == root.leftId).kind,
      MatrixCondition_Kind.AND,
    );
    await tester.tap(find.byKey(const ValueKey('matrix-entry-1')));
    await tester.pumpAndSettle();
    expect(find.text('Condition 3'), findsOneWidget);
  });
  testWidgets(
    'flowing gradient exposes geometry, colors and preview with no overflow',
    (tester) async {
      final editor = await open(tester);
      editor.saveEffect(
        MatrixEffect(
          id: 2,
          name: 'Cabin flow',
          kind: MatrixEffect_Kind.FLOWING_GRADIENT,
          red: 255,
          alpha: 255,
          secondaryColor: MatrixColor(blue: 255, alpha: 128),
          periodMs: 3000,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Animations (2)'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('matrix-animation-2')));
      await tester.pumpAndSettle();
      expect(find.text('Color 2'), findsOneWidget);
      await tester.ensureVisible(
        find.byKey(const ValueKey('animation-wavelength')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('animation-wavelength')),
        '20',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Reverse flow'));
      await tester.tap(find.text('Reverse flow'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
      await tester.tap(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      expect(editor.effect(2)!.reverse, isTrue);
      expect(editor.effect(2)!.wavelengthPixels, 20);
      expect(editor.effect(2)!.secondaryColor.alpha, 128);
      expect(tester.takeException(), isNull);
      final path = Platform.environment['MATRIX_SCREENSHOT'];
      if (path != null) {
        await tester.drag(find.byType(ListView).first, const Offset(0, 1600));
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('matrix-capture')),
          );
          final image = await boundary.toImage(),
              data = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(path).writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }
    },
  );
  testWidgets(
    'gradient palette can add, reorder, remove and save eight colors',
    (tester) async {
      final editor = await open(tester);
      editor.saveEffect(
        MatrixEffect(
          id: 2,
          name: 'Palette',
          kind: MatrixEffect_Kind.FLOWING_GRADIENT,
          red: 255,
          alpha: 255,
          secondaryColor: MatrixColor(blue: 255, alpha: 128),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Animations (2)'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('matrix-animation-2')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<IconButton>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is IconButton && widget.tooltip == 'Remove color 1',
              ),
            )
            .onPressed,
        isNull,
      );
      for (var i = 0; i < 6; i++) {
        await tester.ensureVisible(
          find.byKey(const ValueKey('add-gradient-color')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('add-gradient-color')));
        await tester.pumpAndSettle();
      }
      expect(
        tester
            .widget<TextButton>(
              find.byKey(const ValueKey('add-gradient-color')),
            )
            .onPressed,
        isNull,
      );
      await tester.ensureVisible(find.byTooltip('Move color 2 earlier'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Move color 2 earlier'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Remove color 3'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Remove color 3'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      final stops = editor.effect(2)!.gradientColors;
      expect(stops, hasLength(7));
      expect(stops[0].blue, 255);
      expect(stops[0].alpha, 128);
      expect(stops[1].red, 255);
      expect(stops[2].green, 255);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('on boot saves a trigger without GPIO settings', (tester) async {
    final editor = await open(tester);
    await tester.tap(find.byKey(const ValueKey('matrix-entry-1')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('entry-trigger')));
    await tester.tap(find.byKey(const ValueKey('entry-trigger')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('On boot').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-entry')));
    await tester.tap(find.byKey(const ValueKey('save-entry')));
    await tester.pumpAndSettle();
    final source = editor.source(editor.config.entries.single.sourceId)!;
    expect(source.kind, MatrixSource_Kind.ON_BOOT);
    expect(source.nodeMac, isEmpty);
    expect(editor.canApply, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets('new entry suggests names and allows an opaque background', (
    tester,
  ) async {
    final config = editorFixture()..modes.add(MatrixMode(id: 1, name: 'Night'));
    final editor = await open(tester, config: config);
    await tester.tap(find.byKey(const ValueKey('add-entry')));
    await tester.pumpAndSettle();
    final defaultTransparency = tester.widget<SwitchListTile>(
      find.byKey(const ValueKey('entry-transparency')),
    );
    expect(defaultTransparency.value, isTrue);
    expect(defaultTransparency.onChanged, isNull);
    expect(
      find.text('Default-state entries always have a transparent background.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('entry-priority')))
          .controller!
          .text,
      '15',
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('entry-name')))
          .controller!
          .text,
      contains('Default state'),
    );
    await tester.ensureVisible(find.byKey(const ValueKey('entry-trigger')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('entry-trigger')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('On mode switched').last);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const ValueKey('entry-transparency')),
          )
          .value,
      isTrue,
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('create-entry-animation')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('create-entry-animation')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('animation-name')))
          .controller!
          .text,
      'Static color',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('animation-kind')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('animation-kind')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Blink').last);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('animation-name')))
          .controller!
          .text,
      'Blink',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('animation-duration')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('animation-duration')),
      '1200',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-animation')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('entry-transparency')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('entry-transparency')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('entry-mode')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('entry-mode')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mode: Night').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-entry')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-entry')));
    await tester.pumpAndSettle();
    expect(editor.config.entries, hasLength(2));
    final foreground = editor.config.entries.last;
    expect(foreground.name, 'Blink · Mode switched');
    expect(foreground.priority, 15);
    expect(foreground.opaqueBackground, isTrue);
    expect(editor.effect(foreground.effectId)!.durationMs, 1200);
    expect(editor.config.conditions.last.modeId, 1);
  });
  testWidgets('suggested entry and inline animation names avoid duplicates', (
    tester,
  ) async {
    final config = editorFixture();
    config.effects[0].name = 'Static color';
    config.effects.add(
      MatrixEffect(
        id: 2,
        name: 'Blink',
        kind: MatrixEffect_Kind.BLINK,
        alpha: 255,
      ),
    );
    config.entries[0].name = 'Static color · Default state';
    final editor = await open(tester, config: config);
    await tester.tap(find.byKey(const ValueKey('add-entry')));
    await tester.pumpAndSettle();
    final entryName = find.byKey(const ValueKey('entry-name'));
    expect(
      tester.widget<TextFormField>(entryName).controller!.text,
      'Static color · Default state 2',
    );
    await tester.tap(entryName);
    await tester.enterText(entryName, 'Custom entry');
    await tester.pumpAndSettle();
    final focus = FocusManager.instance.primaryFocus;
    expect(focus, isNotNull);
    editor.connectionChanged(false);
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextFormField>(entryName).controller!.text,
      'Custom entry',
    );
    expect(focus!.hasFocus, isTrue);
    await tester.ensureVisible(
      find.byKey(const ValueKey('create-entry-animation')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('create-entry-animation')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('animation-name')))
          .controller!
          .text,
      'Static color 2',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('animation-kind')));
    await tester.tap(find.byKey(const ValueKey('animation-kind')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Blink').last);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('animation-name')))
          .controller!
          .text,
      'Blink 2',
    );
    expect(
      tester.widget<TextFormField>(entryName).controller!.text,
      'Custom entry',
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('breathe color cycle can stop at the last color', (tester) async {
    final config = editorFixture();
    config.effects.single
      ..kind = MatrixEffect_Kind.BREATHE
      ..gradientColors.addAll([
        MatrixColor(red: 255, alpha: 255),
        MatrixColor(green: 255, alpha: 255),
        MatrixColor(blue: 255, alpha: 255),
      ]);
    final editor = await open(tester, config: config);
    await tester.tap(find.text('Animations (1)'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('matrix-animation-1')));
    await tester.pumpAndSettle();
    final toggle = find.byKey(const ValueKey('breathe-stop-at-last'));
    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-animation')));
    await tester.pumpAndSettle();
    expect(editor.config.effects.single.breatheStopAtLast, isTrue);
  });

  for (final kind in [MatrixEffect_Kind.BLINK, MatrixEffect_Kind.FILL]) {
    testWidgets('modulated $kind hides animation timing and saves one span', (
      tester,
    ) async {
      final config = editorFixture();
      config.signals.add(
        SignalGenerator(
          id: 1,
          name: 'Wave',
          kind: SignalGenerator_Kind.SINE,
          periodMs: 1000,
          amplitude: 1,
        ),
      );
      config.effects.single
        ..kind = kind
        ..durationMs = 2400
        ..periodMs = 1600
        ..loop = true
        ..modulation = AnimationModulation(signalId: 1, minimum: 0, maximum: 1);
      final editor = await open(tester, config: config);
      await tester.tap(find.text('Animations (1)'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('matrix-animation-1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('animation-duration')), findsNothing);
      expect(find.byKey(const ValueKey('animation-period')), findsNothing);
      expect(find.byKey(const ValueKey('fill-once')), findsNothing);
      final toggle = find.byKey(const ValueKey('animation-modulated'));
      await tester.ensureVisible(toggle);
      await tester.pumpAndSettle();
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('animation-duration')), findsOneWidget);
      expect(find.byKey(const ValueKey('animation-period')), findsOneWidget);
      await tester.ensureVisible(toggle);
      await tester.pumpAndSettle();
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      final effect = editor.config.effects.single;
      expect(effect.hasModulation(), isTrue);
      expect(effect.loop, isFalse);
      expect(effect.periodMs, 0);
      expect(effect.durationMs, kind == MatrixEffect_Kind.FILL ? 1000 : 0);
    });
  }

  testWidgets('one-shot fill derives pass time from duration', (tester) async {
    final editor = await open(tester);
    await tester.tap(find.byKey(const ValueKey('matrix-entry-1')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('create-entry-animation')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('create-entry-animation')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('animation-kind')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('animation-kind')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fill').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('fill-once')), findsOneWidget);
    expect(find.byKey(const ValueKey('animation-period')), findsNothing);
    await tester.ensureVisible(find.byKey(const ValueKey('fill-origin')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('fill-origin')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Center · outward').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('animation-duration')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('animation-duration')),
      '2400',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-animation')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-entry')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-entry')));
    await tester.pumpAndSettle();
    final fill = editor.config.effects.singleWhere(
      (e) => e.kind == MatrixEffect_Kind.FILL,
    );
    expect(fill.loop, isFalse);
    expect(fill.durationMs, 2400);
    expect(fill.periodMs, 2400);
    expect(fill.fillFromCenter, isTrue);
    expect(fill.reverse, isFalse);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'existing keyframes open for editing from the animation library',
    (tester) async {
      final config = editorFixture();
      config.effects[0]
        ..kind = MatrixEffect_Kind.KEYFRAMES
        ..keyframes.addAll(defaultKeyframes(60));
      await open(tester, config: config);
      await tester.tap(find.text('Animations (1)'));
      await tester.pumpAndSettle();
      final item = find.byKey(const ValueKey('matrix-animation-1'));
      await tester.ensureVisible(item);
      await tester.pumpAndSettle();
      await tester.tap(item);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('keyframe-canvas')), findsOneWidget);
      expect(
        find.text(
          'Keyframe data is preserved and can be assigned to table entries. Keyframe editing is not available here.',
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Back closes an unfinished form and disconnect preserves a completed draft',
    (tester) async {
      final editor = await open(tester);
      editor.saveEffect(editor.effect(1)!.deepCopy()..name = 'Draft');
      await tester.tap(find.byKey(const ValueKey('matrix-entry-1')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('entry-name')),
        'Not saved',
      );
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(editor.config.entries.single.name, 'Ambient');
      editor.connectionChanged(false);
      await tester.pumpAndSettle();
      expect(editor.canApply, isFalse);
      expect(editor.dirty, isTrue);
      expect(find.textContaining('Controller disconnected'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  test(
    'preview samples blink, breathe and gradient across the global canvas',
    () {
      final blink = MatrixEffect(
        kind: MatrixEffect_Kind.BLINK,
        red: 255,
        alpha: 255,
        dutyPercent: 25,
      );
      expect(sampleSimpleAnimation(blink, 0, 0, 60).a, 1);
      expect(sampleSimpleAnimation(blink, 0.5, 0, 60).a, 0);
      expect(sampleSimpleAnimation(blink, 1, 0, 60, null, true).a, 0);
      expect(sampleSimpleAnimation(blink, 1, 0, 60).a, 1);
      final breathe = blink.deepCopy()..kind = MatrixEffect_Kind.BREATHE;
      expect(sampleSimpleAnimation(breathe, 0, 0, 60).a, 0);
      expect(sampleSimpleAnimation(breathe, 0.5, 0, 60).a, 1);
      final stoppingBreathe = breathe.deepCopy()
        ..breatheStopAtLast = true
        ..gradientColors.addAll([
          MatrixColor(red: 255, alpha: 255),
          MatrixColor(green: 255, alpha: 255),
          MatrixColor(blue: 255, alpha: 255),
        ]);
      expect(
        sampleSimpleAnimation(stoppingBreathe, 0.5, 0, 60),
        const Color(0xff00ff00),
      );
      expect(
        sampleSimpleAnimation(stoppingBreathe, 1, 0, 60),
        const Color(0xff0000ff),
      );
      expect(
        sampleSimpleAnimation(stoppingBreathe, 2, 0, 60),
        const Color(0xff0000ff),
      );
      final flow = breathe.deepCopy()
        ..kind = MatrixEffect_Kind.FLOWING_GRADIENT
        ..secondaryColor = MatrixColor(blue: 255, alpha: 255);
      expect(sampleSimpleAnimation(flow, 0, 0, 60), const Color(0xffff0000));
      expect(sampleSimpleAnimation(flow, 0, 30, 60), const Color(0xff0000ff));
      expect(
        sampleSimpleAnimation(flow, 0.25, 15, 60),
        const Color(0xffff0000),
      );
      final rainbow = MatrixEffect(kind: MatrixEffect_Kind.RAINBOW, alpha: 255);
      final fill = MatrixEffect(
        kind: MatrixEffect_Kind.FILL,
        red: 255,
        alpha: 255,
        durationMs: 1000,
      );
      expect(sampleSimpleAnimation(fill, 0.5, 29, 60), const Color(0xffff0000));
      expect(sampleSimpleAnimation(fill, 0.5, 30, 60), Colors.transparent);
      expect(sampleSimpleAnimation(fill, 1, 59, 60), const Color(0xffff0000));
      fill.reverse = true;
      expect(sampleSimpleAnimation(fill, 0.5, 30, 60), const Color(0xffff0000));
      expect(sampleSimpleAnimation(fill, 0.5, 29, 60), Colors.transparent);
      fill.fillFromCenter = true;
      expect(
        sampleSimpleAnimation(fill, 0.1, 9, 60, 10),
        const Color(0xffff0000),
      );
      expect(
        sampleSimpleAnimation(fill, 0.1, 10, 60, 10),
        const Color(0xffff0000),
      );
      expect(sampleSimpleAnimation(fill, 0.1, 20, 60, 10), Colors.transparent);
      fill.fillFromCenter = true;
      expect(
        sampleSimpleAnimation(fill, 0.01, 29, 60),
        const Color(0xffff0000),
      );
      expect(
        sampleSimpleAnimation(fill, 0.01, 30, 60),
        const Color(0xffff0000),
      );
      expect(sampleSimpleAnimation(fill, 0.01, 28, 60), Colors.transparent);
      expect(sampleSimpleAnimation(fill, 0.25, 2, 5), const Color(0xffff0000));
      expect(sampleSimpleAnimation(fill, 0.25, 1, 5), Colors.transparent);
      expect(sampleSimpleAnimation(fill, 1, 0, 5), const Color(0xffff0000));
      flow.gradientColors.addAll([
        MatrixColor(red: 255, alpha: 255),
        MatrixColor(green: 255, alpha: 128),
        MatrixColor(blue: 255, alpha: 0),
        MatrixColor(red: 255, green: 255, blue: 255, alpha: 255),
      ]);
      expect(sampleSimpleAnimation(flow, 0, 15, 60), const Color(0x8000ff00));
      expect(sampleSimpleAnimation(flow, 0, 30, 60), const Color(0x000000ff));
      expect(
        sampleSimpleAnimation(flow, 0.125, 0, 60),
        const Color(0xffff8080),
      );
      expect(
        sampleSimpleAnimation(flow, 0.125, 15, 60),
        const Color(0xc0808000),
      );
      expect(sampleSimpleAnimation(rainbow, 0, 0, 60), const Color(0xffff0000));
      expect(
        sampleSimpleAnimation(rainbow, 0, 30, 60),
        const Color(0xff00ffff),
      );
      expect(
        sampleSimpleAnimation(rainbow, 0.25, 15, 60),
        const Color(0xffff0000),
      );
    },
  );
}
