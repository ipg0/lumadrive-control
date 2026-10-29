import 'package:fixnum/fixnum.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/repositories/matrix_client.dart';
import 'package:lumadrive_control/repositories/matrix_editor_repository.dart';

import 'layout_fakes.dart' show layoutMasterMac, layoutSlaveMac;

MatrixConfig editorFixture() => MatrixConfig(
  schemaVersion: 2,
  layout: [
    MatrixLayout(
      nodeMac: layoutMasterMac,
      driver: MatrixDriver.WS2812,
      from: 0,
      to: 60,
      name: 'Dashboard',
    ),
  ],
  effects: [
    MatrixEffect(
      id: 1,
      name: 'Base lighting',
      kind: MatrixEffect_Kind.STATIC_COLOR,
      red: 255,
      alpha: 255,
    ),
  ],
  sources: [MatrixSource(id: 1, kind: MatrixSource_Kind.DEFAULT_STATE)],
  conditions: [MatrixCondition(id: 1, kind: MatrixCondition_Kind.ALWAYS)],
  entries: [
    MatrixEntry(
      id: 1,
      name: 'Ambient',
      effectId: 1,
      sourceId: 1,
      conditionId: 1,
      priority: 5,
    ),
  ],
);
MatrixDocument editorDocument([MatrixConfig? config]) => MatrixDocument(
  config: (config ?? editorFixture()).writeToBuffer(),
  revision: Int64(7),
  activeRevision: Int64(7),
  persisted: true,
  masterSession: Int64(10),
  masterMac: layoutMasterMac,
  nodes: [
    MatrixInputNode(
      nodeMac: layoutMasterMac,
      known: true,
      online: true,
      gpios: [12, 13, 34],
    ),
    MatrixInputNode(
      nodeMac: layoutSlaveMac,
      known: true,
      online: true,
      gpios: [12, 14, 35],
    ),
  ],
);

class MemoryMatrixStore implements MatrixDraftStore {
  MatrixDraft? draft;
  @override
  Future<MatrixDraft?> read() async => draft;
  @override
  Future<void> save(MatrixDraft value) async {
    draft = value;
  }
}

class FakeMatrixEditorRepository implements MatrixEditorRepository {
  MatrixDocument document = editorDocument();
  Future<MatrixDocument> Function()? readCurrent;
  bool disconnected = false, failApply = false;
  MatrixUpdate? applied;
  @override
  Future<MatrixDocument> read() async {
    if (disconnected) throw StateError('Disconnected');
    return document.deepCopy()..freeze();
  }

  @override
  Future<MatrixDocument> current() => readCurrent?.call() ?? read();

  @override
  Future<MatrixStatus> status() async => MatrixStatus(
    revision: document.revision,
    masterSession: document.masterSession,
    stage: MatrixStatus_Stage.ACTIVE,
    nodes: [
      for (final node in document.nodes)
        MatrixNodeStatus(
          nodeMac: node.nodeMac,
          state: MatrixNodeStatus_State.READY,
        ),
    ],
  );
  @override
  Stream<MatrixUploadProgress> apply(MatrixUpdate update) async* {
    if (disconnected) throw StateError('Disconnected');
    if (failApply) throw MatrixUploadException('Unable to persist matrix');
    if (update.expectedRevision != document.revision ||
        update.masterSession != document.masterSession) {
      throw MatrixUploadException(
        'Configuration changed on controller; reload before applying',
      );
    }
    applied = update.deepCopy();
    yield MatrixUploadProgress(
      0,
      100,
      MatrixStatus(stage: MatrixStatus_Stage.RECEIVING),
    );
    final config = MatrixConfig.fromBuffer(document.config);
    config.effects
      ..clear()
      ..addAll(update.effects);
    config.sources
      ..clear()
      ..addAll(update.sources);
    config.conditions
      ..clear()
      ..addAll(update.conditions);
    config.entries
      ..clear()
      ..addAll(update.entries);
    document
      ..config = config.writeToBuffer()
      ..revision += Int64.ONE;
    yield MatrixUploadProgress(100, 100, await status());
  }
}
