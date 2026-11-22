import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';
import 'package:pulsator/pulsator.dart';

class BleScanningDisplay extends ConsumerWidget {
  const BleScanningDisplay({super.key, required this.state});

  final BleScanning state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16,
      children: [
        Text(
          state.starting
              ? 'Preparing Bluetooth…'
              : state.active
              ? 'Searching for devices…'
              : 'Search finished',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        if (state.active)
          PulseIcon(
            pulseColor: Theme.of(context).colorScheme.primary,
            pulseDuration: 2.5.seconds,
            pulseCount: 4,
            icon: Icons.bluetooth_searching,
            iconSize: 48,
            innerSize: 64,
            pulseSize: 200,
          ),
        if (!state.active)
          FilledButton.icon(
            onPressed: () =>
                ref.read(bleControllerProvider.notifier).startScan(),
            icon: const Icon(Icons.refresh),
            label: const Text('Scan again'),
          ),
        Text(
          'Disconnect the currently connected device or restart the controller to enter connection mode',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.foundDevices.length,

            itemBuilder: (context, index) {
              final device = state.foundDevices.elementAt(index);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
                  child: ListTile(
                    title: Text(
                      device.advName,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: Text(device.remoteId.toString()),
                    leading: Icon(Icons.bluetooth, size: 24),
                    trailing: Icon(
                      Icons.circle,
                      size: 12,
                      color: Colors.greenAccent,
                    ),
                  ),

                  onPressed: () {
                    ref
                        .read(bleControllerProvider.notifier)
                        .connectDevice(device);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
