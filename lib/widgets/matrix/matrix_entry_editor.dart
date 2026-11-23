import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumadrive_control/controllers/matrix_editor_controller.dart';
import 'package:lumadrive_control/controllers/layout_editor_controller.dart'
    show nodeSuffix, automaticLayoutCenter;
import 'package:lumadrive_control/generated/mesh.pb.dart';

import 'animation_editor.dart';

class MatrixEntryEditor extends StatefulWidget {
  final MatrixEntry initial;
  final MatrixSource trigger;
  final MatrixEditorController controller;
  final bool Function(
    MatrixEntry,
    MatrixSource,
    List<MatrixEffect>,
    List<MatrixCondition>,
    int,
  )
  onSave;
  final VoidCallback onCancel;
  const MatrixEntryEditor({
    super.key,
    required this.initial,
    required this.trigger,
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });
  @override
  State<MatrixEntryEditor> createState() => _MatrixEntryEditorState();
}

class _MatrixEntryEditorState extends State<MatrixEntryEditor> {
  final _form = GlobalKey<FormState>();
  late MatrixEntry _entry;
  late MatrixSource _trigger;
  final List<MatrixEffect> _newEffects = [];
  MatrixEffect? _newAnimation;
  bool _automaticName = false;
  int _modeId = 0;
  static const _combinedValue = -4294967297;
  static const _gpioValue = -4294967298;
  final List<int> _combinedConditions = [0, 0];
  final List<MatrixCondition> _combinedGpios = [
    MatrixCondition(),
    MatrixCondition(),
  ];
  MatrixCondition _gpioCondition = MatrixCondition();
  int _conditionOperator = 0;
  bool _unsupportedCondition = false;
  late final TextEditingController _name, _priority;
  @override
  void initState() {
    super.initState();
    _entry = widget.initial.deepCopy();
    _trigger = widget.trigger.deepCopy();
    _name = TextEditingController(text: _entry.name);
    _priority = TextEditingController(text: '${_entry.priority}');
    final condition = widget.controller.config.conditions
        .where((c) => c.id == _entry.conditionId)
        .firstOrNull;
    int? leaf(MatrixCondition? c) => c?.kind == MatrixCondition_Kind.ALWAYS
        ? 0
        : c?.kind == MatrixCondition_Kind.NEVER
        ? neverConditionValue
        : c?.kind == MatrixCondition_Kind.GPIO_STATE
        ? _gpioValue
        : c?.kind == MatrixCondition_Kind.MODE
        ? (c!.inverted ? -c.modeId : c.modeId)
        : null;
    if (condition != null &&
        (condition.kind == MatrixCondition_Kind.AND ||
            condition.kind == MatrixCondition_Kind.OR)) {
      _conditionOperator = condition.kind == MatrixCondition_Kind.AND ? 1 : 2;
      _modeId = _combinedValue;
      _combinedConditions.clear();
      _combinedGpios.clear();
      final seen = <int>{};
      void collect(MatrixCondition? node) {
        if (node == null || !seen.add(node.id)) {
          _unsupportedCondition = true;
          return;
        }
        if (node.kind == condition.kind) {
          collect(
            widget.controller.config.conditions
                .where((c) => c.id == node.leftId)
                .firstOrNull,
          );
          collect(
            widget.controller.config.conditions
                .where((c) => c.id == node.rightId)
                .firstOrNull,
          );
        } else {
          final value = leaf(node);
          if (value == null) {
            _unsupportedCondition = true;
          } else {
            _combinedConditions.add(value);
            _combinedGpios.add(node.deepCopy());
          }
        }
        seen.remove(node.id);
      }

      collect(condition);
    } else if (condition != null) {
      final value = leaf(condition);
      if (value == null) {
        _unsupportedCondition = true;
      } else {
        _modeId = value;
        if (value == _gpioValue) _gpioCondition = condition.deepCopy();
      }
    }
    _automaticName = _entry.id == 0 && _entry.name.isEmpty;
    _updateName();
  }

  void _updateName() {
    if (!_automaticName) return;
    final effects = [...widget.controller.config.effects, ..._newEffects];
    final effect = effects.where((e) => e.id == _entry.effectId).firstOrNull;
    final trigger = switch (_trigger.kind) {
      MatrixSource_Kind.DEFAULT_STATE => 'Default state',
      MatrixSource_Kind.GPIO_EDGE => 'GPIO edge',
      MatrixSource_Kind.ON_BOOT => 'On boot',
      MatrixSource_Kind.ON_MODE_SWITCHED => 'Mode switched',
      _ => 'Trigger',
    };
    _name.text = uniqueSuggestedName(
      '${effect == null ? 'Animation' : animationTitle(effect)} · $trigger',
      widget.controller.config.entries.map(entryTitle),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _priority.dispose();
    super.dispose();
  }

  String _key(List<int> mac) => mac.join(':');
  List<MatrixInputNode> get _nodes {
    final nodes = (widget.controller.document?.nodes ?? <MatrixInputNode>[])
        .where((n) => n.known && n.gpios.isNotEmpty)
        .toList();
    if (_trigger.nodeMac.length == 6 &&
        !nodes.any((n) => listEquals(n.nodeMac, _trigger.nodeMac))) {
      final reported = widget.controller.document?.nodes
          .where((node) => listEquals(node.nodeMac, _trigger.nodeMac))
          .firstOrNull;
      nodes.add(reported ?? MatrixInputNode(nodeMac: _trigger.nodeMac));
    }
    return nodes;
  }

  void _gpioMode() {
    _trigger.kind = MatrixSource_Kind.GPIO_EDGE;
    final node = _nodes
        .where((node) => node.known && node.gpios.isNotEmpty)
        .firstOrNull;
    if (_trigger.nodeMac.isEmpty && node != null) {
      _trigger.nodeMac = node.nodeMac;
      _trigger.gpio = node.gpios.first;
    }
  }

  MatrixCondition _selection(int value, MatrixCondition gpio) {
    if (value == _gpioValue) {
      return gpio.deepCopy()..kind = MatrixCondition_Kind.GPIO_STATE;
    }
    return MatrixCondition(
      kind: value == neverConditionValue
          ? MatrixCondition_Kind.NEVER
          : value == 0
          ? MatrixCondition_Kind.ALWAYS
          : MatrixCondition_Kind.MODE,
      modeId: value == neverConditionValue ? 0 : value.abs(),
      inverted: value != neverConditionValue && value < 0,
    );
  }

  Widget _gpioConditionFields(MatrixCondition value, int index) {
    final nodes = _nodes.toList();
    if (value.nodeMac.length == 6 &&
        !nodes.any((n) => listEquals(n.nodeMac, value.nodeMac))) {
      nodes.add(
        widget.controller.document?.nodes
                .where((n) => listEquals(n.nodeMac, value.nodeMac))
                .firstOrNull ??
            MatrixInputNode(nodeMac: value.nodeMac),
      );
    }
    final node = nodes
        .where((n) => listEquals(n.nodeMac, value.nodeMac))
        .firstOrNull;
    final pins = (node?.gpios ?? <int>[]).toList();
    if (node != null && !pins.contains(value.gpio)) pins.add(value.gpio);
    return Column(
      children: [
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: ValueKey('condition-node-$index-${_key(value.nodeMac)}'),
          initialValue: node == null ? null : _key(node.nodeMac),
          decoration: const InputDecoration(
            labelText: 'Input node',
            border: OutlineInputBorder(),
          ),
          isExpanded: true,
          items: [
            for (final option in nodes)
              DropdownMenuItem(
                value: _key(option.nodeMac),
                child: Text(
                  '${listEquals(option.nodeMac, widget.controller.document?.masterMac) ? 'Controller' : 'Node'} · ${nodeSuffix(option.nodeMac)}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          validator: (v) =>
              v == null ? 'Choose a node with provisioned inputs' : null,
          onChanged: (v) => setState(() {
            final selected = nodes.firstWhere((n) => _key(n.nodeMac) == v);
            value.nodeMac = selected.nodeMac;
            if (selected.gpios.isNotEmpty) value.gpio = selected.gpios.first;
          }),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
          key: ValueKey(
            'condition-pin-$index-${_key(value.nodeMac)}-${value.gpio}',
          ),
          initialValue: pins.contains(value.gpio) ? value.gpio : null,
          decoration: const InputDecoration(
            labelText: 'GPIO input',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final pin in pins)
              DropdownMenuItem(
                value: pin,
                enabled: node?.known != true || node!.gpios.contains(pin),
                child: Text('GPIO $pin'),
              ),
          ],
          validator: (pin) => pin == null
              ? 'Choose a provisioned GPIO input'
              : node?.known == true && !node!.gpios.contains(pin)
              ? 'Pin is not provisioned on this node'
              : null,
          onChanged: node?.known != true
              ? null
              : (pin) => setState(() => value.gpio = pin!),
        ),
        const SizedBox(height: 12),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('High')),
            ButtonSegment(value: false, label: Text('Low')),
          ],
          selected: {value.high},
          onSelectionChanged: (v) => setState(() => value.high = v.first),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final nodes = _nodes;
    final node = nodes
        .where((n) => listEquals(n.nodeMac, _trigger.nodeMac))
        .firstOrNull;
    final pins = (node?.gpios ?? <int>[]).toList();
    if (node != null && !pins.contains(_trigger.gpio)) pins.add(_trigger.gpio);
    final effects = [...widget.controller.config.effects, ..._newEffects];
    return Form(
      key: _form,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.initial.id == 0 ? 'New table entry' : 'Edit table entry',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('entry-name'),
                controller: _name,
                onChanged: (_) => _automaticName = false,
                maxLength: 32,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              DropdownButtonFormField<int>(
                key: const ValueKey('entry-animation'),
                initialValue: effects.any((e) => e.id == _entry.effectId)
                    ? _entry.effectId
                    : null,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Animation',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final effect in effects)
                    DropdownMenuItem(
                      value: effect.id,
                      child: Text(
                        animationTitle(effect),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                validator: (id) => id == null ? 'Choose an animation' : null,
                onChanged: (id) => setState(() {
                  _entry.effectId = id!;
                  _updateName();
                }),
              ),
              const SizedBox(height: 16),
              if (_newAnimation == null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    key: const ValueKey('create-entry-animation'),
                    icon: const Icon(Icons.add),
                    label: const Text('Create animation'),
                    onPressed: effects.length >= 32
                        ? null
                        : () => setState(
                            () => _newAnimation = newSimpleAnimation(),
                          ),
                  ),
                ),
              if (_newAnimation != null) ...[
                AnimationEditor(
                  key: const ValueKey('entry-inline-animation'),
                  initial: _newAnimation!,
                  layout: widget.controller.config.layout,
                  existingNames: effects.map(animationTitle),
                  canvasSize: widget.controller.canvasSize,
                  centerIndex: widget.controller.config.hasCenterIndex()
                      ? widget.controller.config.centerIndex
                      : automaticLayoutCenter(widget.controller.config.layout),
                  saveLabel: 'Use animation',
                  previewCaption: 'Preview on this phone. Use animation selects it for this entry draft.',
                  onCancel: () => setState(() => _newAnimation = null),
                  onSave: (value) {
                    final used = {
                      ...effects.map((effect) => effect.id),
                      ...widget.controller.saved.effects.map(
                        (effect) => effect.id,
                      ),
                    };
                    var id = 1;
                    while (used.contains(id)) {
                      id++;
                    }
                    setState(() {
                      _newEffects.add(value.deepCopy()..id = id);
                      _entry.effectId = id;
                      _newAnimation = null;
                      _updateName();
                    });
                    return true;
                  },
                ),
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<MatrixSource_Kind>(
                key: const ValueKey('entry-trigger'),
                initialValue: _trigger.kind,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Trigger',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: MatrixSource_Kind.DEFAULT_STATE,
                    child: Text('Default state'),
                  ),
                  DropdownMenuItem(
                    value: MatrixSource_Kind.GPIO_EDGE,
                    child: Text('GPIO edge'),
                  ),
                  DropdownMenuItem(
                    value: MatrixSource_Kind.ON_BOOT,
                    child: Text('On boot'),
                  ),
                  DropdownMenuItem(
                    value: MatrixSource_Kind.ON_MODE_SWITCHED,
                    child: Text('On mode switched'),
                  ),
                ],
                onChanged: (kind) => setState(() {
                  if (kind == MatrixSource_Kind.GPIO_EDGE) {
                    _gpioMode();
                  } else {
                    _trigger
                      ..kind = kind!
                      ..clearNodeMac()
                      ..gpio = 0
                      ..rising = false;
                  }
                  if (kind == MatrixSource_Kind.DEFAULT_STATE) {
                    _entry.opaqueBackground = false;
                  }
                  _updateName();
                }),
              ),
              SwitchListTile(
                key: const ValueKey('entry-transparency'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Transparent background'),
                subtitle: Text(
                  _trigger.kind == MatrixSource_Kind.DEFAULT_STATE
                      ? 'Default-state entries always have a transparent background.'
                      : 'When off, lower-priority lighting is blacked out while this entry plays.',
                ),
                value:
                    _trigger.kind == MatrixSource_Kind.DEFAULT_STATE ||
                    !_entry.opaqueBackground,
                onChanged: _trigger.kind == MatrixSource_Kind.DEFAULT_STATE
                    ? null
                    : (value) =>
                          setState(() => _entry.opaqueBackground = !value),
              ),
              if (_trigger.kind == MatrixSource_Kind.DEFAULT_STATE)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Starts with the configuration. A finite animation restarts when it ends.',
                  ),
                ),
              if (_trigger.kind == MatrixSource_Kind.ON_BOOT)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Runs once when the saved matrix starts after a controller reboot. Finite effects do not repeat; saving a configuration does not replay it.',
                  ),
                ),
              if (_trigger.kind == MatrixSource_Kind.GPIO_EDGE) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  key: ValueKey('entry-node-${_key(_trigger.nodeMac)}'),
                  initialValue: node == null ? null : _key(node.nodeMac),
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Input node',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final option in nodes)
                      DropdownMenuItem(
                        value: _key(option.nodeMac),
                        child: Text(
                          '${listEquals(option.nodeMac, widget.controller.document?.masterMac) ? 'Controller' : 'Node'} · ${nodeSuffix(option.nodeMac)}${!option.known
                              ? ' · unknown'
                              : !option.online
                              ? ' · cached'
                              : ''}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  validator: (value) => value == null
                      ? 'Connect a node to discover its provisioned inputs'
                      : null,
                  onChanged: (value) => setState(() {
                    final selected = nodes.firstWhere(
                      (n) => _key(n.nodeMac) == value,
                    );
                    _trigger.nodeMac = selected.nodeMac;
                    if (selected.gpios.isNotEmpty) {
                      _trigger.gpio = selected.gpios.first;
                    }
                  }),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  key: ValueKey(
                    'entry-pin-${_key(_trigger.nodeMac)}-${_trigger.gpio}',
                  ),
                  initialValue: pins.contains(_trigger.gpio)
                      ? _trigger.gpio
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'GPIO input',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final pin in pins)
                      DropdownMenuItem(
                        value: pin,
                        enabled:
                            node?.known != true || node!.gpios.contains(pin),
                        child: Text(
                          'GPIO $pin${node?.known == true && !node!.gpios.contains(pin) ? ' · not provisioned' : ''}',
                        ),
                      ),
                  ],
                  validator: (pin) => pin == null
                      ? 'Choose a provisioned GPIO input'
                      : node?.known == true && !node!.gpios.contains(pin)
                      ? 'Pin is not provisioned on this node'
                      : null,
                  onChanged: node?.known != true
                      ? null
                      : (pin) => setState(() {
                          _trigger.gpio = pin!;
                        }),
                ),
                const SizedBox(height: 12),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      label: Text('Rising edge'),
                      icon: Icon(Icons.north),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text('Falling edge'),
                      icon: Icon(Icons.south),
                    ),
                  ],
                  selected: {_trigger.rising},
                  onSelectionChanged: (value) => setState(() {
                    _trigger.rising = value.single;
                  }),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Each matching edge restarts the animation. Inputs use external biasing; internal pulls are disabled.',
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('entry-priority'),
                controller: _priority,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => unsignedNumber(value, max: 255),
                decoration: const InputDecoration(
                  labelText: 'Priority (0–255)',
                  helperText: 'Higher priorities render last. Equal priorities use table order.',
                  helperMaxLines: 3,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                key: const ValueKey('entry-mode'),
                initialValue: _modeId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Condition',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: 0, child: Text('Always')),
                  const DropdownMenuItem(
                    value: neverConditionValue,
                    child: Text('Never (disabled)'),
                  ),
                  const DropdownMenuItem(
                    value: _combinedValue,
                    child: Text('Combined'),
                  ),
                  const DropdownMenuItem(
                    value: _gpioValue,
                    child: Text('GPIO state'),
                  ),
                  for (final mode in widget.controller.config.modes)
                    DropdownMenuItem(
                      value: mode.id,
                      child: Text('Mode: ${mode.name}'),
                    ),
                  for (final mode in widget.controller.config.modes)
                    DropdownMenuItem(
                      value: -mode.id,
                      child: Text('Not in mode: ${mode.name}'),
                    ),
                ],
                onChanged: (value) => setState(() {
                  _modeId = value ?? 0;
                  _conditionOperator = _modeId == _combinedValue
                      ? (_conditionOperator == 0 ? 1 : _conditionOperator)
                      : 0;
                  _unsupportedCondition = false;
                }),
              ),
              if (_modeId == _gpioValue)
                _gpioConditionFields(_gpioCondition, -1),
              if (_modeId == _combinedValue) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  key: const ValueKey('entry-condition-operator'),
                  initialValue: _conditionOperator,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Match conditions',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('All (AND)')),
                    DropdownMenuItem(value: 2, child: Text('Any (OR)')),
                  ],
                  onChanged: (value) =>
                      setState(() => _conditionOperator = value ?? 0),
                ),
                for (var i = 0; i < _combinedConditions.length; i++) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          key: ValueKey(
                            'entry-condition-$i-${_combinedConditions[i]}',
                          ),
                          initialValue: _combinedConditions[i],
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Condition ${i + 1}',
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 0,
                              child: Text('Always'),
                            ),
                            const DropdownMenuItem(
                              value: neverConditionValue,
                              child: Text('Never (disabled)'),
                            ),
                            const DropdownMenuItem(
                              value: _gpioValue,
                              child: Text('GPIO state'),
                            ),
                            for (final mode in widget.controller.config.modes)
                              DropdownMenuItem(
                                value: mode.id,
                                child: Text('Mode: ${mode.name}'),
                              ),
                            for (final mode in widget.controller.config.modes)
                              DropdownMenuItem(
                                value: -mode.id,
                                child: Text('Not in mode: ${mode.name}'),
                              ),
                          ],
                          onChanged: (value) => setState(
                            () => _combinedConditions[i] = value ?? 0,
                          ),
                        ),
                      ),
                      if (_combinedConditions.length > 2)
                        IconButton(
                          tooltip: 'Remove condition',
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => setState(() {
                            _combinedConditions.removeAt(i);
                            _combinedGpios.removeAt(i);
                          }),
                        ),
                    ],
                  ),
                  if (_combinedConditions[i] == _gpioValue)
                    _gpioConditionFields(_combinedGpios[i], i),
                ],
                TextButton.icon(
                  onPressed: () => setState(() {
                    _combinedConditions.add(0);
                    _combinedGpios.add(MatrixCondition());
                  }),
                  icon: const Icon(Icons.add),
                  label: const Text('Add condition'),
                ),
              ],
              if (_unsupportedCondition)
                const Text('This nested condition cannot be edited here.'),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 12,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    key: const ValueKey('save-entry'),
                    onPressed: _newAnimation != null || _unsupportedCondition
                        ? null
                        : () {
                            if (_form.currentState!.validate()) {
                              widget.onSave(
                                _entry.deepCopy()
                                  ..name = _name.text.trim()
                                  ..priority = int.parse(_priority.text),
                                _trigger,
                                _newEffects
                                    .where(
                                      (effect) => effect.id == _entry.effectId,
                                    )
                                    .toList(),
                                _modeId == _combinedValue
                                    ? [
                                        for (
                                          var i = 0;
                                          i < _combinedConditions.length;
                                          i++
                                        )
                                          _selection(
                                            _combinedConditions[i],
                                            _combinedGpios[i],
                                          ),
                                      ]
                                    : [_selection(_modeId, _gpioCondition)],
                                _conditionOperator,
                              );
                            }
                          },
                    child: const Text('Save entry'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
