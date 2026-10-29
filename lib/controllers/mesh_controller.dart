import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/repositories/ble_repository.dart';
import 'package:lumadrive_control/repositories/matrix_client.dart';

class MeshState {
  final MeshInteropState interopState;
  final BleDevice masterDevice;
  final DateTime stateUpdatedAt = DateTime.now();

  MeshState({required this.interopState, required this.masterDevice});
}

class MeshController extends AsyncNotifier<MeshState> {
  MatrixClient? _matrixClient;
  BleConnected? _clientConnection;
  MatrixClient get _connectedClient {
    final connection = ref.read(bleControllerProvider);
    final client = _matrixClient;
    if (client == null || !identical(connection, _clientConnection)) {
      throw StateError('No connected master');
    }
    return client;
  }

  Future<LayoutReadResult> readLayout() {
    final client = _connectedClient;
    return client.readLayout();
  }

  Future<MatrixDocument> readMatrix() => _connectedClient.readMatrix();
  Future<MatrixDocument> readCurrentMatrix() =>
      _connectedClient.readCurrentMatrix();
  Stream<MatrixUploadProgress> updateMatrix(MatrixUpdate update) =>
      _connectedClient.updateMatrix(update);

  Future<void> identifyOutput(
    int snapshotId,
    int outputIndex, {
    int pixelCount = 0,
    bool reversed = false,
  }) {
    final client = _connectedClient;
    return client.identifyOutput(
      snapshotId,
      outputIndex,
      pixelCount: pixelCount,
      reversed: reversed,
    );
  }

  Stream<MatrixUploadProgress> uploadLayout(LayoutUpdate update) {
    final client = _connectedClient;
    return client.uploadLayout(update);
  }

  Stream<MatrixUploadProgress> uploadMatrixConfig(MatrixConfig config) {
    final client = _connectedClient;
    return client.upload(config);
  }

  Future<MatrixStatus> getMatrixStatus() {
    final client = _connectedClient;
    return client.getStatus();
  }

  Stream<MatrixStatus> watchMatrixStatus() {
    final client = _connectedClient;
    return client.watchStatus();
  }

  int _generation = 0;

  @override
  Future<MeshState> build() async {
    final connection = ref.watch(bleControllerProvider);
    final generation = ++_generation;
    _matrixClient = null;
    _clientConnection = null;
    StreamSubscription<MeshInteropState>? subscription;
    ref.onDispose(() {
      if (generation == _generation) {
        ++_generation;
        _matrixClient = null;
        _clientConnection = null;
      }
      unawaited(subscription?.cancel());
    });
    if (connection is! BleConnected) {
      throw StateError(
        connection is BleError ? connection.message : 'No connected controller',
      );
    }
    final repository = ref.read(bleRepositoryProvider);
    final client = repository.matrixClient(connection.lumadriveService);
    final initial = await repository.getDeviceMeshStatus(
      connection.lumadriveService,
    );
    if (!ref.mounted || generation != _generation) {
      throw StateError('Connection changed');
    }
    _matrixClient = client;
    _clientConnection = connection;
    subscription = repository
        .subscribeToMeshStatus(connection.lumadriveService)
        .listen(
          (status) {
            if (!ref.mounted || generation != _generation) return;
            state = AsyncData(
              MeshState(interopState: status, masterDevice: connection.device),
            );
          },
          onError: (Object error, StackTrace stack) {
            if (!ref.mounted || generation != _generation) return;
            state = AsyncError(error, stack);
          },
          onDone: () {
            if (!ref.mounted || generation != _generation) return;
            state = AsyncError(
              StateError('Mesh status stream closed'),
              StackTrace.current,
            );
          },
        );
    return MeshState(interopState: initial, masterDevice: connection.device);
  }

  bool getNodeOnlineStatus(MeshInteropNode node) {
    if (state.value == null) {
      debugPrint('Mesh state is null, cannot determine node online status');
      return false;
    }

    final lastSyncedAt = node.lastSyncedAt.toInt();

    if (lastSyncedAt == 0) {
      return false;
    }

    final nodeLastSyncedAt = state.value!.stateUpdatedAt.subtract(
      lastSyncedAt.microseconds,
    );
    final referenceTime = DateTime.now();

    return referenceTime.difference(nodeLastSyncedAt) < 4.seconds;
  }

  DateTime? getNodeLastSyncedAt(MeshInteropNode node) {
    if (state.value == null) {
      debugPrint('Mesh state is null, cannot determine node last synced at');
      return null;
    }

    final lastSyncedAt = node.lastSyncedAt.toInt();

    if (lastSyncedAt == 0) {
      return null;
    }

    return state.value!.stateUpdatedAt.subtract(lastSyncedAt.microseconds);
  }
}

Duration? _noRetry(int _, Object _) => null;

final meshControllerProvider = AsyncNotifierProvider<MeshController, MeshState>(
  () {
    return MeshController();
  },
  retry: _noRetry,
);
