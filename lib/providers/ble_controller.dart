import 'dart:async';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class BleState {
  const BleState();
}

class BleIdle extends BleState {
  const BleIdle();
}

class BleScanning extends BleState {
  const BleScanning();
}

class BleDeviceFound extends BleState {
  final BluetoothDevice device;

  const BleDeviceFound(this.device);
}

class BleConnected extends BleState {
  final BluetoothDevice device;

  const BleConnected(this.device);
}

class BleError extends BleState {
  final String message;

  const BleError(this.message);
}

class BleController extends Notifier<BleState> {
  StreamSubscription<List<ScanResult>>? _scanSub;
  final Guid _lumadrivePrimaryServiceUuid = Guid(
    '7160c543-73ce-b1ad-484b-c14232943214',
  );

  @override
  BleState build() {
    ref.onDispose(() {
      _scanSub?.cancel();
      FlutterBluePlus.stopScan();
    });

    return const BleIdle();
  }

  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
    return statuses.values.every((s) => s.isGranted);
  }

  Future<void> startScan() async {
    try {
      final granted = await _requestPermissions();
      if (!granted) {
        state = const BleError('Bluetooth permissions denied');
        return;
      }

      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        if (Platform.isAndroid) {
          await FlutterBluePlus.turnOn();
          final nowOn = await FlutterBluePlus.adapterState
              .where((s) => s == BluetoothAdapterState.on)
              .first
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () => BluetoothAdapterState.off,
              );
          if (nowOn != BluetoothAdapterState.on) {
            state = const BleError('Bluetooth is off');
            return;
          }
        } else {
          state = const BleError('Please turn on Bluetooth in Settings');
          return;
        }
      }

      state = const BleScanning();

      FlutterBluePlus.startScan();

      final scanGranted = await Permission.bluetoothScan.status;
      final connectGranted = await Permission.bluetoothConnect.status;

      _scanSub = FlutterBluePlus.onScanResults.listen((results) {
        for (var result in results) {
          // master device advertises the primary service UUID in the ADV, without discover
          if (result.advertisementData.serviceUuids.any(
            (serviceUuid) => serviceUuid == _lumadrivePrimaryServiceUuid,
          )) {
            state = BleDeviceFound(result.device);
          }
        }
      });
    } catch (e) {
      state = BleError(e.toString());
    }
  }
}

final bleControllerProvider = NotifierProvider<BleController, BleState>(
  BleController.new,
);
