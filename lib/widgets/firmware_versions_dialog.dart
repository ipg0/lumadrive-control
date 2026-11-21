import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/controllers/mesh_controller.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/utils/stringify_mac.dart';

class FirmwareVersionsDialog extends ConsumerStatefulWidget {
  const FirmwareVersionsDialog({super.key});

  @override
  ConsumerState<FirmwareVersionsDialog> createState() => _FirmwareVersionsDialogState();
}

class _FirmwareVersionsDialogState extends ConsumerState<FirmwareVersionsDialog> {
  late Future<MatrixDocument> _document;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _document = Future.sync(() => ref.read(meshControllerProvider.notifier).readMatrix());
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Firmware versions'),
    content: SizedBox(
      width: 380,
      child: FutureBuilder<MatrixDocument>(
        future: _document,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Text('Could not read firmware versions. Check the connection and try again.');
          }
          final document = snapshot.requireData;
          final nodes = document.nodes.where((node) =>
              !listEquals(node.nodeMac, document.masterMac));
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _versionRow('Controller', document.masterFirmwareVersion, true),
                for (final node in nodes) ...[
                  const Divider(),
                  _versionRow('Node ${macBytesToString(node.nodeMac)}', node.firmwareVersion, node.online),
                ],
              ],
            ),
          );
        },
      ),
    ),
    actions: [
      TextButton(onPressed: () => setState(_load), child: const Text('Refresh')),
      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
    ],
  );

  Widget _versionRow(String title, String version, bool online) {
    final detail = version.isEmpty ? 'Unknown' : version;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(online ? detail : '$detail · Offline${version.isEmpty ? '' : ', last known'}'),
      ]),
    );
  }
}
