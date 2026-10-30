import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/controllers/matrix_editor_controller.dart';
import 'package:lumadrive_control/controllers/mesh_controller.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';

class ModeDashboard extends ConsumerStatefulWidget {
  const ModeDashboard({super.key});

  @override
  ConsumerState<ModeDashboard> createState() => _ModeDashboardState();
}

class _ModeDashboardState extends ConsumerState<ModeDashboard> {
  MatrixDocument? _document;
  MatrixConfig? _config;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    if (!mounted) return;
    try {
      final document = await ref
          .read(meshControllerProvider.notifier)
          .readCurrentMatrix();
      if (!mounted) return;
      setState(() {
        _document = document;
        _config = MatrixConfig.fromBuffer(document.config);
        _error = null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  Future<void> _save({int? selected, String? name}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final controller = ref.read(meshControllerProvider.notifier);
      final document = await controller.readMatrix();
      final config = MatrixConfig.fromBuffer(document.config);
      if (name != null) {
        if (config.modes.length >= 32) {
          throw StateError('Up to 32 modes are supported.');
        }
        var id = 1;
        while (config.modes.any((mode) => mode.id == id)) {
          id++;
        }
        config.modes.add(MatrixMode(id: id, name: name));
        selected = id;
      }
      config.activeModeId = selected ?? 0;
      final update = matrixPatch(config)
        ..expectedRevision = document.revision
        ..masterSession = document.masterSession;
      await for (final _ in controller.updateMatrix(update)) {}
      await _load();
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _add() async {
    var entered = '';
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New mode'),
        content: TextField(
          onChanged: (value) => entered = value,
          autofocus: true,
          maxLength: 32,
          decoration: const InputDecoration(labelText: 'Mode name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, entered.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    if (utf8.encode(name).length > 128) {
      setState(() => _error = 'Mode name is too long.');
      return;
    }
    await _save(name: name);
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Mode', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          if (_document == null && _error == null)
            const LinearProgressIndicator(),
          if (_config != null)
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 8.0;
                final columns = ((constraints.maxWidth + spacing) / 72)
                    .floor()
                    .clamp(1, 12);
                final tileWidth =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;
                final colors = Theme.of(context).colorScheme;
                Widget tile({
                  required Key key,
                  required Widget child,
                  required bool selected,
                  required VoidCallback? onPressed,
                }) {
                  return SizedBox(
                    key: key,
                    width: tileWidth,
                    height: 76,
                    child: Semantics(
                      selected: selected,
                      child: OutlinedButton(
                        onPressed: onPressed,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                          foregroundColor: selected
                              ? colors.onPrimaryContainer
                              : colors.onSurface,
                          backgroundColor: selected
                              ? colors.primaryContainer
                              : colors.surfaceContainerHigh,
                          side: BorderSide(
                            color: selected
                                ? colors.primary
                                : colors.outlineVariant,
                            width: selected ? 2 : 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: child,
                      ),
                    ),
                  );
                }

                Widget mode(int id, String name) => tile(
                  key: ValueKey('mode-button-$id'),
                  selected: _config!.activeModeId == id,
                  onPressed: _busy
                      ? null
                      : () {
                          if (id != _config!.activeModeId) _save(selected: id);
                        },
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    mode(0, 'Default'),
                    for (final item in _config!.modes) mode(item.id, item.name),
                    Tooltip(
                      message: 'Create mode',
                      child: tile(
                        key: const ValueKey('add-mode'),
                        selected: false,
                        onPressed: _busy || _config!.modes.length >= 32
                            ? null
                            : _add,
                        child: const Icon(
                          Icons.add,
                          size: 32,
                          semanticLabel: 'Create mode',
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          if (_busy) const LinearProgressIndicator(),
          if (_error != null)
            TextButton(
              onPressed: _busy ? null : _load,
              child: const Text('Retry'),
            ),
        ],
      ),
    ),
  );
}
