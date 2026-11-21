import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';
import 'package:lumadrive_control/repositories/ble_repository.dart';

class FirmwareUpdateDialog extends ConsumerStatefulWidget {
  const FirmwareUpdateDialog({super.key});

  @override
  ConsumerState<FirmwareUpdateDialog> createState() => _FirmwareUpdateDialogState();
}

class _FirmwareUpdateDialogState extends ConsumerState<FirmwareUpdateDialog> {
  Uint8List? _image;
  String? _name, _error;
  bool _busy = false, _complete = false;
  double _progress = 0;

  Future<void> _pick() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['bin'], withData: true,
      );
      if (!mounted || result == null) return;
      final file = result.files.single;
      setState(() { _image = file.bytes; _name = file.name; _error = file.bytes == null ? 'Could not read the selected file.' : null; });
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not select firmware: $error');
    }
  }

  Future<void> _upload() async {
    final connection = ref.read(bleControllerProvider);
    final image = _image;
    if (connection is! BleConnected || image == null) return;
    setState(() { _busy = true; _error = null; _progress = 0; });
    try {
      final client = ref.read(bleRepositoryProvider).otaClient(connection.lumadriveService);
      await for (final progress in client.upload(image)) {
        if (mounted) setState(() => _progress = progress);
      }
      if (mounted) setState(() => _complete = true);
    } catch (error) {
      if (mounted) setState(() => _error = 'Update failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      title: const Text('Update controller firmware'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Choose a firmware .bin file for the controller.'),
        const SizedBox(height: 16),
        OutlinedButton.icon(onPressed: _busy ? null : _pick, icon: const Icon(Icons.folder_open), label: const Text('Choose file')),
        if (_name != null) ...[const SizedBox(height: 8), Text(_name!, overflow: TextOverflow.ellipsis)],
        if (_busy) ...[const SizedBox(height: 16), LinearProgressIndicator(value: _progress), const SizedBox(height: 8), Text('${(_progress * 100).round()}%')],
        if (_complete) ...[const SizedBox(height: 12), const Text('Update installed. The controller is restarting.')],
        if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))],
      ]),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.of(context).pop(), child: const Text('Close')),
        FilledButton(onPressed: _busy || _image == null || _complete ? null : _upload, child: const Text('Update')),
      ],
    ),
  );
}
