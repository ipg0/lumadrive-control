import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';
import 'package:lumadrive_control/repositories/ble_repository.dart';
import 'package:lumadrive_control/repositories/firmware_release_repository.dart';

class FirmwareUpdateDialog extends ConsumerStatefulWidget {
  const FirmwareUpdateDialog({super.key});

  @override
  ConsumerState<FirmwareUpdateDialog> createState() => _FirmwareUpdateDialogState();
}

class _FirmwareUpdateDialogState extends ConsumerState<FirmwareUpdateDialog> {
  Uint8List? _image;
  String? _name, _error, _releaseError;
  FirmwareRelease? _release;
  bool _checking = false, _downloading = false, _busy = false, _complete = false;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _checkRelease();
  }

  Future<void> _checkRelease() async {
    setState(() { _checking = true; _releaseError = null; });
    try {
      final release = await ref.read(firmwareReleaseRepositoryProvider).latest();
      if (mounted) setState(() => _release = release);
    } catch (error) {
      if (mounted) setState(() => _releaseError = 'Could not check for a release: $error');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _downloadRelease() async {
    final release = _release;
    if (release == null) return;
    setState(() { _downloading = true; _error = null; _progress = 0; });
    try {
      final image = await ref.read(firmwareReleaseRepositoryProvider).download(release, onProgress: (progress) {
        if (mounted) setState(() => _progress = progress);
      });
      if (mounted) setState(() { _image = image; _name = release.assetName; });
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not download firmware: $error');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

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
  Widget build(BuildContext context) {
    final locked = _busy || _downloading || _complete;
    final colors = Theme.of(context).colorScheme;
    return PopScope(
      canPop: !_busy && !_downloading,
      child: AlertDialog(
        title: const Text('Update controller firmware'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Latest release', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              if (_checking) const Text('Checking GitHub for the latest release…')
              else if (_releaseError != null) ...[
                Text(_releaseError!, style: TextStyle(color: colors.error)),
                TextButton.icon(onPressed: locked ? null : _checkRelease, icon: const Icon(Icons.refresh), label: const Text('Try again')),
              ] else if (_release != null) ...[
                Text(_release!.version, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(_release!.assetName, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                OutlinedButton.icon(onPressed: locked ? null : _downloadRelease, icon: const Icon(Icons.download), label: const Text('Use latest release')),
              ],
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Text('Or choose a firmware file', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              OutlinedButton.icon(onPressed: locked ? null : _pick, icon: const Icon(Icons.folder_open), label: const Text('Choose .bin file')),
              if (_name != null) ...[const SizedBox(height: 12), Text('Selected: $_name')],
              if (_busy || _downloading) ...[
                const SizedBox(height: 16),
                Text(_downloading ? 'Downloading firmware' : 'Uploading firmware'),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 8),
                Text('${(_progress * 100).round()}%'),
              ],
              if (_complete) ...[const SizedBox(height: 12), const Text('Update installed. The controller is restarting.')],
              if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: TextStyle(color: colors.error))],
            ],
          )),
        ),
        actions: [
          TextButton(onPressed: _busy || _downloading ? null : () => Navigator.of(context).pop(), child: const Text('Close')),
          FilledButton(onPressed: locked || _image == null ? null : _upload, child: const Text('Update')),
        ],
      ),
    );
  }
}
