import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';
import 'package:lumadrive_control/controllers/mesh_controller.dart';
import 'package:lumadrive_control/controllers/matrix_editor_controller.dart';
import 'package:lumadrive_control/controllers/layout_editor_controller.dart'
    show nodeSuffix, automaticLayoutCenter;
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/repositories/ble_repository.dart';
import 'package:lumadrive_control/repositories/matrix_editor_repository.dart';
import 'package:lumadrive_control/widgets/matrix/animation_editor.dart';
import 'package:lumadrive_control/widgets/matrix/matrix_entry_editor.dart';

enum MatrixEditorSection { table, animations }

class MatrixEditorPage extends ConsumerStatefulWidget {
  final String? controllerId;
  final MatrixEditorController? controller;
  const MatrixEditorPage({super.key, this.controllerId, this.controller});
  @override
  ConsumerState<MatrixEditorPage> createState() => _MatrixEditorPageState();
}

class _MatrixEditorPageState extends ConsumerState<MatrixEditorPage>
    with WidgetsBindingObserver {
  late final MatrixEditorController _editor;
  BleDevice? _owner;
  MatrixEditorSection _section = MatrixEditorSection.table;
  MatrixEffect? _animation;
  MatrixEntry? _entry;
  MatrixSource? _trigger;
  bool get _editing => _animation != null || _entry != null;
  bool _available() {
    if (!mounted) return false;
    final connection = ref.read(bleControllerProvider);
    return connection is BleConnected &&
        connection.device.remoteId == _owner?.remoteId;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.controller != null) {
      _editor = widget.controller!;
    } else {
      final device = ref.read(bleControllerProvider).device,
          id = widget.controllerId ?? device?.remoteId;
      if (id == null) {
        throw StateError('Matrix editor needs a controller identity');
      }
      _owner = BleDevice(
        remoteId: id,
        advName: device?.remoteId == id ? device!.advName : 'Controller',
      );
      _editor = MatrixEditorController(
        store: ref.read(matrixDraftStoreProvider(id)),
        repository: ConnectedMatrixEditorRepository(
          isAvailable: _available,
          readDocument: () =>
              ref.read(meshControllerProvider.notifier).readMatrix(),
          readActiveDocument: () =>
              ref.read(meshControllerProvider.notifier).readCurrentMatrix(),
          readStatus: () =>
              ref.read(meshControllerProvider.notifier).getMatrixStatus(),
          updateMatrix: (value) =>
              ref.read(meshControllerProvider.notifier).updateMatrix(value),
        ),
      );
    }
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

  void _closeForm() {
    if (_editor.applying) return;
    setState(() {
      _animation = null;
      _entry = null;
      _trigger = null;
      _editor.editing = false;
    });
    unawaited(_editor.refresh());
  }

  void _openAnimation(MatrixEffect? effect) => setState(() {
    _editor.editing = true;
    _animation = effect?.deepCopy() ?? newSimpleAnimation();
  });
  void _openEntry(MatrixEntry? entry) => setState(() {
    _editor.editing = true;
    _entry =
        entry?.deepCopy() ??
        MatrixEntry(
          effectId: _editor.config.effects.firstOrNull?.id ?? 0,
          priority:
              (_editor.config.entries.fold<int>(
                        0,
                        (max, e) => e.priority > max ? e.priority : max,
                      ) +
                      10)
                  .clamp(0, 255),
        );
    _trigger = entry == null
        ? MatrixSource(kind: MatrixSource_Kind.DEFAULT_STATE)
        : _editor.source(entry.sourceId)?.deepCopy() ??
              MatrixSource(kind: MatrixSource_Kind.DEFAULT_STATE);
  });
  Widget _message(String text, {Widget? action, bool error = false}) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: error ? colors.errorContainer : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: error ? colors.onErrorContainer : colors.onSurface,
              ),
            ),
            if (action != null)
              Align(alignment: Alignment.centerRight, child: action),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      builder: (context, _) => PopScope(
        canPop: !_editing,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && _editing) _closeForm();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              _animation != null
                  ? 'Edit animation'
                  : _entry != null
                  ? 'Edit table entry'
                  : 'Matrix & animations',
            ),
            leading: _editing
                ? IconButton(
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _editor.applying ? null : _closeForm,
                  )
                : null,
            actions: _editing
                ? null
                : [
                    IconButton(
                      tooltip: 'Refresh matrix',
                      icon: const Icon(Icons.refresh),
                      onPressed: _editor.applying
                          ? null
                          : () => _editor.refresh(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: FilledButton(
                        key: const ValueKey('apply-matrix'),
                        onPressed: _editor.canApply ? _editor.apply : null,
                        child: Text(_editor.applying ? 'Applying…' : 'Apply'),
                      ),
                    ),
                  ],
          ),
          body: _editor.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_editor.error != null)
                          _message(_editor.error!, error: true),
                        if (_editor.conflict)
                          _message(
                            'The matrix changed on the controller. Your local draft is kept.',
                            action: TextButton(
                              onPressed: _editing
                                  ? null
                                  : () => _editor.refresh(discardDraft: true),
                              child: const Text('Use saved matrix'),
                            ),
                          ),
                        if (!_editor.connected)
                          _message(
                            _editor.document == null
                                ? 'Controller disconnected. Connect to load its matrix before editing.'
                                : 'Controller disconnected. Your matrix draft is kept on this phone.',
                            action: TextButton(
                              onPressed: () {
                                if (widget.controller != null || _available()) {
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
                                widget.controller != null || _available()
                                    ? 'Retry'
                                    : 'Reconnect',
                              ),
                            ),
                          ),
                        if (_editor.notice != null) _message(_editor.notice!),
                      ],
                    ),
                    if (_editing && _animation != null)
                      AnimationEditor(
                        key: ValueKey('animation-form-${_animation!.id}'),
                        initial: _animation!,
                        layout: _editor.config.layout,
                        existingNames: _editor.config.effects
                            .where((effect) => effect.id != _animation!.id)
                            .map(animationTitle),
                        canvasSize: _editor.canvasSize,
                        centerIndex: _editor.config.hasCenterIndex()
                            ? _editor.config.centerIndex
                            : automaticLayoutCenter(_editor.config.layout),
                        onCancel: _closeForm,
                        failureMessage: () => _editor.error,
                        onSaveDraft: (value) {
                          final saved = _editor.saveEffect(value);
                          if (saved) _closeForm();
                          return saved;
                        },
                        onSave: (value) async {
                          final saved = await _editor.applyEffect(value);
                          if (mounted && saved) _closeForm();
                          return saved;
                        },
                      )
                    else if (_editing && _entry != null)
                      MatrixEntryEditor(
                        key: ValueKey('entry-form-${_entry!.id}'),
                        initial: _entry!,
                        trigger: _trigger!,
                        controller: _editor,
                        onCancel: _closeForm,
                        onSave: (value, trigger, effects, modeId, secondModeId, conditionOperator) {
                          final saved = _editor.saveEntry(
                            value,
                            trigger,
                            newEffects: effects,
                            modeId: modeId,
                            secondModeId: secondModeId,
                            conditionOperator: conditionOperator,
                          );
                          if (saved) _closeForm();
                          return saved;
                        },
                      )
                    else ...[
                      Text(
                        'Bring your lighting to life',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Match triggers to animations. Every animation uses the same car layout, with transparent colors revealing the layers below.',
                      ),
                      const SizedBox(height: 16),
                      if (_editor.document != null) _configurationState(),
                      if (_editor.dirty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Icon(Icons.edit_note),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Local draft · Apply sends it to the controller',
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_editor.validationError != null)
                        _message(_editor.validationError!, error: true),
                      if (_editor.applying)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: Column(
                            children: [
                              LinearProgressIndicator(
                                value: _editor.progress == 1
                                    ? null
                                    : _editor.progress,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Saving matrix and synchronizing nodes…',
                              ),
                            ],
                          ),
                        ),
                      SegmentedButton<MatrixEditorSection>(
                        segments: [
                          ButtonSegment(
                            value: MatrixEditorSection.table,
                            icon: const Icon(Icons.table_rows_outlined),
                            label: Text(
                              'Table (${_editor.config.entries.length})',
                            ),
                          ),
                          ButtonSegment(
                            value: MatrixEditorSection.animations,
                            icon: const Icon(Icons.animation),
                            label: Text(
                              'Animations (${_editor.config.effects.length})',
                            ),
                          ),
                        ],
                        selected: {_section},
                        onSelectionChanged: _editor.applying
                            ? null
                            : (value) => setState(() {
                                _section = value.single;
                              }),
                      ),
                      const SizedBox(height: 18),
                      if (_section == MatrixEditorSection.table)
                        ..._table()
                      else
                        ..._animations(),
                      const SizedBox(height: 18),
                      ..._deployment(),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
        ),
      ),
    );
  }

  List<Widget> _table() => [
    const Text(
      'Higher priority renders last. Entries with equal priority render in the order shown.',
    ),
    const SizedBox(height: 12),
    Align(
      alignment: Alignment.centerLeft,
      child: FilledButton.icon(
        key: const ValueKey('add-entry'),
        onPressed:
            _editor.document == null ||
                _editor.applying ||
                _editor.config.entries.length >= 32 ||
                _editor.config.layout.isEmpty
            ? null
            : () => _openEntry(null),
        icon: const Icon(Icons.add),
        label: const Text('Add entry'),
      ),
    ),
    if (_editor.config.layout.isEmpty)
      _message(
        'Set up the car layout before creating playback entries.',
        action: widget.controller != null
            ? null
            : TextButton(
                onPressed: () => context.go(
                  Uri(
                    path: '/device/layout',
                    queryParameters: {'controller': _owner!.remoteId},
                  ).toString(),
                ),
                child: const Text('Configure car layout'),
              ),
      ),
    if (_editor.config.effects.isEmpty)
      _message(
        'Add an entry and create its animation right there, or choose one from the library.',
      ),
    if (_editor.config.entries.isEmpty)
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No table entries yet')),
      ),
    for (var i = 0; i < _editor.config.entries.length; i++)
      _entryCard(_editor.config.entries[i], i),
  ];

  Widget _configurationState() {
    final document = _editor.document!;
    final current = _editor.currentDocument;
    final active = current == null
        ? null
        : MatrixConfig.fromBuffer(current.config);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MCU configuration',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              '${_editor.saved.factoryDefault ? 'Factory rainbow' : 'Configuration'} · revision ${document.revision}',
            ),
            Text(
              'Active revision ${current?.revision ?? document.activeRevision}${(current?.activationPending ?? document.activationPending) ? ' · activation pending' : ''}',
            ),
            if (!document.persisted)
              const Text('This configuration is not saved in flash.'),
            if (active != null)
              Text(
                'Read from MCU: ${active.entries.length} entries · ${active.effects.length} animations · ${active.layout.length} outputs',
              ),
            TextButton.icon(
              key: const ValueKey('read-current-matrix'),
              onPressed:
                  !_editor.connected ||
                      _editor.applying ||
                      _editor.refreshing ||
                      _editor.readingCurrent
                  ? null
                  : _editor.readCurrent,
              icon: const Icon(Icons.download_outlined),
              label: Text(
                _editor.readingCurrent ? 'Reading…' : 'Read current state',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _entryCard(MatrixEntry entry, int index) {
    final trigger = _editor.source(entry.sourceId),
        effect = _editor.effect(entry.effectId);
    final label = trigger?.kind == MatrixSource_Kind.GPIO_EDGE
        ? 'GPIO ${trigger!.gpio} · ${trigger.rising ? 'rising' : 'falling'} · ${nodeSuffix(trigger.nodeMac)}'
        : trigger?.kind == MatrixSource_Kind.ON_BOOT
        ? 'On boot'
        : trigger?.kind == MatrixSource_Kind.ON_MODE_SWITCHED
        ? 'On mode switched'
        : 'Default state';
    return Card(
      child: Column(
        children: [
          ListTile(
            key: ValueKey('matrix-entry-${entry.id}'),
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(entryTitle(entry)),
            subtitle: Text(
              '$label\n${effect == null ? 'Missing animation' : animationTitle(effect)} · priority ${entry.priority}',
            ),
            isThreeLine: true,
            onTap: _editor.applying ? null : () => _openEntry(entry),
            trailing: const Icon(Icons.chevron_right),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Move entry earlier',
                  onPressed: _editor.applying || index == 0
                      ? null
                      : () => _editor.moveEntry(index, -1),
                  icon: const Icon(Icons.arrow_upward, size: 20),
                ),
                IconButton(
                  tooltip: 'Move entry later',
                  onPressed:
                      _editor.applying ||
                          index == _editor.config.entries.length - 1
                      ? null
                      : () => _editor.moveEntry(index, 1),
                  icon: const Icon(Icons.arrow_downward, size: 20),
                ),
                IconButton(
                  tooltip: 'Remove entry',
                  onPressed: _editor.applying
                      ? null
                      : () => _editor.removeEntry(entry.id),
                  icon: const Icon(Icons.delete_outline, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _animations() => [
    Align(
      alignment: Alignment.centerLeft,
      child: FilledButton.icon(
        key: const ValueKey('add-animation'),
        onPressed:
            _editor.document == null ||
                _editor.applying ||
                _editor.config.effects.length >= 32
            ? null
            : () => _openAnimation(null),
        icon: const Icon(Icons.add),
        label: const Text('Add animation'),
      ),
    ),
    if (_editor.config.effects.isEmpty)
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('Create a color, blink, breathe or flowing gradient.'),
        ),
      ),
    for (final effect in _editor.config.effects)
      Card(
        child: Column(
          children: [
            ListTile(
              key: ValueKey('matrix-animation-${effect.id}'),
              leading: CircleAvatar(
                backgroundColor: Color.fromARGB(
                  255,
                  effect.red,
                  effect.green,
                  effect.blue,
                ),
                child: Icon(
                  Icons.animation,
                  color: effect.red + effect.green + effect.blue > 400
                      ? Colors.black
                      : Colors.white,
                ),
              ),
              title: Text(animationTitle(effect)),
              subtitle: Text(
                '${effectKindLabel(effect.kind)} · ${effect.durationMs == 0 ? 'indefinite' : '${effect.durationMs} ms'}',
              ),
              trailing: Icon(
                simpleEffectKinds.contains(effect.kind)
                    ? Icons.edit_outlined
                    : Icons.lock_outline,
              ),
              onTap:
                  _editor.applying || !simpleEffectKinds.contains(effect.kind)
                  ? null
                  : () => _openAnimation(effect),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _editor.applying
                      ? null
                      : () => _editor.duplicateEffect(effect.id),
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  label: const Text('Duplicate'),
                ),
                IconButton(
                  tooltip: 'Delete animation',
                  onPressed: _editor.applying
                      ? null
                      : () => _editor.deleteEffect(effect.id),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
  ];
  List<Widget> _deployment() {
    final status = _editor.deployment, document = _editor.document;
    if (!_editor.connected ||
        status == null ||
        document == null ||
        status.revision != document.revision ||
        status.masterSession != document.masterSession) {
      return [];
    }
    final relevant = [
      ..._editor.config.layout.map((row) => row.nodeMac),
      ..._editor.config.sources
          .where((s) => s.kind == MatrixSource_Kind.GPIO_EDGE)
          .map((s) => s.nodeMac),
    ];
    return [
      Text('Deployment', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          for (final node in status.nodes.where(
            (node) => relevant.any((mac) => listEquals(mac, node.nodeMac)),
          ))
            Chip(
              avatar: Icon(
                node.state == MatrixNodeStatus_State.READY
                    ? Icons.check_circle_outline
                    : Icons.sync,
                size: 18,
              ),
              label: Text(
                '${nodeSuffix(node.nodeMac)} · ${switch (node.state) {
                  MatrixNodeStatus_State.READY => 'Ready',
                  MatrixNodeStatus_State.PREPARING => 'Syncing',
                  MatrixNodeStatus_State.DEGRADED => 'Degraded',
                  _ => 'Offline',
                }}',
              ),
            ),
        ],
      ),
    ];
  }
}
