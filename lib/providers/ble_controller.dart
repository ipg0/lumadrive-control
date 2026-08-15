import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/data/database.dart';
import 'package:lumadrive_control/providers/database_provider.dart';
import 'package:permission_handler/permission_handler.dart';

sealed class BleState {
  const BleState();

  BluetoothDevice? get device => null;
  SavedDevice? get savedDevice => null;

  String? get deviceName => savedDevice?.advName ?? device?.advName;
}

class BleIdle extends BleState {
  const BleIdle();
}

class BleScanning extends BleState {
  final Set<BluetoothDevice> foundDevices;

  const BleScanning(this.foundDevices);
}

class BleConnecting extends BleState {
  final BluetoothDevice _device;
  final SavedDevice? _savedDevice;

  @override
  BluetoothDevice get device => _device;

  @override
  SavedDevice? get savedDevice => _savedDevice;

  const BleConnecting(this._device, {this._savedDevice});
}

class BleConnected extends BleState {
  final BluetoothDevice _device;
  final SavedDevice? _savedDevice;

  @override
  BluetoothDevice get device => _device;

  @override
  SavedDevice? get savedDevice => _savedDevice;

  const BleConnected(this._device, {this._savedDevice});
}

class BleError extends BleState {
  final String message;
  final String? details;

  const BleError(this.message, {this.details});
}

class BleController extends Notifier<BleState> {
  StreamSubscription<List<ScanResult>>? _scanSub;
  StreamSubscription<BluetoothAdapterState>? _adapterSub;
  StreamSubscription<BluetoothConnectionState>? _connectionSub;
  bool _isDisconnecting = false;

  final Guid _lumadrivePrimaryServiceUuid = Guid(
    '7160c543-73ce-b1ad-484b-c14232943214',
  );

  @override
  BleState build() {
    _adapterSub = FlutterBluePlus.adapterState.listen(_handleAdapterState);

    ref.onDispose(() {
      _scanSub?.cancel();
      _adapterSub?.cancel();
      _connectionSub?.cancel();
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

  void _handleAdapterState(BluetoothAdapterState adapterState) {
    if (adapterState == BluetoothAdapterState.on) return;

    switch (state) {
      case BleScanning():
        _scanSub?.cancel();
        FlutterBluePlus.stopScan();
        state = const BleError(
          "Bluetooth was turned off",
          details: "Please turn on Bluetooth in Settings",
        );

      case BleConnecting():
      case BleConnected():
        _connectionSub?.cancel();
        state = const BleError(
          'Bluetooth was turned off',
          details: 'Please turn on Bluetooth in Settings',
        );

      default:
        return;
    }
  }

  Future<void> connectToDevice(
    BluetoothDevice device, {
    SavedDevice? savedDevice,
  }) async {
    _scanSub?.cancel();
    await FlutterBluePlus.stopScan();

    state = BleConnecting(device, savedDevice: savedDevice);

    _connectionSub = device.connectionState.listen(_handleConnectionState);

    try {
      await device.connect(license: .nonprofit, timeout: 10.seconds);
    } catch (e) {
      state = BleError(
        'Failed to connect to device',
        details: 'Try restarting the controller and make sure it is in range and powered on',
      );
      debugPrint('Failed to connect to device: $e');
    }
  }

  Future<void> connectToSavedDevice(SavedDevice device) async {
    try {
      final bluetoothDevice = BluetoothDevice.fromId(device.remoteId);

      await connectToDevice(bluetoothDevice, savedDevice: device);
    } catch (e) {
      state = BleError(
        'Failed to connect to saved device',
        details: 'Check that the device is powered on and in range',
      );
      debugPrint('Failed to connect to saved device: $e');
      await deleteSavedDevice(device.remoteId);
    }
  }

  Future<void> deleteSavedDevice(String remoteId) async {
    try {
      if (state is BleConnected &&
          state.device?.remoteId.toString() == remoteId) {
        await disconnect();
      }

      await ref.read(databaseProvider).deleteDevice(remoteId);
    } catch (e) {
      debugPrint('Failed to delete saved device: $e');
    }
  }

  Future<void> disconnect() async {
    if (state is! BleConnected) {
      state = const BleIdle();
      return;
    }

    try {
      // for some reason, awaiting the cancel doesn't prevent the callback from firing
      _isDisconnecting = true;
      await _connectionSub?.cancel();
      await state.device!.disconnect();
      state = const BleIdle();
    } catch (e) {
      debugPrint('Failed to disconnect from device: $e');
    } finally {
      _isDisconnecting = false;
    }
  }

  void _handleConnectionState(BluetoothConnectionState connectionState) {
    // can't handle connection state if we're not in a state with a selected device
    debugPrint('Connection state changed: $connectionState');

    debugPrint('Current state: {$state.device}');

    if (state.device == null) return;

    if (_isDisconnecting &&
        connectionState == BluetoothConnectionState.disconnected) {
      return;
    }

    if (connectionState == BluetoothConnectionState.connected) {
      _deviceConnected();
    } else if (connectionState == BluetoothConnectionState.disconnected) {
      // don't display an error page when we just started connecting
      if (state is BleConnecting) return;

      state = const BleError(
        'Disconnected from device',
        details: 'The connection to the device was lost',
      );
    }
  }

  Future<void> _deviceConnected() async {
    if (state.device == null) {
      debugPrint('connected to device, but device is null');
      return;
    }

    state = BleConnected(state.device!, savedDevice: state.savedDevice);

    try {
      await ref
          .read(databaseProvider)
          .upsertDevice(
            SavedDevicesCompanion(
              remoteId: Value(state.device!.remoteId.toString()),
              advName: Value(state.deviceName!),
              lastConnected: Value(DateTime.now()),
            ),
          );
    } catch (e) {
      debugPrint('Failed to save device: $e');
    }
  }

  Future<void> startScan() async {
    try {
      final granted = await _requestPermissions();
      if (!granted) {
        state = const BleError(
          'Bluetooth permissions denied',
          details: 'Please grant Bluetooth scan and connect permissions to Lumadrive Control in Settings',
        );
        return;
      }

      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        if (Platform.isAndroid) {
          try {
            await FlutterBluePlus.turnOn();
          } catch (e) {
            state = const BleError(
              'Bluetooth is off',
              details: 'Please turn on Bluetooth in Settings',
            );
            return;
          }
          final nowOn = await FlutterBluePlus.adapterState
              .where((s) => s == BluetoothAdapterState.on)
              .first
              .timeout(10.seconds, onTimeout: () => BluetoothAdapterState.off);
          if (nowOn != BluetoothAdapterState.on) {
            state = const BleError(
              'Bluetooth is off',
              details: 'Please turn on Bluetooth in Settings',
            );
            return;
          }
        } else {
          state = const BleError(
            'Bluetooth is off',
            details: 'Please turn on Bluetooth in Settings',
          );
          return;
        }
      }

      state = BleScanning({});

      FlutterBluePlus.startScan();

      _scanSub = FlutterBluePlus.onScanResults.listen((results) {
        state = BleScanning(
          results
              .where(
                (result) => result.advertisementData.serviceUuids.any(
                  (serviceUuid) => serviceUuid == _lumadrivePrimaryServiceUuid,
                ),
              )
              .map((result) => result.device)
              .toSet(),
        );
      });
    } catch (e) {
      state = BleError(
        'Failed to start scanning',
        details: 'Check that Bluetooth is enabled and that the app has permission to scan for Bluetooth devices',
      );
      debugPrint('Failed to start scanning: $e');
    }
  }

  Future<void> reset() async {
    _scanSub?.cancel();
    _connectionSub?.cancel();
    FlutterBluePlus.stopScan();

    if (state.device != null) {
      try {
        await state.device!.disconnect();
      } catch (e) {
        // ignore
      }
    }

    state = const BleIdle();
  }
}

final bleControllerProvider = NotifierProvider<BleController, BleState>(
  BleController.new,
);
