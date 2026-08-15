import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/providers/ble_controller.dart';

class BleIdleDisplay extends ConsumerWidget {
  const BleIdleDisplay({super.key, required this.state});

  final BleIdle state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 16,
      children: [
        Text(
          'Add new controller',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                  ),
                ),
              ),
              Icon(
                Icons.bluetooth,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => ref.read(bleControllerProvider.notifier).startScan(),
          icon: const Icon(Icons.add),
          label: const Text('Start scanning'),
        ),
      ],
    );
  }
}
