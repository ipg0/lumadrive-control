import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/utils/animation_signal.dart';
import 'package:lumadrive_control/utils/car_positions.dart';

const maxKeyframes = 16;

List<MatrixKeyframe> defaultKeyframes(
  int canvasSize, {
  int track = 1,
  String preset = 'moving',
}) {
  final size = math.max(1, canvasSize);
  final whole = preset == 'whole';
  final moving = preset == 'moving';
  final first = MatrixKeyframe(
    trackId: track,
    timeMs: 0,
    red: 255,
    alpha: 255,
    position: 0,
    width: math.min(6, size).toDouble(),
    wrap: moving,
    allPixels: whole,
  );
  return [
    first,
    first.deepCopy()
      ..timeMs = 2000
      ..position = moving ? size.toDouble() : 0,
  ];
}

String? validateKeyframes(MatrixEffect effect) {
  if (effect.kind != MatrixEffect_Kind.KEYFRAMES) return null;
  if (effect.keyframes.length < 2 || effect.keyframes.length > maxKeyframes) {
    return 'Use 2–$maxKeyframes keyframes in total.';
  }
  final tracks = <int, List<MatrixKeyframe>>{};
  for (final frame in effect.keyframes) {
    (tracks[frame.trackId] ??= []).add(frame);
    if (!frame.position.isFinite ||
        frame.position.abs() > 1000000 ||
        (frame.hasWidth() &&
            (!frame.width.isFinite ||
                frame.width < 0 ||
                frame.width > 65536))) {
      return 'Position must be within ±1,000,000 and width within 0–65,536.';
    }
    if (![
      MatrixInterpolation.LINEAR,
      MatrixInterpolation.SMOOTH,
      MatrixInterpolation.STEP,
    ].contains(frame.interpolation)) {
      return 'Choose a supported interpolation.';
    }
  }
  for (final frames in tracks.values) {
    if (frames.length < 2 || frames.first.timeMs != 0) {
      return 'Each track needs at least two keyframes, starting at 0 ms.';
    }
    for (var i = 1; i < frames.length; i++) {
      if (frames[i].timeMs <= frames[i - 1].timeMs) {
        return 'Keyframe times must increase within each track.';
      }
      if (frames[i].wrap != frames.first.wrap ||
          frames[i].allPixels != frames.first.allPixels) {
        return 'A track must use the same coverage and wrapping throughout.';
      }
    }
  }
  return null;
}

bool hasKeyframeLoopJump(MatrixEffect effect, int canvasSize) {
  if (!effect.loop) return false;
  final tracks = <int, List<MatrixKeyframe>>{};
  for (final frame in effect.keyframes) {
    (tracks[frame.trackId] ??= []).add(frame);
  }
  for (final frames in tracks.values) {
    if (frames.length < 2) continue;
    final first = frames.first, last = frames.last;
    var distance = (last.position - first.position).abs();
    if (first.wrap && canvasSize > 0) {
      distance %= canvasSize;
      distance = math.min(distance, canvasSize - distance);
    }
    if (first.red != last.red ||
        first.green != last.green ||
        first.blue != last.blue ||
        first.alpha != last.alpha ||
        (!first.allPixels &&
            (distance > .001 ||
                ((first.hasWidth() ? first.width : 1) -
                            (last.hasWidth() ? last.width : 1))
                        .abs() >
                    .001))) {
      return true;
    }
  }
  return false;
}

// Mirrors the firmware's global-canvas geometry and source-over compositing.
Color sampleKeyframes(
  MatrixEffect effect,
  int timeMs,
  int pixel,
  int canvasSize, [
  bool samplePosition = false,
]) {
  if (canvasSize <= 0 ||
      pixel < 0 ||
      pixel >= canvasSize ||
      effect.keyframes.isEmpty) {
    return Colors.transparent;
  }
  final tracks = <int, List<MatrixKeyframe>>{};
  var cycle = 0;
  for (final f in effect.keyframes) {
    (tracks[f.trackId] ??= []).add(f);
    cycle = math.max(cycle, f.timeMs);
  }
  final time = effect.loop && !samplePosition && cycle > 0
      ? timeMs % cycle
      : timeMs;
  var result = Colors.transparent;
  for (final frames in tracks.values) {
    var a = frames.first;
    MatrixKeyframe? b;
    for (final f in frames.skip(1)) {
      if (f.timeMs <= time) {
        a = f;
      } else {
        b = f;
        break;
      }
    }
    var t = b == null || b.timeMs <= a.timeMs
        ? 0.0
        : ((time - a.timeMs) / (b.timeMs - a.timeMs)).clamp(0.0, 1.0);
    if (a.interpolation == MatrixInterpolation.STEP) t = 0;
    if (a.interpolation == MatrixInterpolation.SMOOTH) t = t * t * (3 - 2 * t);
    double mix(num x, num y) => x + (y - x) * t;
    final end = b ?? a;
    final position = mix(a.position, end.position);
    final width = mix(
      a.hasWidth() ? a.width : 1,
      end.hasWidth() ? end.width : 1,
    );
    double coverage = 1;
    if (!a.allPixels) {
      final start = a.wrap
          ? ((position % canvasSize) + canvasSize) % canvasSize
          : position;
      double overlap(double l, double r) =>
          math.max(0, math.min(pixel + 1.0, r) - math.max(pixel.toDouble(), l));
      coverage = a.wrap && width >= canvasSize
          ? 1
          : overlap(start, start + width);
      if (a.wrap && start + width > canvasSize && width < canvasSize) {
        coverage += overlap(0, start + width - canvasSize);
      }
      coverage = coverage.clamp(0.0, 1.0);
    }
    final color = Color.fromARGB(
      (mix(a.alpha, end.alpha) * coverage).round().clamp(0, 255),
      mix(a.red, end.red).round().clamp(0, 255),
      mix(a.green, end.green).round().clamp(0, 255),
      mix(a.blue, end.blue).round().clamp(0, 255),
    );
    result = Color.alphaBlend(color, result);
  }
  return result;
}

class KeyframeEditor extends StatefulWidget {
  final MatrixEffect effect;
  final int canvasSize;
  final int? centerIndex;
  final List<MatrixLayout> layout;
  final SignalGenerator? signal;
  final AnimationModulation? modulation;
  final VoidCallback onChanged;
  final Widget Function(MatrixColor, ValueChanged<MatrixColor>) colorEditor;
  const KeyframeEditor({
    super.key,
    required this.effect,
    required this.canvasSize,
    this.centerIndex,
    required this.layout,
    this.signal,
    this.modulation,
    required this.onChanged,
    required this.colorEditor,
  });
  @override
  State<KeyframeEditor> createState() => _KeyframeEditorState();
}

class _KeyframeEditorState extends State<KeyframeEditor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _playback;
  final _time = TextEditingController(),
      _position = TextEditingController(),
      _width = TextEditingController();
  final _timeFocus = FocusNode(),
      _positionFocus = FocusNode(),
      _widthFocus = FocusNode();
  int? _track;
  MatrixKeyframe? _selected;
  double _playhead = 0;
  bool _playing = false;
  Map<int, List<MatrixKeyframe>> get _tracks {
    final result = <int, List<MatrixKeyframe>>{};
    for (final f in widget.effect.keyframes) {
      (result[f.trackId] ??= []).add(f);
    }
    return result;
  }

  int get _cycle => math.max(
    1,
    widget.effect.keyframes.fold<int>(0, (n, f) => math.max(n, f.timeMs)),
  );
  @override
  void initState() {
    super.initState();
    _playback = AnimationController(vsync: this)
      ..addListener(() {
        if (mounted) {
          setState(
            () => _playhead = widget.signal != null && widget.modulation != null
                ? mapSignal(
                        virtualSignal(widget.signal!, _playback.value),
                        widget.modulation!,
                      ) *
                      _cycle
                : _playback.value * _cycle,
          );
        }
      });
    if (widget.effect.keyframes.isNotEmpty) {
      _select(widget.effect.keyframes.first);
    }
  }

  @override
  void didUpdateWidget(covariant KeyframeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.modulation != null) != (widget.modulation != null) &&
        _selected != null) {
      _time.text = _framePosition(_selected!);
    }
  }

  String _framePosition(MatrixKeyframe frame) => widget.modulation == null
      ? '${frame.timeMs}'
      : (100 * frame.timeMs / _cycle).toStringAsFixed(1);

  @override
  void dispose() {
    _playback.dispose();
    for (final c in [_time, _position, _width]) {
      c.dispose();
    }
    for (final f in [_timeFocus, _positionFocus, _widthFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  void _select(MatrixKeyframe f) {
    _track = f.trackId;
    _selected = f;
    _time.text = _framePosition(f);
    _position.text = '${f.position}';
    _width.text = '${f.hasWidth() ? f.width : 1}';
    _playhead = f.timeMs.toDouble();
  }

  void _changed() {
    widget.onChanged();
    setState(() {});
  }

  void _play() {
    if (_playing) {
      _playback.stop();
      setState(() => _playing = false);
      return;
    }
    _playback.duration = Duration(
      milliseconds: widget.signal != null && widget.modulation != null
          ? widget.signal!.periodMs
          : _cycle,
    );
    _playback.value = (_playhead / _cycle).clamp(0.0, 1.0);
    setState(() => _playing = true);
    if (widget.effect.loop ||
        (widget.signal != null && widget.modulation != null)) {
      _playback.repeat();
    } else {
      _playback
          .forward(from: _playback.value == 1 ? 0 : null)
          .whenCompleteOrCancel(() {
            if (mounted) setState(() => _playing = false);
          });
    }
  }

  void _addTrack(String preset) {
    if (widget.effect.keyframes.length > maxKeyframes - 2) return;
    var id = 1;
    while (_tracks.containsKey(id)) {
      id++;
    }
    final frames = defaultKeyframes(
      widget.canvasSize,
      track: id,
      preset: preset,
    );
    if (widget.modulation != null) {
      frames.last.timeMs = _cycle;
    }
    widget.effect.keyframes.addAll(frames);
    _select(frames.first);
    _changed();
  }

  void _addFrame() {
    final f = _selected;
    if (f == null || widget.effect.keyframes.length >= maxKeyframes) return;
    final frames = _tracks[f.trackId]!;
    final index = frames.indexOf(f);
    final next = index + 1 < frames.length
        ? frames[index + 1].timeMs
        : widget.modulation != null
        ? _cycle
        : math.min(0xffffffff, f.timeMs + 1000);
    if (next - f.timeMs < 2) return;
    final added = f.deepCopy()..timeMs = f.timeMs + (next - f.timeMs) ~/ 2;
    final globalIndex = widget.effect.keyframes.indexOf(f);
    widget.effect.keyframes.insert(globalIndex + 1, added);
    _select(added);
    _changed();
  }

  void _reorder(int id, int delta) {
    final tracks = _tracks;
    final ids = tracks.keys.toList();
    final i = ids.indexOf(id), next = i + delta;
    if (next < 0 || next >= ids.length) return;
    final other = ids[next];
    ids[next] = id;
    ids[i] = other;
    widget.effect.keyframes
      ..clear()
      ..addAll(ids.expand((id) => tracks[id]!));
    _changed();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme, tracks = _tracks;
    final frame = _selected;
    final frames = frame == null
        ? <MatrixKeyframe>[]
        : tracks[frame.trackId] ?? [];
    final index = frame == null ? -1 : frames.indexOf(frame);
    final count = math.min(80, math.max(1, widget.canvasSize));
    final invalid = validateKeyframes(widget.effect);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Shared layout', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Beginning', style: Theme.of(context).textTheme.bodySmall),
            Text('End', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        GestureDetector(
          key: const ValueKey('keyframe-canvas'),
          onHorizontalDragUpdate:
              frame == null || frame.allPixels || widget.canvasSize == 0
              ? null
              : (details) {
                  final box = context.findRenderObject() as RenderBox?;
                  if (box == null || box.size.width <= 0) return;
                  frame.position =
                      (frame.position +
                              details.delta.dx /
                                  box.size.width *
                                  widget.canvasSize)
                          .clamp(-1000000, 1000000);
                  _position.text = frame.position.toStringAsFixed(1);
                  _changed();
                },
          child: Semantics(
            label: 'Shared layout animation preview',
            child: SizedBox(
              height: 42,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final showHandle =
                      frame != null &&
                      !frame.allPixels &&
                      widget.canvasSize > 0 &&
                      _playhead.round() == frame.timeMs;
                  final edge = showHandle
                      ? ((frame.position +
                                    (frame.hasWidth() ? frame.width : 1)) /
                                widget.canvasSize *
                                constraints.maxWidth)
                            .clamp(0.0, constraints.maxWidth)
                      : 0.0;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: Row(
                          children: [
                            for (var i = 0; i < count; i++)
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: .4,
                                  ),
                                  color: Color.alphaBlend(
                                    sampleKeyframes(
                                      widget.effect,
                                      _playhead.round(),
                                      (i *
                                              math.max(1, widget.canvasSize) /
                                              count)
                                          .floor(),
                                      math.max(1, widget.canvasSize),
                                      widget.modulation != null,
                                    ),
                                    scheme.surfaceContainerHighest,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (widget.canvasSize > 0)
                        Positioned(
                          left:
                              ((widget.centerIndex ?? widget.canvasSize ~/ 2)
                                              .clamp(0, widget.canvasSize) /
                                          widget.canvasSize *
                                          constraints.maxWidth -
                                      1)
                                  .clamp(
                                    0.0,
                                    math.max(0.0, constraints.maxWidth - 2),
                                  ),
                          top: 0,
                          bottom: 0,
                          child: IgnorePointer(
                            child: Container(
                              key: const ValueKey('keyframe-center-marker'),
                              width: 2,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      if (showHandle)
                        Positioned(
                          left: (edge - 12).clamp(
                            0.0,
                            math.max(0.0, constraints.maxWidth - 24),
                          ),
                          top: 0,
                          bottom: 0,
                          child: GestureDetector(
                            key: const ValueKey('keyframe-width-handle'),
                            behavior: HitTestBehavior.opaque,
                            onHorizontalDragUpdate: (details) {
                              frame.width =
                                  ((frame.hasWidth() ? frame.width : 1) +
                                          details.delta.dx /
                                              constraints.maxWidth *
                                              widget.canvasSize)
                                      .clamp(0, 65536);
                              _width.text = frame.width.toStringAsFixed(1);
                              _changed();
                            },
                            child: SizedBox(
                              width: 24,
                              child: Center(
                                child: Container(
                                  width: 4,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: scheme.onSurface,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        Text(
          'Center: ${widget.centerIndex ?? widget.canvasSize ~/ 2}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (widget.layout.any(
          (row) => row.carPosition != CarPosition.POSITION_UNSPECIFIED,
        ))
          Text(
            widget.layout
                .where(
                  (row) => row.carPosition != CarPosition.POSITION_UNSPECIFIED,
                )
                .map(
                  (row) =>
                      '${carPositionLabels[row.carPosition] ?? ''}: ${math.min(row.from, row.to)}–${math.max(row.from, row.to)}',
                )
                .toSet()
                .join(' · '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        Row(
          children: [
            IconButton(
              tooltip: _playing ? 'Pause preview' : 'Play preview',
              onPressed: _play,
              icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
            ),
            Expanded(
              child: Slider(
                value: (_playhead / _cycle).clamp(0.0, 1.0),
                onChanged: (v) {
                  _playback.stop();
                  setState(() {
                    _playing = false;
                    _playhead = v * _cycle;
                  });
                },
              ),
            ),
            Text(
              widget.modulation != null
                  ? '${(100 * _playhead / _cycle).toStringAsFixed(1)}%'
                  : '${(_playhead / 1000).toStringAsFixed(1)} / ${(_cycle / 1000).toStringAsFixed(1)} s',
            ),
          ],
        ),
        if (widget.modulation == null)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Loop'),
            value: widget.effect.loop,
            onChanged: (v) {
              _playback.stop();
              _playing = false;
              widget.effect.loop = v;
              _changed();
            },
          ),
        if (widget.modulation == null &&
            hasKeyframeLoopJump(widget.effect, widget.canvasSize))
          Text(
            'The loop ends at a different position, width or color and may jump.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        Text(
          'Tracks · ${widget.effect.keyframes.length}/$maxKeyframes keyframes',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Text('Later tracks render over earlier tracks.'),
        for (final entry in tracks.entries) ...[
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => setState(() => _select(entry.value.first)),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Track ${entry.key}${entry.key == _track ? ' · selected' : ''}',
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Move track up',
                onPressed: tracks.keys.first == entry.key
                    ? null
                    : () => _reorder(entry.key, -1),
                icon: const Icon(Icons.arrow_upward),
              ),
              IconButton(
                tooltip: 'Move track down',
                onPressed: tracks.keys.last == entry.key
                    ? null
                    : () => _reorder(entry.key, 1),
                icon: const Icon(Icons.arrow_downward),
              ),
              IconButton(
                tooltip: 'Delete track',
                onPressed: tracks.length <= 1
                    ? null
                    : () {
                        widget.effect.keyframes.removeWhere(
                          (f) => f.trackId == entry.key,
                        );
                        _select(widget.effect.keyframes.first);
                        _changed();
                      },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          SizedBox(
            height: 42,
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Positioned(
                    left: 8,
                    right: 8,
                    top: 20,
                    child: Divider(height: 1, color: scheme.outline),
                  ),
                  for (final f in entry.value)
                    Positioned(
                      left: (f.timeMs / _cycle * (constraints.maxWidth - 40))
                          .clamp(0.0, math.max(0.0, constraints.maxWidth - 40)),
                      top: 0,
                      child: IconButton(
                        key: ValueKey('keyframe-${f.trackId}-${f.timeMs}'),
                        tooltip: widget.modulation == null
                            ? '${f.timeMs} ms'
                            : '${_framePosition(f)}%',
                        onPressed: () {
                          _playback.stop();
                          setState(() {
                            _playing = false;
                            _select(f);
                          });
                        },
                        icon: Icon(
                          Icons.diamond,
                          size: 18,
                          color: identical(frame, f)
                              ? scheme.primary
                              : scheme.outline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              key: const ValueKey('add-keyframe'),
              onPressed:
                  frame == null ||
                      widget.effect.keyframes.length >= maxKeyframes ||
                      (widget.modulation != null && frame.timeMs >= _cycle)
                  ? null
                  : _addFrame,
              icon: const Icon(Icons.add),
              label: const Text('Add keyframe'),
            ),
            PopupMenuButton<String>(
              key: const ValueKey('add-keyframe-track'),
              enabled: widget.effect.keyframes.length <= maxKeyframes - 2,
              onSelected: _addTrack,
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'moving', child: Text('Moving band')),
                PopupMenuItem(value: 'static', child: Text('Static region')),
                PopupMenuItem(value: 'whole', child: Text('Entire layout')),
              ],
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text('+ Add track'),
              ),
            ),
          ],
        ),
        if (frame != null && index >= 0) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Selected keyframe ${index + 1} / ${frames.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Delete keyframe',
                onPressed:
                    index == 0 ||
                        frames.length <= 2 ||
                        (widget.modulation != null &&
                            frame.timeMs == _cycle &&
                            widget.effect.keyframes
                                    .where((f) => f.timeMs == _cycle)
                                    .length ==
                                1)
                    ? null
                    : () {
                        widget.effect.keyframes.remove(frame);
                        _select(frames[index - 1]);
                        _changed();
                      },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          TextFormField(
            key: const ValueKey('keyframe-time'),
            controller: _time,
            focusNode: _timeFocus,
            enabled:
                index != 0 &&
                !(widget.modulation != null && frame.timeMs == _cycle),
            keyboardType: TextInputType.numberWithOptions(
              decimal: widget.modulation != null,
            ),
            inputFormatters: widget.modulation == null
                ? [FilteringTextInputFormatter.digitsOnly]
                : [],
            decoration: InputDecoration(
              labelText: widget.modulation == null
                  ? 'Time (ms)'
                  : 'Position (%)',
              helperText: widget.modulation == null
                  ? 'The first keyframe starts at 0 ms.'
                  : 'Keyframes span 0% to 100% of the signal range.',
            ),
            validator: (v) {
              if (index == 0) return null;
              final position = double.tryParse(v ?? '');
              final n = widget.modulation == null
                  ? int.tryParse(v ?? '')
                  : position == null ||
                        !position.isFinite ||
                        position < 0 ||
                        position > 100
                  ? null
                  : (position * _cycle / 100).round();
              if (n == null ||
                  n > 0xffffffff ||
                  n <= frames[index - 1].timeMs ||
                  (index + 1 < frames.length &&
                      n >= frames[index + 1].timeMs)) {
                return widget.modulation == null
                    ? 'Use a time between neighbouring keyframes.'
                    : 'Use a position between neighbouring keyframes.';
              }
              return null;
            },
            onChanged: (v) {
              final position = double.tryParse(v);
              final n = widget.modulation == null
                  ? int.tryParse(v)
                  : position == null ||
                        !position.isFinite ||
                        position < 0 ||
                        position > 100
                  ? null
                  : (position * _cycle / 100).round();
              if (n != null && n <= 0xffffffff) {
                frame.timeMs = n;
                _changed();
              }
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Entire layout'),
            value: frame.allPixels,
            onChanged: (v) {
              for (final f in frames) {
                f.allPixels = v;
              }
              _changed();
            },
          ),
          if (!frame.allPixels) ...[
            TextFormField(
              key: const ValueKey('keyframe-position'),
              controller: _position,
              focusNode: _positionFocus,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Position (LEDs)',
                helperText: 'Negative values start before the layout.',
              ),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                return n == null || !n.isFinite || n.abs() > 1000000
                    ? 'Enter a position between −1,000,000 and 1,000,000.'
                    : null;
              },
              onChanged: (v) {
                final n = double.tryParse(v);
                if (n != null && n.isFinite && n.abs() <= 1000000) {
                  frame.position = n;
                  _changed();
                }
              },
            ),
            TextFormField(
              key: const ValueKey('keyframe-width'),
              controller: _width,
              focusNode: _widthFocus,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Width (LEDs)'),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                return n == null || !n.isFinite || n < 0 || n > 65536
                    ? 'Enter a width between 0 and 65,536.'
                    : null;
              },
              onChanged: (v) {
                final n = double.tryParse(v);
                if (n != null && n.isFinite && n >= 0 && n <= 65536) {
                  frame.width = n;
                  _changed();
                }
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Wrap around ends'),
              value: frame.wrap,
              onChanged: (v) {
                for (final f in frames) {
                  f.wrap = v;
                }
                _changed();
              },
            ),
          ],
          const SizedBox(height: 12),
          KeyedSubtree(
            key: ObjectKey(frame),
            child: widget.colorEditor(
              MatrixColor(
                red: frame.red,
                green: frame.green,
                blue: frame.blue,
                alpha: frame.alpha,
              ),
              (c) {
                frame
                  ..red = c.red
                  ..green = c.green
                  ..blue = c.blue
                  ..alpha = c.alpha;
                _changed();
              },
            ),
          ),
          DropdownButtonFormField<MatrixInterpolation>(
            key: ValueKey('interpolation-${frame.trackId}-$index'),
            initialValue: frame.interpolation,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Move to next'),
            items: const [
              DropdownMenuItem(
                value: MatrixInterpolation.LINEAR,
                child: Text('Linear'),
              ),
              DropdownMenuItem(
                value: MatrixInterpolation.SMOOTH,
                child: Text('Smooth'),
              ),
              DropdownMenuItem(
                value: MatrixInterpolation.STEP,
                child: Text('Step'),
              ),
            ],
            onChanged: (v) {
              if (v != null) {
                frame.interpolation = v;
                _changed();
              }
            },
          ),
        ],
        if (invalid != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(invalid, style: TextStyle(color: scheme.error)),
          ),
        const SizedBox(height: 8),
        Text(
          'Preview on this phone. Positions use the shared layout.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
