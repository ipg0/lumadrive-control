import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/widgets/ble_states/ble_connected_display.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';
import 'package:lumadrive_control/widgets/ble_states/ble_connecting_display.dart';
import 'package:lumadrive_control/widgets/ble_states/ble_error_display.dart';
import 'package:lumadrive_control/widgets/ble_states/ble_idle_display.dart';
import 'package:lumadrive_control/widgets/ble_states/ble_scanning_display.dart';

class DeviceAddPage extends ConsumerWidget {
  const DeviceAddPage({super.key});

  Widget _displayState(WidgetRef ref) {
    final bleState = ref.watch(bleControllerProvider);
    return switch (bleState) {
      BleIdle() => BleIdleDisplay(state: bleState),
      BleScanning() => BleScanningDisplay(state: bleState),
      BleConnecting() => BleConnectingDisplay(state: bleState),
      BleConnected() => BleConnectedDisplay(state: bleState),
      BleError() => BleErrorDisplay(state: bleState),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && ref.read(bleControllerProvider) is! BleConnected) {
          final controller = ref.read(bleControllerProvider.notifier);
          final operationId = controller.currentOperation();
          Future<void>.microtask(() => controller.cancelAttempt(operationId));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Pair new controller')),
        body: Padding(
          padding: const .all(18),
          child: Center(
            child: PageTransitionSwitcher(
              duration: 300.milliseconds,
              transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                return SharedAxisTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: .horizontal,
                  child: child,
                );
              },
              child: _displayState(ref),
            ),
          ),
        ),
      ),
    );
  }
}
