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
  final bool starting;
  final bool active;

  const BleScanning(
    this.foundDevices, {
    this.starting = false,
    this.active = true,
  });
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
  final BleService _lumadriveService;

  @override
  BleDevice get device => _device;

  @override
  SavedDevice? get savedDevice => _savedDevice;

  @override
  BleService get lumadriveService => _lumadriveService;

  const BleConnected(
    this._device, {
    this._savedDevice,
    required this._lumadriveService,
  });
}

class BleError extends BleState {
  final String message;
  final String? details;
  @override
  final BleDevice? device;
  @override
  final SavedDevice? savedDevice;

  const BleError(this.message, {this.details, this.device, this.savedDevice});
}

class BleController extends Notifier<BleState> {
  late BleRepository _repository;
  DatabaseRepository get _database => ref.read(databaseRepositoryProvider);

  StreamSubscription<List<BleScanResult>>? _scanSub;
  StreamSubscription<bool>? _scanStateSub;
  StreamSubscription<BleAdapterState>? _adapterSub;
  StreamSubscription<BleConnectionState>? _connectionSub;
  BleDevice? _transportDevice;
  Future<void> _cleanup = Future<void>.value();
  int _generation = 0;
  bool _alive = true;
  bool _adapterWasOn = false;

  bool _current(int generation) => _alive && generation == _generation;

  @override
  BleState build() {
    _repository = ref.read(bleRepositoryProvider);
    _adapterSub = _repository.adapterState.listen(
      _handleAdapterState,
      onError: (Object error) {
        if (_alive) {
          _fail(_generation, const BleError('Bluetooth is unavailable'));
        }
      },
    );
    ref.onDispose(() {
      _alive = false;
      ++_generation;
      unawaited(_adapterSub?.cancel());
      unawaited(_stopActivity());
    });
    return const BleIdle();
  }

  Future<void> _ignoreFailure(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      debugPrint('Bluetooth cleanup: $error');
    }
  }

  // Capture resources before awaiting, then serialize cleanup so an old attempt
  // cannot disconnect a newer attempt to the same device.
  Future<void> _stopActivity() {
    final scan = _scanSub,
        scanState = _scanStateSub,
        connection = _connectionSub;
    final device = _transportDevice;
    _scanSub = null;
    _scanStateSub = null;
    _connectionSub = null;
    _transportDevice = null;
    final repository = _repository;
    _cleanup = _cleanup.then((_) async {
      if (scan != null) await _ignoreFailure(scan.cancel);
      if (scanState != null) await _ignoreFailure(scanState.cancel);
      if (connection != null) await _ignoreFailure(connection.cancel);
      await _ignoreFailure(repository.stopScan);
      if (device != null) {
        await _ignoreFailure(() => repository.disconnect(device));
      }
    });
    return _cleanup;
  }

  void _fail(int generation, BleError error) {
    if (!_current(generation)) return;
    ++_generation;
    state = error;
    unawaited(_stopActivity());
  }

  void _handleAdapterState(BleAdapterState adapterState) {
    if (!_alive) return;
    final wasOn = _adapterWasOn;
    _adapterWasOn = adapterState == BleAdapterState.on;
    if (!wasOn || _adapterWasOn) return;
    if (state is BleScanning ||
        state is BleConnecting ||
        state is BleConnected) {
      _fail(
        _generation,
        BleError(
          'Bluetooth was turned off',
          details: 'Please turn on Bluetooth in Settings',
          device: state.device,
          savedDevice: state.savedDevice,
        ),
      );
    }
  }

  Future<bool> _prepareBluetooth(
    int generation,
    BleDevice? device,
    SavedDevice? savedDevice,
  ) async {
    final granted = await _repository.requestPermissions();
    if (!_current(generation)) return false;
    if (!granted) {
      _fail(
        generation,
        BleError(
          'Bluetooth permissions denied',
          details:
              'Please grant Bluetooth scan and connect permissions in Settings',
          device: device,
          savedDevice: savedDevice,
        ),
      );
      return false;
    }
    var adapter = await _repository.adapterState.first;
    if (!_current(generation)) return false;
    if (adapter != BleAdapterState.on && Platform.isAndroid) {
      await _repository.turnOnBluetooth();
      if (!_current(generation)) return false;
      adapter = await _repository.waitForAdapterOn();
    }
    if (!_current(generation)) return false;
    if (adapter != BleAdapterState.on) {
      _fail(
        generation,
        BleError(
          'Bluetooth is off',
          details: 'Please turn on Bluetooth in Settings',
          device: device,
          savedDevice: savedDevice,
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> connectDevice(
    BleDevice device, {
    SavedDevice? savedDevice,
  }) async {
    final generation = ++_generation;
    state = BleConnecting(device, savedDevice: savedDevice);
    try {
      await _stopActivity();
      if (!_current(generation)) return;
      if (!await _prepareBluetooth(generation, device, savedDevice)) return;
      _transportDevice = device;
      var linked = false;
      _connectionSub = _repository
          .connectionState(device)
          .listen(
            (connection) {
              if (!_current(generation)) return;
              if (connection == BleConnectionState.connected) {
                linked = true;
              } else if (linked) {
                _fail(
                  generation,
                  BleError(
                    'Disconnected from device',
                    details: 'The connection to the controller was lost',
                    device: device,
                    savedDevice: savedDevice,
                  ),
                );
              }
            },
            onError: (Object error) {
              _fail(
                generation,
                BleError(
                  'Connection failed',
                  details:
                      'Check that the controller is powered on and in range',
                  device: device,
                  savedDevice: savedDevice,
                ),
              );
            },
          );
      await _repository.connect(device, timeout: 10.seconds);
      if (!_current(generation)) {
        if (_transportDevice?.remoteId != device.remoteId) {
          await _ignoreFailure(() => _repository.disconnect(device));
        }
        return;
      }
      linked = true;
      final services = await _repository.discoverServices(device);
      if (!_current(generation)) return;
      final service = services.firstWhere(
        (service) =>
            service.uuid.toLowerCase() ==
            _repository.lumadriveServiceUuid.toLowerCase(),
        orElse: () => throw StateError('Lumadrive service not found'),
      );
      state = BleConnected(
        device,
        savedDevice: savedDevice,
        lumadriveService: service,
      );
      try {
        await _database.upsertDevice(
          remoteId: device.remoteId,
          advName: savedDevice?.advName ?? device.advName,
          lastConnected: DateTime.now(),
        );
      } catch (error) {
        debugPrint('Failed to save controller: $error');
      }
    } catch (error) {
      _fail(
        generation,
        BleError(
          'Failed to connect to device',
          details: 'Check that the controller is in range and runs compatible firmware',
          device: device,
          savedDevice: savedDevice,
        ),
      );
    }
  }

  Future<void> connectToSavedDevice(SavedDevice device) async {
    // A failed connection never deletes a user's saved controller.
    await connectDevice(
      BleDevice(remoteId: device.remoteId, advName: device.advName),
      savedDevice: device,
    );
  }

  Future<void> deleteSavedDevice(String remoteId) async {
    if (state.device?.remoteId == remoteId) await reset();
    try {
      await _database.deleteDevice(remoteId);
    } catch (error) {
      debugPrint('Failed to delete saved controller: $error');
    }
  }

  Future<void> disconnect() => reset();

  int currentOperation() => _generation;

  Future<void> cancelAttempt(int operationId) async {
    if (_current(operationId)) {
      await reset();
    }
  }

  Future<void> reset() {
    ++_generation;
    state = const BleIdle();
    return _stopActivity();
  }

  Future<void> startScan() async {
    if (state is BleConnecting ||
        state is BleConnected ||
        (state is BleScanning && (state as BleScanning).active)) {
      return;
    }
    final generation = ++_generation;
    state = const BleScanning({}, starting: true);
    try {
      await _stopActivity();
      if (!_current(generation)) return;
      if (!await _prepareBluetooth(generation, null, null)) return;
      _scanSub = _repository.onScanResults.listen(
        (results) {
          if (!_current(generation) || state is! BleScanning) return;
          final scan = state as BleScanning;
          state = BleScanning(
            Set.unmodifiable(results.map((result) => result.device)),
            starting: scan.starting,
            active: scan.active,
          );
        },
        onError: (Object error) {
          _fail(
            generation,
            const BleError(
              'Device scanning failed',
              details: 'Check Bluetooth and try scanning again',
            ),
          );
        },
      );
      _scanStateSub = _repository.scanning.listen((active) {
        if (!_current(generation) || state is! BleScanning) return;
        final scan = state as BleScanning;
        if (!scan.starting) {
          state = BleScanning(scan.foundDevices, active: active);
        }
      });
      await _repository.startScan();
      if (!_current(generation)) {
        if (state is! BleScanning) await _ignoreFailure(_repository.stopScan);
        return;
      }
      state = BleScanning((state as BleScanning).foundDevices);
    } catch (error) {
      _fail(
        generation,
        const BleError(
          'Failed to start scanning',
          details: 'Check Bluetooth permissions and try again',
        ),
      );
    }
  }
}

final bleControllerProvider = NotifierProvider<BleController, BleState>(
  BleController.new,
);
