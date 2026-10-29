import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/repositories/ble_repository.dart';
import 'package:lumadrive_control/repositories/database_repository.dart';
import 'package:lumadrive_control/repositories/matrix_client.dart';

const firstController = BleDevice(
  remoteId: 'first-controller',
  advName: 'First controller',
);
const secondController = BleDevice(
  remoteId: 'second-controller',
  advName: 'Second controller',
);

class TestConnectionController extends BleController {
  @override
  BleState build() => const BleIdle();
  void emit(BleState value) {
    state = value;
  }

  @override
  Future<void> reset() async {
    state = const BleIdle();
  }
}

class TestBleService extends Fake implements BleService {
  @override
  final String uuid;
  TestBleService(this.uuid);
}

class TestMatrixTransport implements MatrixTransport {
  @override
  int get mtu => 185;
  @override
  Stream<List<int>> get invalidations => const Stream.empty();
  @override
  Future<List<int>> readStatus() async => MatrixStatus().writeToBuffer();
  @override
  Future<void> write(List<int> bytes) async {}
}

class TestBleRepository extends BleRepository {
  final adapters = StreamController<BleAdapterState>.broadcast(sync: true);
  final results = StreamController<List<BleScanResult>>.broadcast(sync: true);
  final scanStates = StreamController<bool>.broadcast(sync: true);
  final connections = <String, StreamController<BleConnectionState>>{};
  final connectGates = <String, Completer<void>>{};
  final discoveryGates = <String, Completer<List<BleService>>>{};
  final meshReadGates = <BleService, Completer<MeshInteropState>>{};
  final meshStreams = <BleService, StreamController<MeshInteropState>>{};
  final connected = <String>[], disconnected = <String>[];
  Completer<bool>? permissionGate;
  bool permissions = true, rejectDiscovery = false, rejectScan = false;
  int scanStarts = 0;
  BleAdapterState adapter = BleAdapterState.on;

  @override
  Stream<BleAdapterState> get adapterState async* {
    yield adapter;
    yield* adapters.stream;
  }

  void setAdapter(BleAdapterState value) {
    adapter = value;
    adapters.add(value);
  }

  @override
  Future<bool> requestPermissions() async =>
      permissionGate == null ? permissions : await permissionGate!.future;
  @override
  Stream<List<BleScanResult>> get onScanResults => results.stream;
  @override
  Stream<bool> get scanning => scanStates.stream;
  @override
  Future<void> startScan() async {
    scanStarts++;
    if (rejectScan) throw StateError('Scan failed');
    scanStates.add(true);
  }

  @override
  Future<void> stopScan() async {}
  StreamController<BleConnectionState> connectionFor(BleDevice device) =>
      connections.putIfAbsent(
        device.remoteId,
        () => StreamController<BleConnectionState>.broadcast(sync: true),
      );
  @override
  Stream<BleConnectionState> connectionState(BleDevice device) async* {
    yield BleConnectionState.disconnected;
    yield* connectionFor(device).stream;
  }

  @override
  Future<void> connect(BleDevice device, {required Duration timeout}) async {
    connected.add(device.remoteId);
    await connectGates[device.remoteId]?.future;
    connectionFor(device).add(BleConnectionState.connected);
  }

  @override
  Future<void> disconnect(BleDevice device) async {
    disconnected.add(device.remoteId);
    connectionFor(device).add(BleConnectionState.disconnected);
  }

  @override
  Future<List<BleService>> discoverServices(BleDevice device) async {
    if (rejectDiscovery) throw StateError('Discovery failed');
    return discoveryGates[device.remoteId]?.future ??
        [TestBleService(lumadriveServiceUuid)];
  }

  @override
  MatrixClient matrixClient(BleService service) =>
      MatrixClient(TestMatrixTransport());
  @override
  Future<MeshInteropState> getDeviceMeshStatus(BleService service) async =>
      meshReadGates[service]?.future ?? MeshInteropState();
  @override
  Stream<MeshInteropState> subscribeToMeshStatus(BleService service) =>
      meshStreams
          .putIfAbsent(
            service,
            () => StreamController<MeshInteropState>.broadcast(sync: true),
          )
          .stream;
  Future<void> close() async {
    await adapters.close();
    await results.close();
    await scanStates.close();
    for (final stream in connections.values) {
      await stream.close();
    }
    for (final stream in meshStreams.values) {
      await stream.close();
    }
  }
}

class TestDatabaseRepository extends Fake implements DatabaseRepository {
  final saved = <String>[], deleted = <String>[];
  @override
  Future<void> upsertDevice({
    required String remoteId,
    required String advName,
    required DateTime lastConnected,
  }) async {
    saved.add(remoteId);
  }

  @override
  Future<void> deleteDevice(String remoteId) async {
    deleted.add(remoteId);
  }
}
