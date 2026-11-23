import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lumadrive_control/controllers/layout_editor_controller.dart';

class LayoutCanvas extends StatefulWidget {
  final LayoutEditorController controller;
  const LayoutCanvas({super.key, required this.controller});
  @override
  State<LayoutCanvas> createState() => _LayoutCanvasState();
}

class _LayoutCanvasState extends State<LayoutCanvas> {
  double _zoom = 1, _dragPosition = 0;
  static const _rowHeight = 76.0;

  @override
  Widget build(BuildContext context) {
    final editor = widget.controller;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.linear_scale, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Shared canvas · ${editor.canvasSize} pixels',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Expanded(child: Text('View zoom')),
                IconButton(
                  tooltip: 'Zoom out view',
                  onPressed: _zoom > 1
                      ? () => setState(() => _zoom = math.max(1, _zoom / 1.5))
                      : null,
                  icon: const Icon(Icons.zoom_out, size: 20),
                ),
                Text('${(_zoom * 100).round()}%'),
                IconButton(
                  tooltip: 'Zoom in view',
                  onPressed: _zoom < 12
                      ? () => setState(() => _zoom = math.min(12, _zoom * 1.5))
                      : null,
                  icon: const Icon(Icons.zoom_in, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (editor.layout.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.view_stream_outlined,
                        color: colors.primary,
                        size: 42,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Arrange your lighting',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Add an output below to place it on the car’s shared canvas.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final extent = math.max(60, editor.canvasSize).toDouble();
                  final scale =
                      math.max(0.01, (constraints.maxWidth - 24) / extent) *
                      _zoom;
                  final width = math.max(
                    constraints.maxWidth,
                    extent * scale + 24,
                  );
                  final step = _tickStep(scale);
                  return Semantics(
                    label: 'Car layout timeline. Drag outputs horizontally or use the position controls.',
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: width,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 32,
                              child: CustomPaint(
                                size: Size(width, 32),
                                painter: _RulerPainter(
                                  scale: scale,
                                  step: step,
                                  extent: extent.toInt(),
                                  color: colors.onSurfaceVariant,
                                  textStyle: theme.textTheme.labelSmall!
                                      .copyWith(color: colors.onSurfaceVariant),
                                ),
                              ),
                            ),
                            for (var i = 0; i < editor.layout.length; i++)
                              _row(context, i, scale, width, step),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 8),
            Text(
              'Drag to position · strip arrows show direction · overlaps share colors',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _tickStep(double scale) {
    final desired = 45 / scale;
    final power = math
        .pow(10, (math.log(math.max(1, desired)) / math.ln10).floor())
        .toInt();
    for (final multiplier in [1, 2, 5, 10]) {
      if (power * multiplier >= desired) return power * multiplier;
    }
    return power * 10;
  }

  Widget _row(
    BuildContext context,
    int index,
    double scale,
    double width,
    int step,
  ) {
    final editor = widget.controller, row = editor.layout[index];
    final key = placementKey(row), selected = editor.selectedKey == key;
    final output = editor.outputFor(key);
    final point = isPointSource(output);
    final online = output?.online ?? false;
    final low = math.min(row.from, row.to), high = math.max(row.from, row.to);
    final reversed = row.from > row.to;
    final colors = Theme.of(context).colorScheme;
    final palette = [
      colors.primary,
      colors.secondary,
      colors.tertiary,
      Colors.tealAccent.shade100,
      Colors.orange.shade200,
    ];
    final color = palette[index % palette.length];
    final left = point
        ? ((low + 0.5) * scale - 9).clamp(0.0, width - 18)
        : low * scale;
    final barWidth = point ? 18.0 : math.max(2.0, (high - low) * scale);
    final hitWidth = math.max(48.0, barWidth);
    final hitLeft = (left - (hitWidth - barWidth) / 2)
        .clamp(0.0, math.max(0.0, width - hitWidth))
        .toDouble();
    return SizedBox(
      height: _rowHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(
                scale,
                step,
                colors.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 2,
            child: Row(
              children: [
                Icon(
                  online ? Icons.circle : Icons.cloud_off_outlined,
                  size: 10,
                  color: online ? Colors.greenAccent : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    editor.titleFor(row),
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  point ? 'at $low' : '$low–${high - 1}',
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
                const SizedBox(width: 6),
                Icon(
                  point
                      ? Icons.lightbulb_outline
                      : reversed
                      ? Icons.west
                      : Icons.east,
                  size: 14,
                  color: color,
                ),
              ],
            ),
          ),
          Positioned(
            left: hitLeft,
            top: 24,
            width: hitWidth,
            height: 48,
            child: Semantics(
              label: point
                  ? '${editor.titleFor(row)}, at position $low'
                  : '${editor.titleFor(row)}, pixels $low to ${high - 1}, ${reversed ? 'reversed' : 'forward'}',
              selected: selected,
              button: true,
              child: GestureDetector(
                key: ValueKey('layout-bar-$key'),
                behavior: HitTestBehavior.opaque,
                onTap: () => editor.select(key),
                onHorizontalDragStart: editor.busy
                    ? null
                    : (_) {
                        editor.select(key);
                        _dragPosition = low.toDouble();
                      },
                onHorizontalDragUpdate: editor.busy || output?.known != true
                    ? null
                    : (details) {
                        _dragPosition += details.delta.dx / scale;
                        editor.move(
                          key,
                          _dragPosition.round(),
                          snapDistance: 6 / scale,
                        );
                      },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: left - hitLeft,
                      top: point ? 13 : 7,
                      width: barWidth,
                      height: point ? 18 : 30,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        decoration: BoxDecoration(
                          color: color.withValues(
                            alpha: online ? (selected ? 0.8 : 0.45) : 0.2,
                          ),
                          borderRadius: BorderRadius.circular(point ? 9 : 7),
                          border: Border.all(
                            color: selected ? colors.onSurface : color,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: !point && barWidth > 36
                            ? Icon(
                                reversed ? Icons.west : Icons.east,
                                size: 16,
                                color: selected
                                    ? colors.surface
                                    : colors.onSurface,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  final double scale;
  final int step, extent;
  final Color color;
  final TextStyle textStyle;
  _RulerPainter({
    required this.scale,
    required this.step,
    required this.extent,
    required this.color,
    required this.textStyle,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (var tick = 0; tick <= extent; tick += step) {
      final x = tick * scale;
      canvas.drawLine(Offset(x, 24), Offset(x, 31), paint);
      final text = TextPainter(
        text: TextSpan(text: '$tick', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(x == 0 ? 0 : x - text.width / 2, 0));
    }
  }

  @override
  bool shouldRepaint(covariant _RulerPainter old) =>
      scale != old.scale ||
      step != old.step ||
      extent != old.extent ||
      color != old.color;
}

class _GridPainter extends CustomPainter {
  final double scale;
  final int step;
  final Color color;
  _GridPainter(this.scale, this.step, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += step * scale) {
      canvas.drawLine(Offset(x, 24), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      old.scale != scale || old.step != step || old.color != color;
}
