import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';
import 'package:lumadrive_control/data/database.dart';
import 'package:lumadrive_control/repositories/ble_repository.dart';
import 'package:lumadrive_control/repositories/database_repository.dart';

import 'connection_fakes.dart';

void main() {
  late TestBleRepository repository;
  late TestDatabaseRepository database;
  late ProviderContainer container;
  late BleController controller;
  Future<void> flush() => Future<void>.delayed(Duration.zero);
  setUp(() {
    repository = TestBleRepository();
    database = TestDatabaseRepository();
    container = ProviderContainer(
      overrides: [
        bleRepositoryProvider.overrideWithValue(repository),
        databaseRepositoryProvider.overrideWithValue(database),
      ],
    );
    controller = container.read(bleControllerProvider.notifier);
  });
  tearDown(() async {
    container.dispose();
    await flush();
    await repository.close();
  });
  BleState state() => container.read(bleControllerProvider);

  test('deferred Back cancellation wins over readiness but cannot cancel a newer attempt', () async {
    final discovery = Completer<List<BleService>>();
    repository.discoveryGates[firstController.remoteId] = discovery;
    final attempt = controller.connectDevice(firstController);
    await flush();
      final cancelledOperation = controller.currentOperation();
    discovery.complete([TestBleService(repository.lumadriveServiceUuid)]);
    await attempt;
    await controller.cancelAttempt(cancelledOperation);
    expect(state(), isA<BleIdle>());
    await controller.connectDevice(secondController);
    await controller.cancelAttempt(cancelledOperation);
    expect(state().device, secondController);
  });

  test(
    'connected means discovery is complete and a usable service exists',
    () async {
      final discovery = Completer<List<BleService>>();
      repository.discoveryGates[firstController.remoteId] = discovery;
      final attempt = controller.connectDevice(firstController);
      await flush();
      expect(state(), isA<BleConnecting>());
      expect(database.saved, isEmpty);
      discovery.complete([TestBleService(repository.lumadriveServiceUuid)]);
      await attempt;
      expect(state(), isA<BleConnected>());
      expect(state().lumadriveService, isNotNull);
      expect(database.saved, [firstController.remoteId]);
    },
  );
  test(
    'reset cancels pending discovery without resurrecting a connection',
    () async {
      final discovery = Completer<List<BleService>>();
      repository.discoveryGates[firstController.remoteId] = discovery;
      final attempt = controller.connectDevice(firstController);
      await flush();
      await controller.reset();
      discovery.complete([TestBleService(repository.lumadriveServiceUuid)]);
      await attempt;
      expect(state(), isA<BleIdle>());
      expect(database.saved, isEmpty);
      expect(repository.disconnected, contains(firstController.remoteId));
    },
  );
  test(
    'late connection completion cannot replace a newer controller',
    () async {
      final gate = Completer<void>();
      repository.connectGates[firstController.remoteId] = gate;
      final old = controller.connectDevice(firstController);
      await flush();
      await controller.connectDevice(secondController);
      gate.complete();
      await old;
      expect(state().device, secondController);
      expect(state(), isA<BleConnected>());
      expect(repository.disconnected, contains(firstController.remoteId));
      expect(
        repository.disconnected,
        isNot(contains(secondController.remoteId)),
      );
    },
  );
  test(
    'permission completion after cancellation cannot start scanning',
    () async {
      repository.permissionGate = Completer<bool>();
      final scan = controller.startScan();
      await flush();
      expect(
        state(),
        isA<BleScanning>().having((s) => s.starting, 'preparing', isTrue),
      );
      await controller.reset();
      repository.permissionGate!.complete(true);
      await scan;
      expect(state(), isA<BleIdle>());
      expect(repository.scanStarts, 0);
    },
  );
  test('scan completion retains results and permits another scan', () async {
    await controller.startScan();
    repository.results.add([const BleScanResult(firstController)]);
    await flush();
    repository.scanStates.add(false);
    await flush();
    expect(
      state(),
      isA<BleScanning>().having((s) => s.active, 'active', isFalse),
    );
    expect((state() as BleScanning).foundDevices, contains(firstController));
    await controller.startScan();
    expect(repository.scanStarts, 2);
  });
  test(
    'discovery failure has an error state and retains saved controllers',
    () async {
      repository.rejectDiscovery = true;
      await controller.connectToSavedDevice(
        SavedDevice(
          remoteId: firstController.remoteId,
          advName: firstController.advName,
          lastConnected: DateTime(2026),
        ),
      );
      expect(state(), isA<BleError>());
      expect(database.deleted, isEmpty);
      expect(state().device, firstController);
      await flush();
      expect(repository.disconnected, contains(firstController.remoteId));
    },
  );
  test('Bluetooth loss fences pending discovery', () async {
    final discovery = Completer<List<BleService>>();
    repository.discoveryGates[firstController.remoteId] = discovery;
    final attempt = controller.connectDevice(firstController);
    await flush();
    repository.setAdapter(BleAdapterState.off);
    await flush();
    discovery.complete([TestBleService(repository.lumadriveServiceUuid)]);
    await attempt;
    expect(state(), isA<BleError>());
    expect(database.saved, isEmpty);
  });
  test('unexpected link loss clears readiness and explicit disconnect returns idle', () async {
    await controller.connectDevice(firstController);
    repository
        .connectionFor(firstController)
        .add(BleConnectionState.disconnected);
    await flush();
    expect(state(), isA<BleError>());
    expect(state().device, firstController);
    await controller.disconnect();
    expect(state(), isA<BleIdle>());
  });
}
