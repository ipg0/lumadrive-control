import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:permission_handler/permission_handler.dart';

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
    FlutterBluePlus.startScan(
      withServices: [Guid(lumadriveServiceUuid)],
      timeout: 60.seconds,
    );
  }

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

  Stream<MeshInteropState> subscribeToMeshStatus(BleService service) {
    try {
      final meshStatusCharacteristic = _getCharacteristic(
        service,
        meshStatusCharacteristicUuid,
      );

      meshStatusCharacteristic.setNotifyValue(true);
      return meshStatusCharacteristic.lastValueStream.map(
        (bytes) => MeshInteropState.fromBuffer(bytes),
      );
    } catch (e) {
      debugPrint('Failed to subscribe to mesh status: $e');
      throw Exception('Failed to subscribe to mesh status');
    }
  }
}

final bleRepositoryProvider = Provider<BleRepository>((ref) {
  return BleRepository();
});
