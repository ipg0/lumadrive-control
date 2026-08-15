import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'dart:async';

import 'package:lumadrive_control/providers/ble_controller.dart';

class BleConnectedDisplay extends ConsumerStatefulWidget {
  const BleConnectedDisplay({super.key, required this.state});

  final BleConnected state;

  @override
  ConsumerState<BleConnectedDisplay> createState() =>
      _BleConnectedDisplayState();
}

class _BleConnectedDisplayState extends ConsumerState<BleConnectedDisplay> {
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _redirectTimer = Timer(0.5.seconds, () {
      if (mounted) {
        ref.context.go('/device');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16,
      children: [
        Text(
          "Connected to ${widget.state.deviceName}",
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

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }
}
