import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';
import 'package:lumadrive_control/controllers/mesh_controller.dart';
import 'package:lumadrive_control/controllers/layout_editor_controller.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/repositories/layout_repository.dart';
import 'package:lumadrive_control/repositories/ble_repository.dart';
import 'package:lumadrive_control/widgets/layout/layout_canvas.dart';
import 'package:lumadrive_control/widgets/layout/layout_output_editor.dart';
import 'package:lumadrive_control/widgets/layout/car_layout.dart';
import 'package:lumadrive_control/repositories/database_repository.dart';
import 'package:lumadrive_control/utils/car_positions.dart';
import 'package:lumadrive_control/utils/stringify_mac.dart';
import 'package:lumadrive_control/widgets/node_name_dialog.dart';

class LayoutEditorPage extends ConsumerStatefulWidget {
  final LayoutEditorController? controller;
  final String? controllerId;
  final bool initialAdvanced;
  const LayoutEditorPage({
    super.key,
    this.controller,
    this.controllerId,
    this.initialAdvanced = false,
  });
  @override
  ConsumerState<LayoutEditorPage> createState() => _LayoutEditorPageState();
}

class _LayoutEditorPageState extends ConsumerState<LayoutEditorPage>
    with WidgetsBindingObserver {
  late final LayoutEditorController _editor;
  BleDevice? _owner;
  late bool _advanced;
  bool _isOwnerConnected() {
    if (!mounted) return false;
    final connection = ref.read(bleControllerProvider);
    return connection is BleConnected &&
        connection.device.remoteId == _owner?.remoteId;
  }

  Future<void> _renameNode(List<int> mac, CarPosition position) async {
    final owner = widget.controllerId ?? _owner?.remoteId;
    if (owner == null) return;
    final address = macBytesToString(mac);
    final name = await showDialog<String>(
      context: context,
      builder: (_) => NodeNameDialog(
        address: address,
        current: suggestedNodeName(position),
      ),
    );
    if (name == null || !mounted) return;
    try {
      await ref
          .read(databaseRepositoryProvider)
          .setNodeName(owner, address, name);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save the node name. Try again.'),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _advanced = widget.initialAdvanced;
    WidgetsBinding.instance.addObserver(this);
    final device = widget.controller == null
        ? ref.read(bleControllerProvider).device
        : null;
    final ownerId = widget.controllerId ?? device?.remoteId;
    if (widget.controller == null && ownerId == null) {
      throw StateError('Layout needs a controller identity');
    }
    if (ownerId != null) {
      _owner = BleDevice(
        remoteId: ownerId,
        advName: device?.remoteId == ownerId ? device!.advName : 'Controller',
      );
    }
    _editor =
        widget.controller ??
        LayoutEditorController(
          repository: ConnectedLayoutRepository(
            isAvailable: _isOwnerConnected,
            readLayout: () =>
                ref.read(meshControllerProvider.notifier).readLayout(),
            getStatus: () =>
                ref.read(meshControllerProvider.notifier).getMatrixStatus(),
            identifyOutput: (token, index, length, reversed) => ref
                .read(meshControllerProvider.notifier)
                .identifyOutput(
                  token,
                  index,
                  pixelCount: length,
                  reversed: reversed,
                ),
            uploadLayout: (update) =>
                ref.read(meshControllerProvider.notifier).uploadLayout(update),
          ),
          store: ref.read(layoutDraftStoreProvider(ownerId!)),
        );
    unawaited(_editor.initialize());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(_editor.flush());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.controller == null) _editor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ownerId = widget.controllerId ?? _owner?.remoteId;
    _editor.nodeNames = ownerId == null
        ? const {}
        : ref.watch(nodeNamesProvider(ownerId)).value ?? const {};
    if (widget.controller == null) {
      ref.listen(
        bleControllerProvider,
        (_, connection) => _editor.connectionChanged(
          connection is BleConnected &&
              connection.device.remoteId == _owner?.remoteId,
        ),
      );
    }
    return ListenableBuilder(
      listenable: _editor,
      builder: (context, _) {
        final theme = Theme.of(context), colors = theme.colorScheme;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Car layout'),
            actions: [
              IconButton(
                tooltip: 'Refresh outputs',
                onPressed: _editor.busy ? null : () => _editor.refresh(),
                icon: const Icon(Icons.refresh),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilledButton(
                  key: const ValueKey('apply-layout'),
                  onPressed: _editor.canApply ? _editor.apply : null,
                  child: Text(_editor.applying ? 'Applying…' : 'Apply'),
                ),
              ),
            ],
          ),
          body: _editor.loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _editor.refresh,
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      Text(
                        'One layout for all your lighting',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Arrange the outputs in your car. Every animation flows through this shared canvas.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<bool>(
                        key: const ValueKey('layout-mode'),
                        segments: const [
                          ButtonSegment(
                            value: false,
                            label: Text('Simple'),
                            icon: Icon(Icons.directions_car_outlined),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text('Advanced'),
                            icon: Icon(Icons.view_timeline_outlined),
                          ),
                        ],
                        selected: {_advanced},
                        onSelectionChanged: (value) =>
                            setState(() => _advanced = value.single),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_editor.dirty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_note,
                                    size: 19,
                                    color: colors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Draft · changes apply when you save',
                                      style: theme.textTheme.labelLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_editor.conflict)
                            _banner(
                              context,
                              Icons.sync_problem,
                              'The configuration changed on the controller. Your draft is kept here.',
                              action: TextButton(
                                onPressed: () =>
                                    _editor.refresh(discardDraft: true),
                                child: const Text('Use saved layout'),
                              ),
                            ),
                          if (!_editor.connected)
                            _banner(
                              context,
                              Icons.cloud_off_outlined,
                              'Controller disconnected. Your draft is kept on this phone.',
                              action: TextButton(
                                onPressed: () {
                                  if (widget.controller != null ||
                                      _isOwnerConnected()) {
                                    _editor.refresh();
                                  } else if (ref.read(bleControllerProvider)
                                          is! BleConnecting &&
                                      _owner != null) {
                                    ref
                                        .read(bleControllerProvider.notifier)
                                        .connectDevice(_owner!);
                                  }
                                },
                                child: Text(
                                  widget.controller != null ||
                                          _isOwnerConnected()
                                      ? 'Retry'
                                      : 'Reconnect',
                                ),
                              ),
                            ),
                          if (_editor.error != null)
                            _banner(
                              context,
                              Icons.info_outline,
                              _editor.error!,
                              error: true,
                            ),
                          if (_editor.validationError != null &&
                              _editor.fieldError == null)
                            _banner(
                              context,
                              Icons.rule,
                              _editor.validationError!,
                              error: true,
                            ),
                          if (_editor.notice != null)
                            _banner(
                              context,
                              Icons.check_circle_outline,
                              _editor.notice!,
                            ),
                          if (_editor.deploymentNotice != null)
                            _banner(
                              context,
                              Icons.sync,
                              _editor.deploymentNotice!,
                            ),
                          if (_editor.applying)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LinearProgressIndicator(
                                    value: _editor.progress == 1
                                        ? null
                                        : _editor.progress,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _editor.progress == 1
                                        ? 'Saving and syncing with nodes…'
                                        : 'Sending layout…',
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      if (_advanced)
                        LayoutCanvas(
                          key: const ValueKey('layout-canvas'),
                          controller: _editor,
                        )
                      else
                        CarLayout(
                          key: const ValueKey('car-layout'),
                          controller: _editor,
                          renameNode:
                              widget.controllerId != null || _owner != null
                              ? _renameNode
                              : null,
                        ),
                      if (_advanced && _editor.selected != null) ...[
                        const SizedBox(height: 12),
                        LayoutOutputEditor(
                          key: ValueKey('editor-${_editor.selectedKey}'),
                          controller: _editor,
                          advanced: _advanced,
                        ),
                      ],
                      if (_editor.canvasSize > 0)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Layout center',
                                  style: theme.textTheme.titleMedium,
                                ),
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Automatic center'),
                                  subtitle: const Text(
                                    'Between the left and right dash; otherwise the layout midpoint.',
                                  ),
                                  value: _editor.centerIndex == null,
                                  onChanged: _editor.busy
                                      ? null
                                      : (automatic) => _editor.setCenter(
                                          automatic
                                              ? null
                                              : _editor.resolvedCenter,
                                        ),
                                ),
                                if (_editor.centerIndex != null) ...[
                                  Text(
                                    'Center: ${_editor.centerIndex} / ${_editor.canvasSize}',
                                  ),
                                  Slider(
                                    key: const ValueKey('layout-center-slider'),
                                    min: 0,
                                    max: _editor.canvasSize.toDouble(),
                                    value: _editor.centerIndex!
                                        .clamp(0, _editor.canvasSize)
                                        .toDouble(),
                                    onChanged: _editor.busy
                                        ? null
                                        : (value) =>
                                              _editor.setCenter(value.round()),
                                  ),
                                  TextFormField(
                                    key: ValueKey(
                                      'center-${_editor.centerIndex}',
                                    ),
                                    initialValue: '${_editor.centerIndex}',
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Center index',
                                      helperText: 'Boundary between pixels; press Done to set.',
                                    ),
                                    onFieldSubmitted: (text) {
                                      final value = int.tryParse(text);
                                      if (value != null &&
                                          value >= 0 &&
                                          value <= _editor.canvasSize) {
                                        _editor.setCenter(value);
                                      }
                                    },
                                  ),
                                ] else
                                  Text('Center: ${_editor.resolvedCenter}'),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 18),
                      if (_advanced) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Outputs',
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            if (_advanced)
                              TextButton.icon(
                                onPressed: _editor.busy
                                    ? null
                                    : () => _showOutputs(context),
                                icon: const Icon(Icons.add),
                                label: const Text('Add output'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if ((_editor.snapshot?.outputs.length ?? 0) == 0)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Connect to the controller to discover its strips and modules.',
                              ),
                            ),
                          ),
                        ..._outputGroups(context),
                      ] else
                        ExpansionTile(
                          key: const ValueKey('all-outputs'),
                          title: const Text('All outputs'),
                          subtitle: const Text(
                            'View hardware and connection status',
                          ),
                          children: [
                            if ((_editor.snapshot?.outputs.length ?? 0) == 0)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'Connect to discover strips and modules.',
                                ),
                              ),
                            ..._outputGroups(context),
                          ],
                        ),
                      if ((_editor.snapshot?.pendingNodes ?? 0) > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'Waiting for output details from ${_editor.snapshot!.pendingNodes} nodes. Offline placements stay in the layout.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _banner(
    BuildContext context,
    IconData icon,
    String message, {
    Widget? action,
    bool error = false,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: error ? colors.errorContainer : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: error ? colors.onErrorContainer : colors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: error
                            ? colors.onErrorContainer
                            : colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              if (action != null)
                Align(alignment: Alignment.centerRight, child: action),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _outputGroups(BuildContext context, {bool picker = false}) {
    final nodes = <String, List<LayoutOutput>>{};
    for (final output in _editor.snapshot?.outputs ?? <LayoutOutput>[]) {
      (nodes[output.nodeMac.join(':')] ??= []).add(output);
    }
    return [
      for (final outputs in nodes.values) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
          child: Text(
            '${_sameMac(outputs.first.nodeMac, _editor.snapshot?.masterMac ?? []) ? 'Controller' : 'Node'} · ${_editor.nodeNames[macBytesToString(outputs.first.nodeMac)] ?? nodeSuffix(outputs.first.nodeMac)}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < outputs.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 56),
                _outputTile(context, outputs[i], picker: picker),
              ],
            ],
          ),
        ),
      ],
    ];
  }

  bool _sameMac(List<int> a, List<int> b) =>
      a.length == b.length &&
      List.generate(a.length, (i) => a[i] == b[i]).every((v) => v);
  Widget _outputTile(
    BuildContext context,
    LayoutOutput output, {
    bool picker = false,
  }) {
    final key = outputKey(output),
        placed = _editor.layout.any((row) => placementKey(row) == key);
    final canPlace =
        !placed &&
        output.known &&
        output.ready &&
        output.pixelCount > 0 &&
        !_editor.busy;
    final colors = Theme.of(context).colorScheme;
    var status = !output.known
        ? 'Waiting for device details'
        : !output.online
        ? 'Offline · cached'
        : output.ready
        ? 'Online'
        : 'Unavailable';
    if (placed && output.online && output.ready) {
      status = switch (_editor.deploymentFor(output.nodeMac)) {
        MatrixNodeStatus_State.READY => 'Online · layout synced',
        MatrixNodeStatus_State.PREPARING => 'Online · syncing layout',
        MatrixNodeStatus_State.DEGRADED => 'Online · delivery degraded',
        MatrixNodeStatus_State.UNAVAILABLE => 'Waiting for node',
        _ => status,
      };
    }
    final label = _editor.layout
        .where((row) => placementKey(row) == key)
        .firstOrNull;
    void activate() {
      if (placed) {
        _editor.select(key);
      } else if (canPlace) {
        _editor.place(output, afterKey: picker ? _editor.selectedKey : null);
      }
      if (picker && (placed || canPlace)) Navigator.of(context).pop();
    }

    return ListTile(
      key: ValueKey('output-$key'),
      leading: Icon(
        output.driverKind == MatrixDriverKind.LED_STRIP
            ? Icons.linear_scale
            : Icons.lightbulb_outline,
        color: output.online ? colors.primary : colors.onSurfaceVariant,
      ),
      title: Text(
        label == null ? _editor.outputTitle(output) : _editor.titleFor(label),
      ),
      subtitle: Text(
        '${output.known ? '${label == null ? output.pixelCount : _editor.lengthFor(label)} ${isPointSource(output) ? 'LED' : 'LEDs'} · ' : ''}$status',
      ),
      onTap: placed || canPlace ? activate : null,
      trailing: placed
          ? const Icon(Icons.check_circle_outline)
          : IconButton(
              tooltip: 'Place ${outputType(output)}',
              onPressed: canPlace ? activate : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
    );
  }

  Future<void> _showOutputs(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.65,
        child: ListenableBuilder(
          listenable: _editor,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            children: [
              Text(
                'Place an output',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                _editor.selected == null
                    ? 'Outputs are placed at the end of the canvas.'
                    : 'New outputs are placed after the selected output.',
              ),
              const SizedBox(height: 8),
              ..._outputGroups(sheetContext, picker: true),
            ],
          ),
        ),
      ),
    ),
  );
}
