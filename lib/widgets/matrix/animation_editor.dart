import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumadrive_control/controllers/matrix_editor_controller.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/utils/gradient_palette.dart';

import 'simple_animation_preview.dart';

String? unsignedNumber(String? value, {int min = 0, int max = 0xffffffff}) {
  final number = int.tryParse(value ?? '');
  return number == null || number < min || number > max
      ? 'Enter $min–$max'
      : null;
}

class AnimationEditor extends StatefulWidget {
  final MatrixEffect initial;
  final int canvasSize;
  final FutureOr<bool> Function(MatrixEffect) onSave;
  final VoidCallback onCancel;
  final String saveLabel, previewCaption;
  final String? Function()? failureMessage;
  final bool Function(MatrixEffect)? onSaveDraft;
  const AnimationEditor({
    super.key,
    required this.initial,
    required this.canvasSize,
    required this.onSave,
    required this.onCancel,
    this.saveLabel = 'Apply animation',
    this.previewCaption =
        'Preview on this phone. Apply animation saves it to the controller.',
    this.failureMessage,
    this.onSaveDraft,
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
  String? _saveError;
  late final TextEditingController _name,
      _duration,
      _period,
      _duty,
      _wavelength;
  @override
  void initState() {
    super.initState();
    _effect = widget.initial.deepCopy();
    _gradient = gradientPalette(_effect)
        .map((color) => color.deepCopy())
        .toList();
    _gradientIds = [
      for (var i = 0; i < _gradient.length; i++) _nextGradientId++,
    ];
    _name = TextEditingController(text: _effect.name);
    if (_effect.id == 0 && _effect.name.isEmpty) {
      _automaticName = true;
      _name.text = effectKindLabel(_effect.kind);
    }
    _duration = TextEditingController(text: '${_effect.durationMs}');
    _period = TextEditingController(
      text: '${_effect.periodMs == 0 ? 1000 : _effect.periodMs}',
    );
    _duty = TextEditingController(
      text: '${_effect.dutyPercent == 0 ? 50 : _effect.dutyPercent}',
    );
    _wavelength = TextEditingController(text: '${_effect.wavelengthPixels}');
  }

  @override
  void dispose() {
    for (final field in [_name, _duration, _period, _duty, _wavelength]) {
      field.dispose();
    }
    super.dispose();
  }

  MatrixEffect _value() {
    final value = _effect.deepCopy()
      ..name = _name.text.trim()
      ..durationMs = int.tryParse(_duration.text) ?? 0
      ..periodMs = _effect.kind == MatrixEffect_Kind.STATIC_COLOR
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
    value.gradientColors.clear();
    if (value.kind == MatrixEffect_Kind.FLOWING_GRADIENT) {
      value.gradientColors.addAll(_gradient.map((color) => color.deepCopy()));
      final first = _gradient.first;
      value
        ..red = first.red
        ..green = first.green
        ..blue = first.blue
        ..alpha = first.alpha
        ..secondaryColor = _gradient[1].deepCopy();
    }
    return value;
  }

  void _moveColor(int index, int delta) => setState(() {
    final color = _gradient.removeAt(index), id = _gradientIds.removeAt(index);
    _gradient.insert(index + delta, color);
    _gradientIds.insert(index + delta, id);
  });

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
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
                  _effect.kind = kind!;
                  if (_automaticName) _name.text = effectKindLabel(kind);
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
              if (_effect.kind == MatrixEffect_Kind.RAINBOW) ...[
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
              ] else if (_effect.kind != MatrixEffect_Kind.FLOWING_GRADIENT)
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
              if (_effect.kind == MatrixEffect_Kind.FLOWING_GRADIENT) ...[
                Text(
                  'Gradient colors · ${_gradient.length}/$maxGradientColors',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Text(
                  'Colors are evenly spaced and flow in this order, wrapping from the last back to the first.',
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
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Reverse fill'),
                  subtitle: const Text('Fill toward decreasing canvas indices'),
                  value: _effect.reverse,
                  onChanged: (value) => setState(() => _effect.reverse = value),
                ),
              const SizedBox(height: 18),
              SimpleAnimationPreview(
                effect: _value(),
                canvasSize: widget.canvasSize,
                caption: widget.previewCaption,
              ),
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
