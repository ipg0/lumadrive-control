import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';

Color sampleSimpleAnimation(
  MatrixEffect effect,
  double phase,
  double position,
  int canvasSize,
) {
  Color rgba(int r, int g, int b, int a) => Color.fromARGB(
    a.clamp(0, 255),
    r.clamp(0, 255),
    g.clamp(0, 255),
    b.clamp(0, 255),
  );
  final primary = rgba(effect.red, effect.green, effect.blue, effect.alpha);
  final p = phase % 1;
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
    final secondary = effect.secondaryColor;
    final wavelength = effect.wavelengthPixels == 0
        ? math.max(1, canvasSize)
        : effect.wavelengthPixels;
    return Color.lerp(
      primary,
      rgba(secondary.red, secondary.green, secondary.blue, secondary.alpha),
      triangle(position / wavelength + (effect.reverse ? p : -p)),
    )!;
  }
  return primary;
}

class SimpleAnimationPreview extends StatefulWidget {
  final MatrixEffect effect;
  final String caption;
  final int canvasSize;
  const SimpleAnimationPreview({
    super.key,
    required this.effect,
    this.caption = 'One cycle on your phone. Nothing is sent until Apply.',
    required this.canvasSize,
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
  }

  Duration get _period => Duration(
    milliseconds: widget.effect.periodMs < 2 ? 1000 : widget.effect.periodMs,
  );
  @override
  void didUpdateWidget(covariant SimpleAnimationPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.effect.periodMs != widget.effect.periodMs) {
      _phase.duration = _period;
      if (_playing) _phase.repeat(period: _period);
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
                    _phase.repeat(period: _period);
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
                              _phase.value,
                              i * math.max(1, widget.canvasSize) / count,
                              widget.canvasSize,
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
