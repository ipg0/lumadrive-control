import 'package:flutter/material.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BleErrorDisplay extends ConsumerWidget {
  const BleErrorDisplay({
    super.key,
    required this.state,
    this.icon,
    this.label,
    this.onBack,
  });

  final BleError state;
  final IconData? icon;
  final String? label;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16,
      children: [
        Text(
          state.message,
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
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
              Icon(
                Icons.bluetooth_disabled,
                size: 48,
                color: Theme.of(context).colorScheme.onError,
              ),
            ],
          ),
        ),
        Text(
          state.details ?? 'An error happened',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        ElevatedButton.icon(
          icon: Icon(icon ?? Icons.refresh),
          label: Text(label ?? 'Try again'),
          onPressed: () {
            ref.read(bleControllerProvider.notifier).reset();
            if (onBack != null) {
              onBack!();
            }
          },
        ),
      ],
    );
  }
}
