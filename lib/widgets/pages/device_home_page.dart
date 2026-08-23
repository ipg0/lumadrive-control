import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';

class DeviceHomePage extends ConsumerWidget {
  const DeviceHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bleState = ref.watch(bleControllerProvider);

    ref.listen<BleState>(bleControllerProvider, (previous, next) {
      if (next is BleIdle) {
        context.go('/');
        return;
      }

      if (next is! BleConnected) {
        debugPrint(
          'Device disconnected, showing snackbar ${next.runtimeType} ${(next as BleError).message}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lost connection to device',
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
            action: SnackBarAction(
              label: 'To controller list',
              textColor: Theme.of(context).colorScheme.onError,
              onPressed: () {
                context.go('/');
              },
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(bleState.deviceName ?? 'Unknown Device')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ID: ${bleState.device?.remoteId ?? 'Unknown'}'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(bleControllerProvider.notifier).disconnect();
              },
              icon: const Icon(Icons.bluetooth_disabled),
              label: const Text('Disconnect'),
            ),
          ],
        ),
      ),
    );
  }
}
