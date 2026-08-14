import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/providers/ble_controller.dart';

class BleScanPage extends ConsumerWidget {
  const BleScanPage({super.key});

  Widget _displayState(WidgetRef ref) {
    final bleState = ref.watch(bleControllerProvider);
    return switch (bleState) {
      BleIdle() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Idle'),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                ref.read(bleControllerProvider.notifier).startScan(),
            child: Text('Start Scan'),
          ),
        ],
      ),
      BleScanning() => const Text('Scanning...'),
      BleDeviceFound(:var device) => Text('Device found: ${device.advName}'),
      BleConnected(:var device) => Text('Connected to: ${device.advName}'),
      BleError(:var message) => Text('Error: $message'),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(body: Center(child: _displayState(ref)));
  }
}
