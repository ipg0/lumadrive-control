import 'package:fixnum/fixnum.dart';

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/repositories/layout_repository.dart';
import 'package:lumadrive_control/repositories/matrix_client.dart';
import 'package:lumadrive_control/controllers/layout_editor_controller.dart';

import 'layout_fakes.dart';

void main() {
  test('layout repository rejects stale reads and writes after its controller changes', () async {
    var available = true, uploads = 0;
    final read = Completer<LayoutReadResult>();
    final bound = ConnectedLayoutRepository(
      isAvailable: () => available,
      readLayout: () => read.future,
      getStatus: () async => MatrixStatus(),
      identifyOutput: (_, _, _, _) async {},
      uploadLayout: (_) {
        uploads++;
        return const Stream.empty();
      },
    );
    final pending = bound.read();
    available = false;
    read.complete(LayoutReadResult(layoutFixture(), 1));
    await expectLater(pending, throwsStateError);
    await expectLater(bound.apply(LayoutUpdate()).toList(), throwsStateError);
    expect(uploads, 0);
  });
  late FakeLayoutRepository repository;
  late MemoryLayoutStore store;
  late LayoutEditorController editor;
  setUp(() async {
    repository = FakeLayoutRepository();
    store = MemoryLayoutStore();
    editor = LayoutEditorController(
      repository: repository,
      store: store,
      pollInterval: Duration.zero,
    );
    await editor.initialize();
  });
  tearDown(() => editor.dispose());
  test(
    'center defaults to dash boundary and survives drafts and uploads',
    () async {
      editor.place(repository.snapshot.outputs[0]);
      editor.assignPosition(editor.selectedKey!, CarPosition.DASH_LEFT);
      editor.place(repository.snapshot.outputs[1]);
      editor.assignPosition(editor.selectedKey!, CarPosition.DASH_RIGHT);
      expect(editor.resolvedCenter, 60);
      editor.setCenter(0);
      expect(editor.dirty, isTrue);
      await editor.flush();
      expect(store.value!.centerIndex, 0);
      await editor.apply();
      expect(repository.applied!.hasCenterIndex(), isTrue);
      expect(repository.applied!.centerIndex, 0);
      expect(editor.centerIndex, 0);
      editor.setCenter(null);
      expect(editor.resolvedCenter, 60);
      await editor.apply();
      expect(repository.applied!.hasCenterIndex(), isFalse);
    },
  );
  test(
    'background reads keep Apply available and serialize a user save',
    () async {
      editor.place(repository.snapshot.outputs.first);
      final gate = Completer<void>();
      repository.readDelay = gate.future;
      final refresh = editor.refresh();
      expect(editor.refreshing, isTrue);
      expect(editor.canApply, isTrue);
      final save = editor.apply();
      expect(editor.applying, isTrue);
      expect(repository.applied, isNull);
      gate.complete();
      await refresh;
      await save;
      expect(repository.applied, isNotNull);
      expect(editor.dirty, isFalse);
      expect(editor.error, isNull);
    },
  );
  test('identify waits for a background read and previews unsaved length and direction', () async {
    repository.snapshot.outputs.first.maxPixelCount = 2048;
    await editor.refresh();
    editor.place(repository.snapshot.outputs.first);
    editor.resize(editor.selectedKey!, '120');
    editor.reverse(editor.selectedKey!);
    final gate = Completer<void>();
    repository.readDelay = gate.future;
    final refresh = editor.refresh();
    final identify = editor.identify(editor.selectedKey!);
    expect(editor.identifyingKey, isNotNull);
    expect(repository.identifiedIndex, isNull);
    gate.complete();
    await refresh;
    await identify;
    expect(repository.identifiedLength, 120);
    expect(repository.identifiedReversed, isTrue);
    expect(repository.applied, isNull);
    expect(editor.dirty, isTrue);
    expect(editor.error, isNull);
  });
  test(
    'car locations pack continuously from rear left around to rear right',
    () async {
      repository.snapshot.outputs.first.maxPixelCount = 2048;
      await editor.refresh();
      editor.place(repository.snapshot.outputs[0]);
      final left = editor.selectedKey!;
      editor.place(repository.snapshot.outputs[1]);
      final right = editor.selectedKey!;
      editor.assignPosition(right, CarPosition.REAR_RIGHT_DOOR);
      editor.assignPosition(left, CarPosition.REAR_LEFT_DOOR);
      expect(editor.layout.map((row) => row.from), [0, 60]);
      editor.reverse(right);
      editor.resize(left, '120', continuous: true);
      expect(editor.layout[0].to, 120);
      expect(editor.layout[1].from, 122);
      expect(editor.layout[1].to, 120);
      await editor.apply();
      expect(repository.applied!.layout.map((row) => row.carPosition), [
        CarPosition.REAR_LEFT_DOOR,
        CarPosition.REAR_RIGHT_DOOR,
      ]);
      expect(editor.validationError, isNull);
      editor.resize(left, '2049');
      expect(editor.canApply, isFalse);
    },
  );
  test(
    'two LEDs on one module retain independent positions and identities',
    () async {
      repository.snapshot.outputs
        ..clear()
        ..addAll([
          for (var source = 0; source < 2; source++)
            LayoutOutput(
              nodeMac: layoutMasterMac,
              driver: MatrixDriver.DRIVER_6,
              driverKind: MatrixDriverKind.RGB_LED_MODULE,
              sourceIndex: source,
              pixelCount: 1,
              known: true,
              ready: true,
              online: true,
            ),
        ]);
      await editor.refresh();
      editor.place(editor.snapshot!.outputs[0]);
      final first = editor.selectedKey!;
      editor.move(first, 10);
      editor.place(editor.snapshot!.outputs[1]);
      final second = editor.selectedKey!;
      editor.move(second, 70);
      expect(first, isNot(second));
      expect(editor.layout.map((row) => row.from), [10, 70]);
      expect(editor.layout.map((row) => row.to), [11, 71]);
      expect(editor.layout.map((row) => row.sourceIndex), [0, 1]);
      expect(editor.titleFor(editor.layout.last), contains('RGB LED 2'));
      await editor.identify(second);
      expect(repository.identifiedIndex, 1);
      await editor.apply();
      expect(repository.applied!.layout.map((row) => row.sourceIndex), [0, 1]);
      expect(editor.validationError, isNull);
    },
  );
  test('six driver slots per node allow 84 distinct layout sources', () async {
    repository.snapshot.outputs
      ..clear()
      ..addAll([
        for (var node = 0; node < 7; node++)
          for (var slot = 1; slot <= 6; slot++)
            for (var source = 0; source < 2; source++)
              LayoutOutput(
                nodeMac: [2 + node * 2, 1, 2, 3, 4, 5],
                driver: MatrixDriver.valueOf(slot),
                driverKind: MatrixDriverKind.RGB_LED_MODULE,
                sourceIndex: source,
                pixelCount: 1,
                known: true,
                ready: true,
                online: true,
              ),
      ]);
    await editor.refresh();
    for (final output in editor.snapshot!.outputs) {
      editor.place(output);
    }
    expect(editor.layout.length, 84);
    expect(editor.validationError, isNull);
    expect(editor.layout.map(placementKey).toSet().length, 84);
    editor.layout.add(editor.layout.first.deepCopy());
    expect(editor.validationError, contains('84'));
  });
  test(
    'placements use reported lengths, allow overlap and reverse the same area',
    () {
      editor.place(repository.snapshot.outputs[0]);
      editor.place(repository.snapshot.outputs[1]);
      final module = editor.selectedKey!;
      editor.move(module, 10);
      editor.reverse(module);
      expect(editor.selected!.from, 12);
      expect(editor.selected!.to, 10);
      expect(editor.layout.first.to, 60);
      expect(editor.validationError, isNull);
      editor.place(repository.snapshot.outputs[1]);
      expect(editor.layout.length, 2);
      editor.move(module, 59, snapDistance: 2);
      expect(editor.selected!.to, 60);
      expect(editor.selected!.from, 62);
    },
  );
  test('identification resolves a fresh inventory index', () async {
    editor.place(repository.snapshot.outputs[0]);
    final key = editor.selectedKey!;
    repository.snapshot.outputs.setAll(
      0,
      repository.snapshot.outputs.reversed.toList(),
    );
    await editor.identify(key);
    expect(repository.identifiedIndex, 1);
    expect(editor.notice, contains('green'));
  });
  test(
    'apply sends only the layout with expected revision and preserves names',
    () async {
      editor.place(repository.snapshot.outputs[0]);
      editor.rename(editor.selectedKey!, 'Front left');
      await editor.apply();
      expect(repository.applied!.expectedRevision, Int64(7));
      expect(repository.applied!.masterSession, Int64(10));
      expect(repository.applied!.layout.single.name, 'Front left');
      expect(editor.dirty, isFalse);
      expect(editor.notice, 'Layout saved to controller.');
    },
  );
  test(
    'disconnection preserves a durable draft and cached output lengths',
    () async {
      editor.place(repository.snapshot.outputs[0]);
      editor.rename(editor.selectedKey!, 'My strip');
      repository.disconnected = true;
      await editor.refresh();
      await editor.flush();
      expect(editor.connected, isFalse);
      expect(editor.dirty, isTrue);
      final restored = LayoutEditorController(
        repository: repository,
        store: store,
        pollInterval: Duration.zero,
      );
      addTearDown(restored.dispose);
      await restored.initialize();
      expect(restored.layout.single.name, 'My strip');
      repository.disconnected = false;
      repository.snapshot.outputs[0]
        ..online = false
        ..known = false
        ..pixelCount = 0;
      await restored.refresh();
      expect(restored.snapshot!.outputs[0].pixelCount, 60);
      expect(restored.snapshot!.outputs[0].online, isFalse);
      expect(restored.dirty, isTrue);
    },
  );
  test('new controller revision preserves the draft and requires an explicit reload', () async {
    editor.place(repository.snapshot.outputs[0]);
    repository.snapshot.revision = Int64(8);
    await editor.refresh();
    expect(editor.conflict, isTrue);
    expect(editor.layout.length, 1);
    expect(editor.canApply, isFalse);
    await editor.refresh(discardDraft: true);
    expect(editor.conflict, isFalse);
    expect(editor.layout, isEmpty);
  });
  test(
    'an accepted layout with a lost reply reconciles as saved on refresh',
    () async {
      editor.place(repository.snapshot.outputs[0]);
      repository.snapshot.layout.addAll(editor.layout);
      repository.snapshot.revision = Int64(8);
      await editor.refresh();
      expect(editor.dirty, isFalse);
      expect(editor.conflict, isFalse);
    },
  );
  test(
    'a reduced device limit requires review without moving other outputs',
    () async {
      editor.place(repository.snapshot.outputs[0]);
      repository.snapshot.outputs[0].maxPixelCount = 30;
      await editor.refresh();
      expect(editor.layout.single.to, 60);
      expect(editor.validationError, contains('30 LEDs'));
      editor.resize(editor.selectedKey!, '30');
      expect(editor.layout.single.to, 30);
      expect(editor.validationError, isNull);
    },
  );
  test('invalid position input blocks save while keeping a valid draft', () {
    editor.place(repository.snapshot.outputs[0]);
    editor.positionText(editor.selectedKey!, '99999');
    expect(editor.canApply, isFalse);
    editor.rename(editor.selectedKey!, 'Still editing');
    expect(editor.canApply, isFalse);
    editor.positionText(editor.selectedKey!, '12');
    expect(editor.selected!.from, 12);
    expect(editor.canApply, isTrue);
  });
  test('connection loss immediately disables Apply and marks cached outputs offline', () {
    editor.place(repository.snapshot.outputs[0]);
    expect(editor.canApply, isTrue);
    editor.connectionChanged(false);
    expect(editor.canApply, isFalse);
    expect(editor.snapshot!.outputs.every((output) => !output.online), isTrue);
    expect(editor.layout.single.to, 60);
    expect(editor.dirty, isTrue);
  });
  test('deployment readiness follows recovery and ignores unused nodes and stale revisions', () async {
    editor.place(repository.snapshot.outputs[1]);
    await editor.apply();
    repository.deployment = MatrixStatus(
      masterSession: repository.snapshot.masterSession,
      revision: repository.snapshot.revision,
      nodes: [
        MatrixNodeStatus(
          nodeMac: layoutMasterMac,
          state: MatrixNodeStatus_State.DEGRADED,
        ),
        MatrixNodeStatus(
          nodeMac: layoutSlaveMac,
          state: MatrixNodeStatus_State.UNAVAILABLE,
        ),
      ],
    );
    await editor.refresh();
    expect(editor.deploymentNotice, contains('1 node'));
    repository.deployment!.nodes[1].state = MatrixNodeStatus_State.READY;
    await editor.refresh();
    expect(editor.deploymentNotice, isNull);
    repository.deployment!.nodes[1].state = MatrixNodeStatus_State.DEGRADED;
    await editor.refresh();
    expect(editor.deploymentNotice, contains('degraded delivery'));
    repository.deployment!.revision = Int64(1);
    await editor.refresh();
    expect(editor.deploymentNotice, isNull);
  });
}
