import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';
import 'package:lumadrive_control/controllers/mesh_controller.dart';
import 'package:lumadrive_control/repositories/ble_repository.dart';
import 'package:lumadrive_control/repositories/firmware_release_repository.dart';
import 'package:lumadrive_control/utils/stringify_mac.dart';

class FirmwareUpdateDialog extends ConsumerStatefulWidget {
  const FirmwareUpdateDialog({super.key});

  @override
  ConsumerState<FirmwareUpdateDialog> createState() =>
      _FirmwareUpdateDialogState();
}

class _FirmwareUpdateDialogState extends ConsumerState<FirmwareUpdateDialog> {
  Uint8List? _image;
  String? _name, _error, _releaseError;
  FirmwareRelease? _release;
  bool _checking = false,
      _downloading = false,
      _busy = false,
      _complete = false;
  double _progress = 0;
  String _updatingTarget = '';
  List<List<int>>? _targets;
  final Set<int> _completedTargets = {};
  int? _activeTarget;
  int? _failedTarget;

  @override
  void initState() {
    super.initState();
    _checkRelease();
  }

  Future<void> _checkRelease() async {
    setState(() {
      _checking = true;
      _releaseError = null;
    });
    try {
      final release = await ref
          .read(firmwareReleaseRepositoryProvider)
          .latest();
      if (mounted) setState(() => _release = release);
    } catch (error) {
      if (mounted)
        setState(() => _releaseError = 'Could not check for a release: $error');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _downloadRelease() async {
    final release = _release;
    if (release == null) return;
    setState(() {
      _downloading = true;
      _error = null;
      _progress = 0;
    });
    try {
      final image = await ref
          .read(firmwareReleaseRepositoryProvider)
          .download(
            release,
            onProgress: (progress) {
              if (mounted) setState(() => _progress = progress);
            },
          );
      if (mounted)
        setState(() {
          _image = image;
          _name = release.assetName;
        });
    } catch (error) {
      if (mounted)
        setState(() => _error = 'Could not download firmware: $error');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  Future<void> _pick() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['bin'],
        withData: true,
      );
      if (!mounted || result == null) return;
      final file = result.files.single;
      setState(() {
        _image = file.bytes;
        _name = file.name;
        _error = file.bytes == null
            ? 'Could not read the selected file.'
            : null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not select firmware: $error');
    }
  }

  Future<void> _upload() async {
    final connection = ref.read(bleControllerProvider);
    final image = _image;
    if (connection is! BleConnected || image == null) return;
    setState(() {
      _busy = true;
      _error = null;
      _progress = 0;
    });
    try {
      final mesh = ref.read(meshControllerProvider).value;
      if (mesh == null) {
        throw StateError(
          'Node list is not available. Reconnect and try again.',
        );
      }
      final nodes = mesh.interopState.nodes
          .map((node) => node.mac.toList())
          .toList();
      setState(() {
        _targets = nodes;
        _completedTargets.clear();
        _activeTarget = null;
        _failedTarget = null;
      });
      final client = ref
          .read(bleRepositoryProvider)
          .otaClient(connection.lumadriveService);
      await for (final progress in client.uploadAll(image, nodes)) {
        if (mounted) {
          setState(() {
            _progress = progress.overall;
            _activeTarget = progress.targetIndex;
            if (progress.completed) _completedTargets.add(progress.targetIndex);
            _updatingTarget = progress.nodeMac == null
                ? 'Controller'
                : 'Node ${macBytesToString(progress.nodeMac!)}';
          });
        }
      }
      if (mounted) setState(() => _complete = true);
    } catch (error) {
      if (mounted)
        setState(() {
          _failedTarget = _activeTarget;
          _error = 'Update failed: $error';
        });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = _busy || _downloading || _complete;
    final colors = Theme.of(context).colorScheme;
    final mesh = ref.watch(meshControllerProvider).value;
    final targets =
        _targets ??
        mesh?.interopState.nodes.map((node) => node.mac.toList()).toList();
    return PopScope(
      canPop: !_busy && !_downloading,
      child: AlertDialog(
        title: const Text('Update firmware'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Paired nodes are updated first, followed by the controller. All nodes must be online.',
                ),
                const SizedBox(height: 16),
                Text('Devices', style: Theme.of(context).textTheme.titleSmall),
                if (targets == null)
                  const Text('Node list unavailable')
                else
                  OtaDeviceList(
                    nodes: targets,
                    completed: _completedTargets,
                    failed: _failedTarget,
                    active: _busy ? _activeTarget : null,
                  ),
                const SizedBox(height: 16),
                Text(
                  'Latest release',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                if (_checking)
                  const Text('Checking GitHub for the latest release…')
                else if (_releaseError != null) ...[
                  Text(_releaseError!, style: TextStyle(color: colors.error)),
                  TextButton.icon(
                    onPressed: locked ? null : _checkRelease,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again'),
                  ),
                ] else if (_release != null) ...[
                  Text(
                    _release!.version,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _release!.assetName,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: locked ? null : _downloadRelease,
                    icon: const Icon(Icons.download),
                    label: const Text('Use latest release'),
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Or choose a firmware file',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: locked ? null : _pick,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Choose .bin file'),
                ),
                if (_name != null) ...[
                  const SizedBox(height: 12),
                  Text('Selected: $_name'),
                ],
                if (_busy || _downloading) ...[
                  const SizedBox(height: 16),
                  Text(
                    _downloading
                        ? 'Downloading firmware'
                        : 'Updating $_updatingTarget',
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: _progress),
                  const SizedBox(height: 8),
                  Text('${(_progress * 100).round()}%'),
                ],
                if (_complete) ...[
                  const SizedBox(height: 12),
                  const Text('Updates sent. The controller is restarting.'),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: colors.error)),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy || _downloading
                ? null
                : () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: locked || _image == null ? null : _upload,
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class OtaDeviceList extends StatelessWidget {
  final List<List<int>> nodes;
  final Set<int> completed;
  final int? failed, active;
  const OtaDeviceList({
    super.key,
    required this.nodes,
    required this.completed,
    this.failed,
    this.active,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index <= nodes.length; index++)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              index == nodes.length
                  ? 'Controller'
                  : 'Node ${macBytesToString(nodes[index])}',
            ),
            trailing: completed.contains(index)
                ? Icon(
                    Icons.check_circle,
                    color: colors.primary,
                    semanticLabel: 'Update sent',
                  )
                : failed == index
                ? Icon(
                    Icons.error_outline,
                    color: colors.error,
                    semanticLabel: 'Update failed',
                  )
                : active == index
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
        if (completed.isNotEmpty)
          Text(
            'Check marks mean the update was sent and a restart was requested.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}
