import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lumadrive_control/providers/ble_controller.dart';
import 'package:pulsator/pulsator.dart';

class BleConnectingDisplay extends StatelessWidget {
  const BleConnectingDisplay({super.key, required this.state});

  final BleConnecting state;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16,
      children: [
        Text(
          'Connecting...',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        PulseIcon(
          pulseColor: Colors.greenAccent.withAlpha(200),
          pulseDuration: 2.5.seconds,
          pulseCount: 4,
          pulseSize: 200,
          icon: Icons.bluetooth_searching,
          iconSize: 48,
          innerSize: 64,
        ),
        Text(
          "Connecting to ${state.deviceName}",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
