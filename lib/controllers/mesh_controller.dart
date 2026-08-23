import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/repositories/ble_repository.dart';

class MeshState {
  final MeshInteropState interopState;

  MeshState({required this.interopState});
}

class MeshController extends AsyncNotifier<MeshState> {
  BleRepository get _bleRepository => ref.read(bleRepositoryProvider);

  @override
  Future<MeshState> build() async {
    final connectionState = ref.watch(bleControllerProvider);

    switch (connectionState) {
      case BleConnected connected:
        final initialStatus = await _bleRepository.getDeviceMeshStatus(
          connected.lumadriveService!,
        );

        // TODO: notify subscription

        return MeshState(interopState: initialStatus);
      case BleError(:final message):
        throw Exception(message);
      default:
        throw Exception('Disconnected');
    }
  }
}
