import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/repositories/ble_repository.dart';

class MeshState {
  final MeshInteropState interopState;
  final BleDevice masterDevice;
  final DateTime stateUpdatedAt = DateTime.now();

  MeshState({required this.interopState, required this.masterDevice});
}

class MeshController extends AsyncNotifier<MeshState> {
  BleRepository get _bleRepository => ref.read(bleRepositoryProvider);
  StreamSubscription<MeshInteropState>? _meshStatusSub;

  @override
  Future<MeshState> build() async {
    final connectionState = ref.watch(bleControllerProvider);

    switch (connectionState) {
      case BleConnected connected:
        final initialStatus = await _bleRepository.getDeviceMeshStatus(
          connected.lumadriveService!,
        );

        _subscribeToMeshStatus(connected.lumadriveService!);

        ref.onDispose(() {
          _meshStatusSub?.cancel();
        });

        return MeshState(
          interopState: initialStatus,
          masterDevice: connected.device,
        );
      case BleError(:final message):
        debugPrint('HERE');
        throw Exception(message);
      case BleIdle():
        throw Exception('Lost connection to device');
      default:
        throw Exception('Unexpected connection state: $connectionState');
    }
  }

  void _subscribeToMeshStatus(BleService service) {
    _meshStatusSub?.cancel();
    _meshStatusSub = _bleRepository
        .subscribeToMeshStatus(service)
        .listen(
          (status) {
            final currentState = state.value;
            if (currentState == null) return;

            state = AsyncData(
              MeshState(
                interopState: status,
                masterDevice: currentState.masterDevice,
              ),
            );
          },
          onError: (error, stackTrace) {
            debugPrint('Error receiving mesh status: $error');
            debugPrintStack(stackTrace: stackTrace);
          },
        );
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
