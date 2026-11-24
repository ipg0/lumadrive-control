import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumadrive_control/controllers/matrix_editor_controller.dart';
import 'package:lumadrive_control/controllers/layout_editor_controller.dart'
    show defaultOutputName, outputKey, placementKey;
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/utils/gradient_palette.dart';
import 'package:lumadrive_control/utils/stringify_mac.dart';

import 'simple_animation_preview.dart';
import 'keyframe_editor.dart';
import 'signal_editor_dialog.dart';

String? unsignedNumber(String? value, {int min = 0, int max = 0xffffffff}) {
  final number = int.tryParse(value ?? '');
  return number == null || number < min || number > max
      ? 'Enter $min–$max'
      : null;
}

class AnimationEditor extends StatefulWidget {
  final MatrixEffect initial;
  final int canvasSize;
  final int? centerIndex;
  final FutureOr<bool> Function(MatrixEffect) onSave;
  final Future<int?> Function(MatrixEffect)? onPreview;
  final VoidCallback onCancel;
  final String saveLabel, previewCaption;
  final String? Function()? failureMessage;
  final bool Function(MatrixEffect)? onSaveDraft;
  final Iterable<String> existingNames;
  final List<MatrixLayout> layout;
  final List<LayoutOutput> outputCatalog;
  final Map<String, String> nodeNames;
  final List<SignalGenerator> signals;
  final int Function()? nextSignalId;
  final void Function(SignalGenerator)? onSignalSave;
  const AnimationEditor({
    super.key,
    required this.initial,
    required this.canvasSize,
    this.centerIndex,
    required this.onSave,
    this.onPreview,
    required this.onCancel,
    this.saveLabel = 'Apply animation',
    this.previewCaption =
        'Preview on this phone. Apply animation saves it to the controller.',
    this.failureMessage,
    this.onSaveDraft,
    this.existingNames = const [],
    this.layout = const [],
    this.outputCatalog = const [],
    this.nodeNames = const {},
    this.signals = const [],
    this.nextSignalId,
    this.onSignalSave,
  });
  @override
  State<AnimationEditor> createState() => _AnimationEditorState();
}

class _AnimationEditorState extends State<AnimationEditor> {
  final _form = GlobalKey<FormState>();
  late MatrixEffect _effect;
  late List<MatrixColor> _gradient;
  late List<int> _gradientIds;
  int _nextGradientId = 0;
  bool _saving = false;
  bool _automaticName = false;
  late bool _breatheColors;
  late bool _modulated;
  late int _signalId;
  late AnimationModulation_Curve _mappingCurve;
  String? _saveError;
  late final TextEditingController _name,
      _duration,
      _period,
      _duty,
      _wavelength,
      _regionStart,
      _regionEnd;
  late final TextEditingController _signalMin, _signalMax;
  @override
  void initState() {
    super.initState();
    _effect = widget.initial.deepCopy();
    _modulated = _effect.hasModulation();
    _signalId = _modulated ? _effect.modulation.signalId : 0;
    _mappingCurve = _modulated
        ? _effect.modulation.curve
        : AnimationModulation_Curve.LINEAR;
    _signalMin = TextEditingController(
      text: _modulated ? '${_effect.modulation.minimum}' : '0',
    );
    _signalMax = TextEditingController(
      text: _modulated ? '${_effect.modulation.maximum}' : '1',
    );
    _breatheColors =
        _effect.kind == MatrixEffect_Kind.BREATHE &&
        _effect.gradientColors.isNotEmpty;
    _gradient = gradientPalette(_effect)
        .map((color) => color.deepCopy())
        .toList();
    _gradientIds = [
      for (var i = 0; i < _gradient.length; i++) _nextGradientId++,
    ];
    _name = TextEditingController(text: _effect.name);
    if (_effect.id == 0 && _effect.name.isEmpty) {
      _automaticName = true;
      _name.text = uniqueSuggestedName(
        effectKindLabel(_effect.kind),
        widget.existingNames,
      );
    }
    _duration = TextEditingController(text: '${_effect.durationMs}');
    _period = TextEditingController(
      text: '${_effect.periodMs == 0 ? 1000 : _effect.periodMs}',
    );
    _duty = TextEditingController(
      text: '${_effect.dutyPercent == 0 ? 50 : _effect.dutyPercent}',
    );
    _wavelength = TextEditingController(text: '${_effect.wavelengthPixels}');
    _regionStart = TextEditingController(
      text: _effect.hasRegionStart() ? '${_effect.regionStart}' : '',
    );
    _regionEnd = TextEditingController(
      text: _effect.hasRegionEnd() ? '${_effect.regionEnd}' : '',
    );
  }

  @override
  void dispose() {
    for (final field in [
      _name,
      _duration,
      _period,
      _duty,
      _wavelength,
      _regionStart,
      _regionEnd,
      _signalMin,
      _signalMax,
    ]) {
      field.dispose();
    }
    super.dispose();
  }

  MatrixEffect _value() {
    final value = _effect.deepCopy()
      ..name = _name.text.trim()
      ..durationMs = int.tryParse(_duration.text) ?? 0
      ..periodMs =
          _effect.kind == MatrixEffect_Kind.STATIC_COLOR ||
              _effect.kind == MatrixEffect_Kind.DIMMING
          ? 0
          : _effect.kind == MatrixEffect_Kind.FILL && !_effect.loop
          ? int.tryParse(_duration.text) ?? 0
          : int.tryParse(_period.text) ?? 1000
      ..dutyPercent = _effect.kind == MatrixEffect_Kind.BLINK
          ? int.tryParse(_duty.text) ?? 50
          : 0
      ..wavelengthPixels =
          (_effect.kind == MatrixEffect_Kind.FLOWING_GRADIENT ||
              _effect.kind == MatrixEffect_Kind.RAINBOW)
          ? int.tryParse(_wavelength.text) ?? 0
          : 0;
    if (_modulated) {
      value.modulation = AnimationModulation(
        signalId: _signalId,
        minimum: double.tryParse(_signalMin.text) ?? 0,
        maximum: double.tryParse(_signalMax.text) ?? 1,
        curve: _mappingCurve,
      );
    } else {
      value.clearModulation();
    }
    if (value.kind == MatrixEffect_Kind.KEYFRAMES ||
        _regionStart.text.trim().isEmpty) {
      value.clearRegionStart();
    } else {
      value.regionStart = int.tryParse(_regionStart.text) ?? 0;
    }
    if (value.kind == MatrixEffect_Kind.KEYFRAMES ||
        _regionEnd.text.trim().isEmpty) {
      value.clearRegionEnd();
    } else {
      value.regionEnd = int.tryParse(_regionEnd.text) ?? 0;
    }
    value.gradientColors.clear();
    if (value.kind == MatrixEffect_Kind.DIMMING) {
      value
        ..red = 0
        ..green = 0
        ..blue = 0;
    }
    if (value.kind != MatrixEffect_Kind.KEYFRAMES) value.keyframes.clear();
    if (value.kind == MatrixEffect_Kind.FLOWING_GRADIENT ||
        (value.kind == MatrixEffect_Kind.BREATHE && _breatheColors)) {
      value.gradientColors.addAll(_gradient.map((color) => color.deepCopy()));
      final first = _gradient.first;
      value
        ..red = first.red
        ..green = first.green
        ..blue = first.blue
        ..alpha = first.alpha;
      if (value.kind == MatrixEffect_Kind.FLOWING_GRADIENT) {
        value.secondaryColor = _gradient[1].deepCopy();
      }
    }
    return value;
  }

  void _moveColor(int index, int delta) => setState(() {
    final color = _gradient.removeAt(index), id = _gradientIds.removeAt(index);
    _gradient.insert(index + delta, color);
    _gradientIds.insert(index + delta, id);
  });

  Future<void> _editSignal([SignalGenerator? existing]) async {
    if (widget.onSignalSave == null || widget.nextSignalId == null) return;
    final initial =
        existing?.deepCopy() ??
        SignalGenerator(
          id: widget.nextSignalId!(),
          name: 'Signal ${widget.nextSignalId!()}',
          kind: SignalGenerator_Kind.SINE,
          periodMs: 1000,
          amplitude: 1,
          offset: 0,
          phase: 0,
        );
    final result = await showDialog<SignalGenerator>(
      context: context,
      builder: (_) => SignalEditorDialog(signal: initial),
    );
    if (result == null || !mounted) return;
    widget.onSignalSave!(result);
    setState(() => _signalId = result.id);
  }

  Widget _regionField(bool start) {
    final field = start ? _regionStart : _regionEnd;
    final max = widget.canvasSize > 0 ? widget.canvasSize : 65536;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: ValueKey(
            start ? 'animation-region-start' : 'animation-region-end',
          ),
          controller: field,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: start ? 'From index' : 'To index',
            hintText: start ? 'Beginning of layout' : 'End of layout',
            helperText: start
                ? 'Inclusive; leave blank for the beginning'
                : 'Exclusive; leave blank for the end',
            border: const OutlineInputBorder(),
          ),
          validator: (text) {
            if (text == null || text.isEmpty) return null;
            final number = int.tryParse(text);
            if (number == null ||
                number < (start ? 0 : 1) ||
                number > max ||
                (start && number == max)) {
              return 'Enter a boundary within the layout';
            }
            final other = int.tryParse(
              (start ? _regionEnd : _regionStart).text,
            );
            if (other != null && (start ? number >= other : number <= other)) {
              return 'From must be before To';
            }
            return null;
          },
          onChanged: (_) => setState(() {}),
        ),
        if (widget.layout.isNotEmpty)
          DropdownButton<int>(
            key: ValueKey(
              start
                  ? 'animation-region-from-source'
                  : 'animation-region-to-source',
            ),
            isExpanded: true,
            hint: Text(
              start
                  ? 'Choose starting light source'
                  : 'Choose ending light source',
            ),
            items: [
              for (var i = 0; i < widget.layout.length; i++)
                DropdownMenuItem(
                  value: i,
                  child: Text(
                    _layoutSourceName(widget.layout[i]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (index) {
              if (index == null) return;
              final row = widget.layout[index];
              setState(
                () => field.text =
                    '${start ? (row.from < row.to ? row.from : row.to) : (row.from > row.to ? row.from : row.to)}',
              );
            },
          ),
      ],
    );
  }

  String _layoutSourceName(MatrixLayout row) => row.name.isNotEmpty
      ? row.name
      : defaultOutputName(
          widget.outputCatalog
                  .where((output) => outputKey(output) == placementKey(row))
                  .firstOrNull ??
              LayoutOutput(
                nodeMac: row.nodeMac,
                driver: row.driver,
                sourceIndex: row.sourceIndex,
              ),
          nodeName: widget.nodeNames[macBytesToString(row.nodeMac)],
        );

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    final validation = validateKeyframes(_value());
    if (validation != null) {
      setState(() => _saveError = validation);
      return;
    }
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      final saved = await widget.onSave(_value());
      if (mounted && !saved) {
        setState(
          () => _saveError =
              widget.failureMessage?.call() ??
              'Could not save this animation. Try again.',
        );
      }
    } catch (error) {
      if (mounted) setState(() => _saveError = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _number(
    String label,
    String key,
    TextEditingController field, {
    String? helper,
    int min = 0,
    bool period = false,
    int max = 0xffffffff,
  }) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: TextFormField(
      key: ValueKey(key),
      controller: field,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        helperMaxLines: 3,
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          unsignedNumber(value, min: min, max: max) ??
          (period && int.tryParse(value ?? '') == 1
              ? 'Use at least 2 ms'
              : null),
      onChanged: (_) => setState(() {}),
    ),
  );
  @override
  Widget build(BuildContext context) => Form(
    key: _form,
    child: IgnorePointer(
      ignoring: _saving,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.initial.id == 0 ? 'New animation' : 'Edit animation',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (_saving) const LinearProgressIndicator(),
              if (_saveError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _saveError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              TextFormField(
                key: const ValueKey('animation-name'),
                controller: _name,
                onChanged: (_) => _automaticName = false,
                maxLength: 32,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              DropdownButtonFormField<MatrixEffect_Kind>(
                key: const ValueKey('animation-kind'),
                initialValue: _effect.kind,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Animation type',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final kind in simpleEffectKinds)
                    DropdownMenuItem(
                      value: kind,
                      child: Text(
                        effectKindLabel(kind),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (kind) => setState(() {
                  if (kind == MatrixEffect_Kind.DIMMING &&
                      _effect.kind != kind) {
                    _effect.alpha = 128;
                  }
                  _effect.kind = kind!;
                  if (kind == MatrixEffect_Kind.KEYFRAMES &&
                      _effect.keyframes.isEmpty) {
                    _effect.keyframes.addAll(
                      defaultKeyframes(widget.canvasSize),
                    );
                    _effect.loop = false;
                  }
                  if (_automaticName) {
                    _name.text = uniqueSuggestedName(
                      effectKindLabel(kind),
                      widget.existingNames,
                    );
                  }
                  if (kind == MatrixEffect_Kind.FILL && _duration.text == '0') {
                    _duration.text = '1000';
                  }
                  if (kind == MatrixEffect_Kind.FLOWING_GRADIENT &&
                      !_effect.hasSecondaryColor()) {
                    _effect.secondaryColor = MatrixColor(blue: 255, alpha: 255);
                  }
                }),
              ),
              const SizedBox(height: 18),
              if (_effect.kind != MatrixEffect_Kind.KEYFRAMES) ...[
                Text(
                  'Animation region',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                const Text('Leave both blank to animate the entire layout.'),
                const SizedBox(height: 12),
                _regionField(true),
                const SizedBox(height: 12),
                _regionField(false),
                const SizedBox(height: 18),
              ],
              SwitchListTile(
                key: const ValueKey('animation-modulated'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Modulate animation'),
                subtitle: const Text(
                  'A signal controls the animation position; playback stays active.',
                ),
                value: _modulated,
                onChanged: (v) => setState(() => _modulated = v),
              ),
              if (_modulated) ...[
                DropdownButtonFormField<int>(
                  key: ValueKey('modulation-signal-$_signalId'),
                  initialValue: widget.signals.any((s) => s.id == _signalId)
                      ? _signalId
                      : null,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Signal',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final signal in widget.signals)
                      DropdownMenuItem(
                        value: signal.id,
                        child: Text(signal.name),
                      ),
                  ],
                  onChanged: (v) => setState(() => _signalId = v ?? 0),
                  validator: (v) => v == null ? 'Choose a signal' : null,
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: widget.onSignalSave == null
                          ? null
                          : () => _editSignal(),
                      icon: const Icon(Icons.add),
                      label: const Text('New generator'),
                    ),
                    if (widget.signals.any(
                      (s) =>
                          s.id == _signalId &&
                          s.kind != SignalGenerator_Kind.SENSOR,
                    ))
                      TextButton(
                        onPressed: () => _editSignal(
                          widget.signals.firstWhere((s) => s.id == _signalId),
                        ),
                        child: const Text('Edit generator'),
                      ),
                  ],
                ),
                for (final field in [
                  (_signalMin, 'Input minimum'),
                  (_signalMax, 'Input maximum'),
                ])
                  TextFormField(
                    controller: field.$1,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: field.$2,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (text) {
                      final number = double.tryParse(text ?? ''),
                          min = double.tryParse(_signalMin.text),
                          max = double.tryParse(_signalMax.text);
                      if (number == null || !number.isFinite) {
                        return 'Enter a finite number';
                      }
                      if (min != null && max != null && min >= max) {
                        return 'Minimum must be less than maximum';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 12),
                DropdownButtonFormField<AnimationModulation_Curve>(
                  initialValue: _mappingCurve,
                  decoration: const InputDecoration(
                    labelText: 'Mapping curve',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: AnimationModulation_Curve.LINEAR,
                      child: Text('Linear'),
                    ),
                    DropdownMenuItem(
                      value: AnimationModulation_Curve.EASE_IN,
                      child: Text('Ease in'),
                    ),
                    DropdownMenuItem(
                      value: AnimationModulation_Curve.EASE_OUT,
                      child: Text('Ease out'),
                    ),
                    DropdownMenuItem(
                      value: AnimationModulation_Curve.SMOOTH,
                      child: Text('Smooth'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _mappingCurve = v!),
                ),
                if (_effect.kind == MatrixEffect_Kind.STATIC_COLOR ||
                    _effect.kind == MatrixEffect_Kind.DIMMING)
                  const Text(
                    'This animation has no changing frames, so modulation will not change its appearance.',
                  ),
                const SizedBox(height: 18),
              ],
              if (_effect.kind == MatrixEffect_Kind.BREATHE)
                SwitchListTile(
                  key: const ValueKey('breathe-cycle-colors'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Cycle colors'),
                  subtitle: const Text(
                    'Blend through multiple colors instead of fading one color.',
                  ),
                  value: _breatheColors,
                  onChanged: (value) => setState(() => _breatheColors = value),
                ),
              if (_effect.kind == MatrixEffect_Kind.DIMMING) ...[
                const Text(
                  'Dim lower-priority lighting across the layout. Use a transparent entry background to show the lighting underneath.',
                ),
                Row(
                  children: [
                    const Text('Dim by'),
                    Expanded(
                      child: Slider(
                        key: const ValueKey('animation-dim-amount'),
                        max: 100,
                        divisions: 100,
                        value: (_effect.alpha * 100 / 255).roundToDouble(),
                        onChanged: (value) => setState(
                          () => _effect.alpha = (value * 255 / 100).round(),
                        ),
                      ),
                    ),
                    Text('${(_effect.alpha * 100 / 255).round()}%'),
                  ],
                ),
              ] else if (_effect.kind == MatrixEffect_Kind.RAINBOW) ...[
                const Text('Rainbow uses the full color spectrum.'),
                Row(
                  children: [
                    const Text('Opacity'),
                    Expanded(
                      child: Slider(
                        max: 255,
                        value: _effect.alpha.toDouble(),
                        onChanged: (value) => setState(() {
                          _effect.alpha = value.round();
                        }),
                      ),
                    ),
                    Text('${(_effect.alpha * 100 / 255).round()}%'),
                  ],
                ),
              ] else if (_effect.kind != MatrixEffect_Kind.FLOWING_GRADIENT &&
                  !(_effect.kind == MatrixEffect_Kind.BREATHE &&
                      _breatheColors) &&
                  _effect.kind != MatrixEffect_Kind.KEYFRAMES)
                MatrixColorEditor(
                  key: const ValueKey('primary-color'),
                  label: 'Primary color',
                  color: MatrixColor(
                    red: _effect.red,
                    green: _effect.green,
                    blue: _effect.blue,
                    alpha: _effect.alpha,
                  ),
                  onChanged: (value) => setState(() {
                    _effect
                      ..red = value.red
                      ..green = value.green
                      ..blue = value.blue
                      ..alpha = value.alpha;
                    _gradient[0] = value.deepCopy();
                  }),
                ),
              if (_effect.kind == MatrixEffect_Kind.FLOWING_GRADIENT ||
                  (_effect.kind == MatrixEffect_Kind.BREATHE &&
                      _breatheColors)) ...[
                Text(
                  '${_effect.kind == MatrixEffect_Kind.BREATHE ? 'Cycle' : 'Gradient'} colors · ${_gradient.length}/$maxGradientColors',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  _effect.kind == MatrixEffect_Kind.BREATHE
                      ? 'Colors blend smoothly in order, from the last back to the first.'
                      : 'Colors are evenly spaced and flow in this order, wrapping from the last back to the first.',
                ),
                for (var i = 0; i < _gradient.length; i++)
                  Padding(
                    key: ValueKey('gradient-stop-${_gradientIds[i]}'),
                    padding: const EdgeInsets.only(top: 14),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              tooltip: 'Move color ${i + 1} earlier',
                              onPressed: i == 0
                                  ? null
                                  : () => _moveColor(i, -1),
                              icon: const Icon(Icons.arrow_upward),
                            ),
                            IconButton(
                              tooltip: 'Move color ${i + 1} later',
                              onPressed: i + 1 == _gradient.length
                                  ? null
                                  : () => _moveColor(i, 1),
                              icon: const Icon(Icons.arrow_downward),
                            ),
                            IconButton(
                              tooltip: 'Remove color ${i + 1}',
                              onPressed: _gradient.length <= 2
                                  ? null
                                  : () => setState(() {
                                      _gradient.removeAt(i);
                                      _gradientIds.removeAt(i);
                                    }),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                        MatrixColorEditor(
                          label: 'Color ${i + 1}',
                          color: _gradient[i],
                          onChanged: (color) =>
                              setState(() => _gradient[i] = color),
                        ),
                      ],
                    ),
                  ),
                TextButton.icon(
                  key: const ValueKey('add-gradient-color'),
                  onPressed: _gradient.length >= maxGradientColors
                      ? null
                      : () => setState(() {
                          _gradient.add(MatrixColor(green: 255, alpha: 255));
                          _gradientIds.add(_nextGradientId++);
                        }),
                  icon: const Icon(Icons.add),
                  label: const Text('Add color'),
                ),
              ],
              if (_effect.kind == MatrixEffect_Kind.FILL)
                SwitchListTile(
                  key: const ValueKey('fill-once'),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fill once'),
                  subtitle: const Text(
                    'Fill the entire layout over the animation duration.',
                  ),
                  value: !_effect.loop,
                  onChanged: (value) => setState(() {
                    _effect.loop = !value;
                    if (value && (int.tryParse(_duration.text) ?? 0) < 2) {
                      _duration.text = '1000';
                    }
                  }),
                ),
              _number(
                'Duration (ms)',
                'animation-duration',
                _duration,
                min: _effect.kind == MatrixEffect_Kind.FILL && !_effect.loop
                    ? 2
                    : 0,
                helper: _effect.kind == MatrixEffect_Kind.FILL && !_effect.loop
                    ? 'The fill reaches the end at this time; speed adjusts to the layout length.'
                    : '0 holds indefinitely. Finite default-state animations restart after ending.',
              ),
              if (_effect.kind != MatrixEffect_Kind.STATIC_COLOR &&
                  _effect.kind != MatrixEffect_Kind.DIMMING &&
                  _effect.kind != MatrixEffect_Kind.KEYFRAMES &&
                  !(_effect.kind == MatrixEffect_Kind.FILL && !_effect.loop))
                _number(
                  'Period (ms)',
                  'animation-period',
                  _period,
                  period: true,
                  helper: 'Time for one full cycle; 0 uses 1,000 ms.',
                ),
              if (_effect.kind == MatrixEffect_Kind.BLINK)
                _number(
                  'On time (%)',
                  'animation-duty',
                  _duty,
                  min: 1,
                  max: 100,
                ),
              if (_effect.kind == MatrixEffect_Kind.FLOWING_GRADIENT ||
                  _effect.kind == MatrixEffect_Kind.RAINBOW) ...[
                _number(
                  'Wavelength (pixels)',
                  'animation-wavelength',
                  _wavelength,
                  helper: '0 spans the entire shared canvas.',
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Reverse flow'),
                  subtitle: const Text('Move toward decreasing canvas indices'),
                  value: _effect.reverse,
                  onChanged: (value) => setState(() {
                    _effect.reverse = value;
                  }),
                ),
              ],
              if (_effect.kind == MatrixEffect_Kind.FILL)
                DropdownButtonFormField<String>(
                  key: const ValueKey('fill-origin'),
                  isExpanded: true,
                  initialValue: _effect.fillFromCenter
                      ? 'center'
                      : _effect.reverse
                      ? 'end'
                      : 'beginning',
                  decoration: const InputDecoration(labelText: 'Fill from'),
                  items: const [
                    DropdownMenuItem(
                      value: 'beginning',
                      child: Text('Beginning'),
                    ),
                    DropdownMenuItem(value: 'end', child: Text('End')),
                    DropdownMenuItem(
                      value: 'center',
                      child: Text('Center · outward'),
                    ),
                  ],
                  onChanged: (value) => setState(() {
                    _effect.fillFromCenter = value == 'center';
                    _effect.reverse = value == 'end';
                  }),
                ),
              const SizedBox(height: 18),
              if (_effect.kind == MatrixEffect_Kind.KEYFRAMES)
                KeyframeEditor(
                  effect: _effect,
                  signal: _modulated
                      ? widget.signals
                            .where((s) => s.id == _signalId)
                            .firstOrNull
                      : null,
                  modulation: _modulated ? _value().modulation : null,
                  canvasSize: widget.canvasSize,
                  centerIndex: widget.centerIndex,
                  layout: widget.layout,
                  onChanged: () => setState(() {}),
                  colorEditor: (color, onChanged) => MatrixColorEditor(
                    label: 'Keyframe color',
                    color: color,
                    onChanged: onChanged,
                  ),
                )
              else
                SimpleAnimationPreview(
                  effect: _value(),
                  signal: _modulated
                      ? widget.signals
                            .where((s) => s.id == _signalId)
                            .firstOrNull
                      : null,
                  canvasSize: widget.canvasSize,
                  centerIndex: widget.centerIndex,
                  caption: widget.previewCaption,
                ),
              if (widget.onPreview != null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: const ValueKey('preview-on-lights'),
                  onPressed: _saving
                      ? null
                      : () async {
                          if (!_form.currentState!.validate()) return;
                          final validation = validateKeyframes(_value());
                          if (validation != null) {
                            setState(() => _saveError = validation);
                            return;
                          }
                          setState(() {
                            _saving = true;
                            _saveError = null;
                          });
                          try {
                            final value = _value();
                            final id = await widget.onPreview!(value);
                            if (mounted) {
                              setState(() {
                                if (value.id != 0) _effect.id = value.id;
                                if (id != null) {
                                  _effect.id = id;
                                } else {
                                  _saveError =
                                      widget.failureMessage?.call() ??
                                      'Could not preview this animation.';
                                }
                              });
                            }
                          } catch (error) {
                            if (mounted) {
                              setState(() => _saveError = error.toString());
                            }
                          } finally {
                            if (mounted) setState(() => _saving = false);
                          }
                        },
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('Preview on lights'),
                ),
                const Text(
                  'Saves this animation to the controller before previewing.',
                ),
              ],
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 12,
                runSpacing: 8,
                children: [
                  TextButton(
                    onPressed: _saving ? null : widget.onCancel,
                    child: const Text('Cancel'),
                  ),
                  if (widget.onSaveDraft != null)
                    OutlinedButton(
                      key: const ValueKey('save-animation-draft'),
                      onPressed: _saving
                          ? null
                          : () {
                              if (!_form.currentState!.validate()) return;
                              final validation = validateKeyframes(_value());
                              if (validation != null) {
                                setState(() => _saveError = validation);
                                return;
                              }
                              if (!widget.onSaveDraft!(_value())) {
                                setState(
                                  () => _saveError =
                                      widget.failureMessage?.call() ??
                                      'Could not save the draft.',
                                );
                              }
                            },
                      child: const Text('Save draft'),
                    ),
                  FilledButton(
                    key: const ValueKey('save-animation'),
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'Applying…' : widget.saveLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class MatrixColorEditor extends StatefulWidget {
  final String label;
  final MatrixColor color;
  final ValueChanged<MatrixColor> onChanged;
  const MatrixColorEditor({
    super.key,
    required this.label,
    required this.color,
    required this.onChanged,
  });
  @override
  State<MatrixColorEditor> createState() => _MatrixColorEditorState();
}

class _MatrixColorEditorState extends State<MatrixColorEditor> {
  late final TextEditingController _hex;
  String _text() => [
    widget.color.red,
    widget.color.green,
    widget.color.blue,
  ].map((c) => c.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
  @override
  void initState() {
    super.initState();
    _hex = TextEditingController(text: _text());
  }

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  void _set(int rgb) {
    final value = widget.color.deepCopy()
      ..red = (rgb >> 16) & 255
      ..green = (rgb >> 8) & 255
      ..blue = rgb & 255;
    _hex.text = rgb.toRadixString(16).padLeft(6, '0').toUpperCase();
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final rgb in [
            0xffffff,
            0xff0000,
            0xff8000,
            0xffff00,
            0x00ff00,
            0x00ffff,
            0x0000ff,
            0x8000ff,
            0xff00ff,
          ])
            Semantics(
              label:
                  'Color #${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}',
              button: true,
              child: InkWell(
                onTap: () => _set(rgb),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(0xff000000 | rgb),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _hex,
        maxLength: 6,
        decoration: InputDecoration(
          labelText: '${widget.label} hex',
          prefixText: '#',
          border: const OutlineInputBorder(),
        ),
        validator: (value) => RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(value ?? '')
            ? null
            : 'Enter six hexadecimal digits',
        onChanged: (value) {
          final rgb = int.tryParse(value, radix: 16);
          if (value.length == 6 && rgb != null) {
            widget.onChanged(
              widget.color.deepCopy()
                ..red = (rgb >> 16) & 255
                ..green = (rgb >> 8) & 255
                ..blue = rgb & 255,
            );
          }
        },
      ),
      Row(
        children: [
          const Text('Opacity'),
          Expanded(
            child: Slider(
              value: widget.color.alpha.toDouble().clamp(0, 255),
              max: 255,
              onChanged: (value) => widget.onChanged(
                widget.color.deepCopy()..alpha = value.round(),
              ),
            ),
          ),
          Text('${(widget.color.alpha * 100 / 255).round()}%'),
        ],
      ),
      Text(
        'Transparent colors let lower-priority layers show through.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}
