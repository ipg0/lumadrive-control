import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lumadrive_control/controllers/ble_controller.dart';

class BleConnectedDisplay extends ConsumerWidget {
  const BleConnectedDisplay({super.key, required this.state});

  final BleConnected state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16,
      children: [
        Text(
          "Connected to ${state.deviceName}",
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
                    color: Colors.greenAccent.withAlpha(200),
                  ),
                ),
              ),
              Icon(Icons.bluetooth_connected, size: 48),
            ],
          ),
        ),
      ],
    );
  }
}
