import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';
import 'package:lumadrive_control/controllers/mesh_controller.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/repositories/ble_repository.dart';

import 'connection_fakes.dart';

void main() {
  late ProviderContainer container;
  late TestBleRepository repository;
  late TestConnectionController connection;
  Future<void> flush() => Future<void>.delayed(Duration.zero);
  setUp(() {
    repository = TestBleRepository();
    container = ProviderContainer(
      overrides: [
        bleRepositoryProvider.overrideWithValue(repository),
        bleControllerProvider.overrideWith(TestConnectionController.new),
      ],
    );
    connection = container.read(
      bleControllerProvider.notifier,
    ) as TestConnectionController;
    container.listen(meshControllerProvider, (_, _) {});
  });
  tearDown(() async {
    container.dispose();
    await flush();
    await repository.close();
  });
  test('late mesh reads cannot restore a client after disconnect', () async {
    final service = TestBleService(repository.lumadriveServiceUuid),
        gate = Completer<MeshInteropState>();
    repository.meshReadGates[service] = gate;
    connection.emit(BleConnected(firstController, lumadriveService: service));
    await flush();
    connection.emit(const BleIdle());
    await flush();
    gate.complete(MeshInteropState());
    await flush();
    expect(container.read(meshControllerProvider).hasError, isTrue);
    expect(
      () => container.read(meshControllerProvider.notifier).getMatrixStatus(),
      throwsStateError,
    );
    expect(repository.meshStreams, isEmpty);
  });
  test('old mesh subscriptions cannot overwrite a new controller', () async {
    final first = TestBleService(repository.lumadriveServiceUuid),
        second = TestBleService(repository.lumadriveServiceUuid);
    connection.emit(BleConnected(firstController, lumadriveService: first));
    await flush();
    expect(
      container.read(meshControllerProvider).value!.masterDevice,
      firstController,
    );
    final previousClient = container.read(meshControllerProvider.notifier);
    connection.emit(BleConnected(secondController, lumadriveService: second));
    expect(previousClient.getMatrixStatus, throwsStateError);
    await flush();
    repository.meshStreams[first]!.add(MeshInteropState());
    await flush();
    expect(
      container.read(meshControllerProvider).value!.masterDevice,
      secondController,
    );
    expect(repository.meshStreams[first]!.hasListener, isFalse);
    repository.meshStreams[second]!.addError(StateError('Notification failed'));
    await flush();
    expect(container.read(meshControllerProvider).hasError, isTrue);
    repository.meshStreams[second]!.add(MeshInteropState());
    await flush();
    expect(
      container.read(meshControllerProvider).value!.masterDevice,
      secondController,
    );
    await repository.meshStreams[second]!.close();
    await flush();
    expect(container.read(meshControllerProvider).hasError, isTrue);
  });
  test(
    'node is online only when its last sync is less than five seconds old',
    () async {
      final service = TestBleService(repository.lumadriveServiceUuid);
      connection.emit(BleConnected(firstController, lumadriveService: service));
      await flush();
      final mesh = container.read(meshControllerProvider.notifier);
      expect(
        mesh.getNodeOnlineStatus(MeshInteropNode(lastSyncedAt: Int64(4500000))),
        isTrue,
      );
      expect(
        mesh.getNodeOnlineStatus(MeshInteropNode(lastSyncedAt: Int64(5000000))),
        isFalse,
      );
      expect(mesh.getNodeOnlineStatus(MeshInteropNode()), isFalse);
    },
  );
}
