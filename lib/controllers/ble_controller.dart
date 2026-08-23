import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/data/database.dart';
import 'package:lumadrive_control/repositories/ble_repository.dart';
import 'package:lumadrive_control/repositories/database_repository.dart';

sealed class BleState {
  const BleState();

  BleDevice? get device => null;
  SavedDevice? get savedDevice => null;
  BleService? get lumadriveService => null;

  String? get deviceName => savedDevice?.advName ?? device?.advName;
}

class BleIdle extends BleState {
  const BleIdle();
}

class BleScanning extends BleState {
  final Set<BleDevice> foundDevices;

  const BleScanning(this.foundDevices);
}

class BleConnecting extends BleState {
  final BleDevice _device;
  final SavedDevice? _savedDevice;

  @override
  BleDevice get device => _device;

  @override
  SavedDevice? get savedDevice => _savedDevice;

  const BleConnecting(this._device, {this._savedDevice});
}

class BleConnected extends BleState {
  final BleDevice _device;
  final SavedDevice? _savedDevice;
  final BleService? _lumadriveService;

  @override
  BleDevice get device => _device;

  @override
  SavedDevice? get savedDevice => _savedDevice;

  @override
  BleService? get lumadriveService => _lumadriveService;

  const BleConnected(this._device, {this._savedDevice, this._lumadriveService});
}

class BleError extends BleState {
  final String message;
  final String? details;

  const BleError(this.message, {this.details});
}

class BleController extends Notifier<BleState> {
  BleRepository get _repository => ref.read(bleRepositoryProvider);
  DatabaseRepository get _database => ref.read(databaseRepositoryProvider);

  StreamSubscription<List<BleScanResult>>? _scanSub;
  StreamSubscription<BleAdapterState>? _adapterSub;
  StreamSubscription<BleConnectionState>? _connectionSub;
  bool _isDisconnecting = false;

  @override
  BleState build() {
    _adapterSub = _repository.adapterState.listen(_handleAdapterState);

    ref.onDispose(() {
      _scanSub?.cancel();
      _adapterSub?.cancel();
      _connectionSub?.cancel();
      unawaited(_repository.stopScan());
    });

    return const BleIdle();
  }

  void _handleAdapterState(BleAdapterState adapterState) {
    if (adapterState == BleAdapterState.on) return;

    switch (state) {
      case BleScanning():
        _scanSub?.cancel();
        unawaited(_repository.stopScan());
        state = const BleError(
          'Bluetooth was turned off',
          details: 'Please turn on Bluetooth in Settings',
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

  Future<void> connectDevice(
    BleDevice device, {
    SavedDevice? savedDevice,
  }) async {
    _scanSub?.cancel();
    await _repository.stopScan();

    state = BleConnecting(device, savedDevice: savedDevice);

    _connectionSub = _repository
        .connectionState(device)
        .listen(_handleConnectionState);

    try {
      await _repository.connect(device, timeout: 10.seconds);
    } catch (e) {
      state = const BleError(
        'Failed to connect to device',
        details: 'Try restarting the controller and make sure it is in range and powered on',
      );
      debugPrint('Failed to connect to device: $e');
    }
  }

  Future<void> connectToSavedDevice(SavedDevice device) async {
    try {
      final knownDevice = _repository.deviceFromId(
        device.remoteId,
        advName: device.advName,
      );

      await connectDevice(knownDevice, savedDevice: device);
    } catch (e) {
      state = const BleError(
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

      await _database.deleteDevice(remoteId);
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
      _isDisconnecting = true;
      await _connectionSub?.cancel();
      await _repository.disconnect(state.device!);
      state = const BleIdle();
    } catch (e) {
      debugPrint('Failed to disconnect from device: $e');
    } finally {
      _isDisconnecting = false;
    }
  }

  void _handleConnectionState(BleConnectionState connectionState) {
    debugPrint('Connection state changed: $connectionState');
    debugPrint('Current state: $state');

    if (state.device == null) return;

    if (_isDisconnecting &&
        connectionState == BleConnectionState.disconnected) {
      debugPrint(
        'isDisconnecting is true and connectionState is disconnected, ignoring',
      );
      return;
    }

    if (connectionState == BleConnectionState.connected) {
      _deviceConnected();
    } else if (connectionState == BleConnectionState.disconnected) {
      if (state is BleConnecting) return;

      debugPrint('Disconnected from device: ${state.device!.remoteId}');

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

    try {
      await _database.upsertDevice(
        remoteId: state.device!.remoteId.toString(),
        advName: state.deviceName!,
        lastConnected: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Failed to save device: $e');
    }

    state = BleConnected(state.device!, savedDevice: state.savedDevice);

    try {
      final deviceServices = await _repository.discoverServices(state.device!);

      final relevantService = deviceServices.firstWhere(
        (service) => service.uuid == _repository.lumadriveServiceUuid,
        orElse: () => throw Exception('Lumadrive service not found'),
      );

      debugPrint('Relevant service discovered: ${relevantService.uuid}');

      state = BleConnected(
        state.device!,
        savedDevice: state.savedDevice,
        lumadriveService: relevantService,
      );
    } catch (e) {
      debugPrint('Failed to discover services: $e');
      unawaited(disconnect());
    }
  }

  Future<void> startScan() async {
    try {
      final granted = await _repository.requestPermissions();
      if (!granted) {
        state = const BleError(
          'Bluetooth permissions denied',
          details: 'Please grant Bluetooth scan and connect permissions to Lumadrive Control in Settings',
        );
        return;
      }

      final adapterState = await _repository.adapterState.first;
      if (adapterState != BleAdapterState.on) {
        if (Platform.isAndroid) {
          try {
            await _repository.turnOnBluetooth();
          } catch (e) {
            state = const BleError(
              'Bluetooth is off',
              details: 'Please turn on Bluetooth in Settings',
            );
            return;
          }

          final nowOn = await _repository.waitForAdapterOn();
          if (nowOn != BleAdapterState.on) {
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

      await _repository.startScan();

      _scanSub = _repository.onScanResults.listen((results) {
        debugPrint('Scan results: ${results.map((e) => e.device.advName)}');
        state = BleScanning(results.map((result) => result.device).toSet());
      });
    } catch (e) {
      state = const BleError(
        'Failed to start scanning',
        details: 'Check that Bluetooth is enabled and that the app has permission to scan for Bluetooth devices',
      );
      debugPrint('Failed to start scanning: $e');
    }
  }

  Future<void> reset() async {
    _scanSub?.cancel();
    _connectionSub?.cancel();
    unawaited(_repository.stopScan());

    if (state.device != null) {
      try {
        await _repository.disconnect(state.device!);
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
