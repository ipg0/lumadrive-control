import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/widgets/ble_states/ble_connected_display.dart';
import 'package:lumadrive_control/providers/ble_controller.dart';
import 'package:lumadrive_control/widgets/ble_states/ble_connecting_display.dart';
import 'package:lumadrive_control/widgets/ble_states/ble_error_display.dart';

class SavedDeviceConnectionPage extends ConsumerWidget {
  const SavedDeviceConnectionPage({super.key});

  Widget _displayState(WidgetRef ref) {
    final bleState = ref.watch(bleControllerProvider);

    return switch (bleState) {
      BleConnecting() => BleConnectingDisplay(state: bleState),
      BleConnected() => BleConnectedDisplay(state: bleState),
      BleError() => BleErrorDisplay(
        state: bleState,
        icon: Icons.arrow_back,
        label: 'Back',
        onBack: () {
          ref.context.go('/');
        },
      ),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Connecting to controller')),
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
    );
  }
}
