import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/utils/gradient_palette.dart';
import 'package:lumadrive_control/utils/animation_signal.dart';

Color sampleSimpleAnimation(
  MatrixEffect effect,
  double phase,
  double position,
  int canvasSize, [
  int? centerIndex,
  bool samplePosition = false,
]) {
  final start = effect.hasRegionStart() ? effect.regionStart : 0;
  final end = effect.hasRegionEnd() ? effect.regionEnd : canvasSize;
  if (start >= end || position < start || position >= end) {
    return Colors.transparent;
  }
  position -= start;
  canvasSize = end - start;
  if (centerIndex != null) centerIndex = centerIndex.clamp(start, end) - start;
  Color rgba(int r, int g, int b, int a) => Color.fromARGB(
    a.clamp(0, 255),
    r.clamp(0, 255),
    g.clamp(0, 255),
    b.clamp(0, 255),
  );
  final primary = rgba(effect.red, effect.green, effect.blue, effect.alpha);
  final p = phase % 1;
  if (effect.kind == MatrixEffect_Kind.FILL) {
    final progress = effect.loop && !samplePosition ? p : phase.clamp(0.0, 1.0);
    final count = math.max(1, canvasSize);
    final filled = (progress * count).ceil();
    final pixel = position.floor().clamp(0, count - 1);
    if (effect.fillFromCenter) {
      final center = (centerIndex ?? count ~/ 2).clamp(0, count);
      final middlePixel = count.isOdd && center == count ~/ 2;
      final radius =
          (progress *
                  (middlePixel ? center + 1 : math.max(center, count - center)))
              .ceil();
      final distance = middlePixel
          ? (pixel - center).abs()
          : pixel < center
          ? center - 1 - pixel
          : pixel - center;
      return distance < radius ? primary : Colors.transparent;
    }
    return (effect.reverse ? pixel >= count - filled : pixel < filled)
        ? primary
        : Colors.transparent;
  }
  double triangle(double value) {
    final v = value % 1;
    return v < 0.5 ? v * 2 : (1 - v) * 2;
  }

  if (effect.kind == MatrixEffect_Kind.BLINK) {
    return p * 100 < (effect.dutyPercent == 0 ? 50 : effect.dutyPercent)
        ? primary
        : Colors.transparent;
  }
  if (effect.kind == MatrixEffect_Kind.BREATHE) {
    if (effect.gradientColors.length >= 2) {
      final colors = effect.gradientColors;
      final scaled = p * colors.length;
      final index = scaled.floor();
      final t = scaled - index;
      final fraction = t * t * (3 - 2 * t);
      final from = colors[index], to = colors[(index + 1) % colors.length];
      int mix(int a, int b) => (a + (b - a) * fraction).round();
      return rgba(
        mix(from.red, to.red),
        mix(from.green, to.green),
        mix(from.blue, to.blue),
        mix(from.alpha, to.alpha),
      );
    }
    final t = triangle(p), alpha = t * t * (3 - 2 * t);
    return primary.withValues(alpha: primary.a * alpha);
  }
  if (effect.kind == MatrixEffect_Kind.RAINBOW) {
    final wavelength = effect.wavelengthPixels == 0
        ? math.max(1, canvasSize)
        : effect.wavelengthPixels;
    final hue = ((position / wavelength + (effect.reverse ? p : -p)) % 1) * 360;
    return HSVColor.fromAHSV(effect.alpha / 255, hue, 1, 1).toColor();
  }
  if (effect.kind == MatrixEffect_Kind.FLOWING_GRADIENT) {
    final palette = gradientPalette(effect);
    final wavelength = effect.wavelengthPixels == 0
        ? math.max(1, canvasSize)
        : effect.wavelengthPixels;
    final scaled =
        ((position / wavelength + (effect.reverse ? p : -p)) % 1) *
        palette.length;
    final index = scaled.floor();
    final from = palette[index], to = palette[(index + 1) % palette.length];
    final fraction = scaled - index;
    // Match firmware's straight-channel RGBA interpolation, including alpha.
    int mix(int a, int b) => (a + (b - a) * fraction).round();
    return rgba(
      mix(from.red, to.red),
      mix(from.green, to.green),
      mix(from.blue, to.blue),
      mix(from.alpha, to.alpha),
    );
  }
  return primary;
}

class SimpleAnimationPreview extends StatefulWidget {
  final MatrixEffect effect;
  final String caption;
  final int canvasSize;
  final int? centerIndex;
  final SignalGenerator? signal;
  const SimpleAnimationPreview({
    super.key,
    required this.effect,
    this.caption = 'One cycle on your phone. Nothing is sent until Apply.',
    required this.canvasSize,
    this.centerIndex,
    this.signal,
  });
  @override
  State<SimpleAnimationPreview> createState() => _SimpleAnimationPreviewState();
}

class _SimpleAnimationPreviewState extends State<SimpleAnimationPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _phase;
  bool _playing = false;
  @override
  void initState() {
    super.initState();
    _phase = AnimationController(vsync: this, duration: _period);
    _phase.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _playing = false);
      }
    });
  }

  Duration get _period => Duration(
    milliseconds: widget.effect.hasModulation() && widget.signal != null
        ? widget.signal!.periodMs
        : widget.effect.periodMs < 2
        ? 1000
        : widget.effect.periodMs,
  );
  @override
  void didUpdateWidget(covariant SimpleAnimationPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.effect.periodMs != widget.effect.periodMs ||
        oldWidget.effect.kind != widget.effect.kind ||
        oldWidget.effect.loop != widget.effect.loop ||
        oldWidget.signal?.periodMs != widget.signal?.periodMs ||
        oldWidget.effect.hasModulation() != widget.effect.hasModulation()) {
      _phase.duration = _period;
      if (_playing) {
        _phase.stop();
        _play();
      }
    }
  }

  void _play() {
    if (!widget.effect.hasModulation() &&
        widget.effect.kind == MatrixEffect_Kind.FILL &&
        !widget.effect.loop) {
      _phase.forward(from: _phase.value >= 1 ? 0 : _phase.value);
    } else {
      _phase.repeat(period: _period);
    }
  }

  @override
  void dispose() {
    _phase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _phase,
    builder: (context, _) {
      final count = math.min(80, math.max(1, widget.canvasSize));
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Shared canvas · ${widget.canvasSize} pixels',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              IconButton(
                tooltip: _playing ? 'Pause preview' : 'Play preview',
                onPressed: () => setState(() {
                  _playing = !_playing;
                  if (_playing) {
                    _play();
                  } else {
                    _phase.stop();
                  }
                }),
                icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
              ),
            ],
          ),
          Semantics(
            label: 'Animation preview on this phone',
            child: SizedBox(
              height: 38,
              child: Row(
                children: [
                  for (var i = 0; i < count; i++)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 0.4),
                        decoration: BoxDecoration(
                          color: Color.alphaBlend(
                            sampleSimpleAnimation(
                              widget.effect,
                              widget.effect.hasModulation() &&
                                      widget.signal != null
                                  ? mapSignal(
                                      virtualSignal(
                                        widget.signal!,
                                        _phase.value,
                                      ),
                                      widget.effect.modulation,
                                    )
                                  : _phase.value,
                              i * math.max(1, widget.canvasSize) / count,
                              widget.canvasSize,
                              widget.centerIndex,
                              widget.effect.hasModulation(),
                            ),
                            const Color(0xff25252b),
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Slider(
            value: _phase.value,
            onChanged: (value) {
              _phase.stop();
              setState(() {
                _playing = false;
                _phase.value = value;
              });
            },
          ),
          Text(widget.caption, style: Theme.of(context).textTheme.bodySmall),
        ],
      );
    },
  );
}
