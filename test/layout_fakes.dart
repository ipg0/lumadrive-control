import 'package:fixnum/fixnum.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/repositories/layout_repository.dart';
import 'package:lumadrive_control/repositories/matrix_client.dart';

const layoutMasterMac = [2, 1, 2, 3, 4, 5];
const layoutSlaveMac = [4, 1, 2, 3, 4, 5];
LayoutSnapshot layoutFixture({bool placed = false}) => LayoutSnapshot(
  masterSession: Int64(10),
  revision: Int64(7),
  masterMac: layoutMasterMac,
  layout: placed
      ? [
          MatrixLayout(
            nodeMac: layoutMasterMac,
            driver: MatrixDriver.WS2812,
            from: 0,
            to: 60,
            name: 'Left footwell',
          ),
        ]
      : [],
  outputs: [
    LayoutOutput(
      nodeMac: layoutMasterMac,
      driver: MatrixDriver.WS2812,
      driverKind: MatrixDriverKind.LED_STRIP,
      pixelCount: 60,
      known: true,
      ready: true,
      online: true,
    ),
    LayoutOutput(
      nodeMac: layoutSlaveMac,
      driver: MatrixDriver.HC595,
      // A second strip in slot 2 exercises ID/type independence and reversal.
      driverKind: MatrixDriverKind.LED_STRIP,
      pixelCount: 2,
      known: true,
      ready: true,
      online: true,
    ),
  ],
);

class MemoryLayoutStore implements LayoutDraftStore {
  SavedLayoutDraft? value;
  @override
  Future<SavedLayoutDraft?> read() async => value;
  @override
  Future<void> save(SavedLayoutDraft draft) async {
    value = draft;
  }
}

class FakeLayoutRepository implements LayoutRepository {
  LayoutSnapshot snapshot;
  bool disconnected = false;
  LayoutUpdate? applied;
  int? identifiedIndex;
  int? identifiedLength;
  bool? identifiedReversed;
  MatrixStatus? deployment;
  Future<void>? readDelay;
  FakeLayoutRepository({LayoutSnapshot? snapshot})
    : snapshot = snapshot ?? layoutFixture();
  @override
  Future<LayoutReadResult> read() async {
    await readDelay;
    if (disconnected) throw StateError('Disconnected');
    return LayoutReadResult(
      LayoutSnapshot.fromBuffer(snapshot.writeToBuffer())..freeze(),
      123,
    );
  }

  @override
  Future<MatrixStatus> readStatus() async {
    if (disconnected) throw StateError('Disconnected');
    return deployment ??
        MatrixStatus(
          masterSession: snapshot.masterSession,
          revision: snapshot.revision,
          nodes: snapshot.outputs.map(
            (output) => MatrixNodeStatus(
              nodeMac: output.nodeMac,
              state: output.online
                  ? MatrixNodeStatus_State.READY
                  : MatrixNodeStatus_State.UNAVAILABLE,
            ),
          ),
        );
  }

  @override
  Future<void> identify(
    int token,
    int index, {
    int pixelCount = 0,
    bool reversed = false,
  }) async {
    identifiedIndex = index;
    identifiedLength = pixelCount;
    identifiedReversed = reversed;
  }

  @override
  Stream<MatrixUploadProgress> apply(LayoutUpdate update) async* {
    if (disconnected) throw StateError('Disconnected');
    if (update.expectedRevision != snapshot.revision ||
        update.masterSession != snapshot.masterSession) {
      throw MatrixUploadException(
        'Configuration changed on controller; reload before applying',
      );
    }
    applied = update;
    yield MatrixUploadProgress(
      0,
      100,
      MatrixStatus(stage: MatrixStatus_Stage.RECEIVING),
    );
    snapshot.layout
      ..clear()
      ..addAll(update.layout);
    snapshot.revision += Int64.ONE;
    yield MatrixUploadProgress(
      100,
      100,
      MatrixStatus(
        stage: MatrixStatus_Stage.ACTIVE,
        masterSession: snapshot.masterSession,
        revision: snapshot.revision,
        nodes: [
          MatrixNodeStatus(
            nodeMac: layoutMasterMac,
            state: MatrixNodeStatus_State.READY,
          ),
        ],
      ),
    );
  }
}
