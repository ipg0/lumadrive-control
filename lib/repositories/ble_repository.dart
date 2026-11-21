import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lumadrive_control/repositories/matrix_client.dart';
import 'package:lumadrive_control/repositories/ota_client.dart';

class _BleOtaTransport implements OtaTransport {
  _BleOtaTransport(this.upload, this.status);
  final BluetoothCharacteristic upload, status;
  @override
  int get mtu => upload.device.mtuNow;
  @override
  Future<void> write(List<int> bytes) => upload.write(bytes, withoutResponse: false);
  @override
  Future<List<int>> readStatus() => status.read();
}

class _BleMatrixTransport implements MatrixTransport {
  final BluetoothCharacteristic upload;
  final BluetoothCharacteristic status;
  _BleMatrixTransport(this.upload, this.status);
  @override
  int get mtu => upload.device.mtuNow;
  @override
  Future<void> write(List<int> bytes) =>
      upload.write(bytes, withoutResponse: false);
  @override
  Future<List<int>> readStatus() => status.read();
  @override
  Stream<List<int>> get invalidations async* {
    await status.setNotifyValue(true);
    // Reads share this plugin stream with notifications. Only the one-byte
    // invalidation notifications should request another read.
    yield* status.onValueReceived.where(
      (bytes) => bytes.length == 1 && bytes[0] == 1,
    );
  }
}

class BleDevice {
  final String remoteId;
  final String advName;

  const BleDevice({required this.remoteId, required this.advName});

  @override
  bool operator ==(Object other) {
    return other is BleDevice && other.remoteId == remoteId;
  }

  @override
  int get hashCode => remoteId.hashCode;
}

class BleScanResult {
  final BleDevice device;

  const BleScanResult(this.device);
}

enum BleAdapterState { on, off }

enum BleConnectionState { connected, disconnected }

class BleService {
  final String uuid;
  final BluetoothService _service;

  const BleService._(this.uuid, this._service);
}

class BleRepository {
  OtaClient otaClient(BleService service) => OtaClient(_BleOtaTransport(
    _getCharacteristic(service, Guid('294b8b31-57d2-bf85-dc41-5c612c9d1539')),
    _getCharacteristic(service, Guid('294b8b32-57d2-bf85-dc41-5c612c9d1539')),
  ));
  MatrixClient matrixClient(BleService service) => MatrixClient(
    _BleMatrixTransport(
      _getCharacteristic(service, Guid('294b8b2e-57d2-bf85-dc41-5c612c9d1539')),
      _getCharacteristic(service, Guid('294b8b2f-57d2-bf85-dc41-5c612c9d1539')),
    ),
    readLayoutResponse: () => _getCharacteristic(
      service,
      Guid('294b8b30-57d2-bf85-dc41-5c612c9d1539'),
    ).read(),
  );
  final String lumadriveServiceUuid = '7160c543-73ce-b1ad-484b-c14232943214';

  final Guid meshStatusCharacteristicUuid = Guid(
    '294b8b2d-57d2-bf85-dc41-5c612c9d1539',
  );

  Stream<BleAdapterState> get adapterState {
    return FlutterBluePlus.adapterState.map((state) {
      return state == BluetoothAdapterState.on
          ? BleAdapterState.on
          : BleAdapterState.off;
    });
  }

  Stream<List<BleScanResult>> get onScanResults {
    return FlutterBluePlus.onScanResults.map(
      (results) => results
          .map(
            (result) => BleScanResult(
              BleDevice(
                remoteId: result.device.remoteId.str,
                advName: result.device.advName,
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Stream<BleConnectionState> connectionState(BleDevice device) {
    return BluetoothDevice.fromId(device.remoteId).connectionState.map((state) {
      return state == BluetoothConnectionState.connected
          ? BleConnectionState.connected
          : BleConnectionState.disconnected;
    });
  }

  BleDevice deviceFromId(String remoteId, {String? advName}) {
    return BleDevice(remoteId: remoteId, advName: advName ?? remoteId);
  }

  Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
    return statuses.values.every((status) => status.isGranted);
  }

  Future<void> stopScan() {
    return FlutterBluePlus.stopScan();
  }

  Future<void> startScan() async {
    await FlutterBluePlus.startScan(
      withServices: [Guid(lumadriveServiceUuid)],
      timeout: 60.seconds,
    );
  }

  Stream<bool> get scanning => FlutterBluePlus.isScanning;

  Future<void> turnOnBluetooth() async {
    if (!Platform.isAndroid) {
      throw UnsupportedError(
        'Bluetooth can only be turned on automatically on Android',
      );
    }

    await FlutterBluePlus.turnOn();
  }

  Future<BleAdapterState> waitForAdapterOn({
    Duration timeout = const Duration(seconds: 10),
  }) {
    return adapterState
        .where((state) => state == BleAdapterState.on)
        .first
        .timeout(timeout, onTimeout: () => BleAdapterState.off);
  }

  Future<void> connect(BleDevice device, {required Duration timeout}) {
    return BluetoothDevice.fromId(device.remoteId)
        .connect(license: .nonprofit, timeout: timeout);
  }

  Future<void> disconnect(BleDevice device) {
    return BluetoothDevice.fromId(device.remoteId).disconnect();
  }

  Future<List<BleService>> discoverServices(BleDevice device) async {
    final services = await BluetoothDevice.fromId(device.remoteId)
        .discoverServices();
    return services
        .map((service) => BleService._(service.uuid.toString(), service))
        .toList(growable: false);
  }

  BluetoothCharacteristic _getCharacteristic(
    BleService service,
    Guid characteristicUuid,
  ) {
    return service._service.characteristics.firstWhere(
      (characteristic) => characteristic.uuid == characteristicUuid,
      orElse: () => throw Exception(
        'Characteristic $characteristicUuid not found in service ${service.uuid}',
      ),
    );
  }

  Future<MeshInteropState> getDeviceMeshStatus(BleService service) async {
    try {
      final meshStatusCharacteristic = _getCharacteristic(
        service,
        meshStatusCharacteristicUuid,
      );

      final buffer = await meshStatusCharacteristic.read(timeout: 15);

      if (buffer.isEmpty) {
        throw Exception(
          'Mesh status payload is empty. Read path worked, but device returned no data.',
        );
      }

      return MeshInteropState.fromBuffer(buffer)..freeze();
    } catch (e) {
      debugPrint('Failed to read mesh status: $e');
      throw Exception('Failed to get mesh status');
    }
  }

  Stream<MeshInteropState> subscribeToMeshStatus(BleService service) async* {
    try {
      final meshStatusCharacteristic = _getCharacteristic(
        service,
        meshStatusCharacteristicUuid,
      );

      await meshStatusCharacteristic.setNotifyValue(true);
      yield* meshStatusCharacteristic.lastValueStream
          .where((bytes) => bytes.isNotEmpty)
          .map((bytes) => MeshInteropState.fromBuffer(bytes)..freeze());
    } catch (e) {
      debugPrint('Failed to subscribe to mesh status: $e');
      throw Exception('Failed to subscribe to mesh status');
    }
  }
}

final bleRepositoryProvider = Provider<BleRepository>((ref) {
  return BleRepository();
});
