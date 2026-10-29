import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lumadrive_control/controllers/layout_editor_controller.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/utils/car_positions.dart';

class CarLayout extends StatefulWidget {
  final LayoutEditorController controller;
  const CarLayout({super.key, required this.controller});
  @override
  State<CarLayout> createState() => _CarLayoutState();
}

class _CarLayoutState extends State<CarLayout> {
  CarPosition get _position => widget.controller.selectedCarPosition;
  @override
  Widget build(BuildContext context) {
    final editor = widget.controller;
    final theme = Theme.of(context), colors = theme.colorScheme;
    final door = carDoorParts.entries
        .where((entry) => entry.value.contains(_position))
        .firstOrNull;
    final rows = editor.layout
        .where((row) => row.carPosition == _position)
        .toList();
    final unassigned = editor.layout
        .where((row) => row.carPosition == CarPosition.POSITION_UNSPECIFIED)
        .toList();
    final outputs =
        editor.snapshot?.outputs.where((o) => o.known && o.ready).toList() ??
        <LayoutOutput>[];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Place lights in your car',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Tap a location, then assign a light. Left and right are viewed from inside the car.',
              style: theme.textTheme.bodySmall,
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth, height = width * 1.45;
                Widget location(
                  CarPosition position,
                  String label,
                  double x,
                  double y, {
                  double size = 66,
                }) {
                  final buttonWidth = size * (width / 300).clamp(.75, 1.0);
                  final parts = carDoorParts[position] ?? [position];
                  final selected = parts.contains(_position);
                  final count = editor.layout
                      .where((row) => parts.contains(row.carPosition))
                      .length;
                  return Positioned(
                    left: (x * width - buttonWidth / 2).clamp(
                      0,
                      width - buttonWidth,
                    ),
                    top: y * height - 24,
                    width: buttonWidth,
                    child: Semantics(
                      label: carPositionLabels[position],
                      selected: selected,
                      child: OutlinedButton(
                        key: ValueKey('car-${position.value}'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(44, 48),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 3,
                            vertical: 6,
                          ),
                          backgroundColor: selected
                              ? colors.primaryContainer
                              : colors.surfaceContainerHigh,
                          foregroundColor: selected
                              ? colors.onPrimaryContainer
                              : colors.onSurface,
                          side: BorderSide(
                            color: selected
                                ? colors.primary
                                : colors.outlineVariant,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: editor.busy
                            ? null
                            : () => editor.selectCarPosition(position),
                        child: Text(
                          '$label${count == 0 ? '' : ' · $count'}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ),
                  );
                }

                return SizedBox(
                  key: const ValueKey('car-diagram'),
                  height: height,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: _CarPainter(colors)),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Text(
                          'FRONT',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      location(CarPosition.DASH_LEFT, 'Dash L', .37, .31),
                      location(CarPosition.DASH_RIGHT, 'Dash R', .63, .31),
                      location(
                        CarPosition.FRONT_LEFT_DOOR,
                        'Front L\ndoor',
                        .13,
                        .46,
                        size: 72,
                      ),
                      location(
                        CarPosition.FRONT_RIGHT_DOOR,
                        'Front R\ndoor',
                        .87,
                        .46,
                        size: 72,
                      ),
                      location(
                        CarPosition.REAR_LEFT_DOOR,
                        'Rear L\ndoor',
                        .13,
                        .75,
                        size: 72,
                      ),
                      location(
                        CarPosition.REAR_RIGHT_DOOR,
                        'Rear R\ndoor',
                        .87,
                        .75,
                        size: 72,
                      ),
                      location(
                        CarPosition.FRONT_LEFT_FOOTWELL,
                        'Front L\nfootwell',
                        .39,
                        .46,
                        size: 60,
                      ),
                      location(
                        CarPosition.FRONT_RIGHT_FOOTWELL,
                        'Front R\nfootwell',
                        .61,
                        .46,
                        size: 60,
                      ),
                      location(
                        CarPosition.REAR_LEFT_FOOTWELL,
                        'Rear L\nfootwell',
                        .39,
                        .76,
                        size: 60,
                      ),
                      location(
                        CarPosition.REAR_RIGHT_FOOTWELL,
                        'Rear R\nfootwell',
                        .61,
                        .76,
                        size: 60,
                      ),
                      location(
                        CarPosition.CONSOLE_LEFT,
                        'Console\nL',
                        .39,
                        .61,
                        size: 60,
                      ),
                      location(
                        CarPosition.CONSOLE_RIGHT,
                        'Console\nR',
                        .61,
                        .61,
                        size: 60,
                      ),
                      Positioned(
                        bottom: 6,
                        left: 0,
                        right: 0,
                        child: Text(
                          'START: REAR LEFT  ·  END: REAR RIGHT',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Text(
              carPositionLabels[_position]!,
              style: theme.textTheme.titleSmall,
            ),
            if (door != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (var i = 0; i < door.value.length; i++)
                      ChoiceChip(
                        label: Text(['Door trim', 'Handle', 'Pocket'][i]),
                        selected: _position == door.value[i],
                        onSelected: editor.busy
                            ? null
                            : (_) => editor.selectCarPosition(door.value[i]),
                      ),
                  ],
                ),
              ),
            for (final row in rows)
              ListTile(
                contentPadding: EdgeInsets.zero,
                selected: editor.selectedKey == placementKey(row),
                leading: const Icon(Icons.lightbulb_outline),
                title: Text(editor.titleFor(row)),
                subtitle: Text(
                  '${editor.lengthFor(row)} LEDs · ${row.from > row.to ? 'reversed' : 'forward'}',
                ),
                trailing: const Icon(Icons.tune),
                onTap: () => editor.select(placementKey(row)),
              ),
            if (rows.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('No lights assigned here yet.'),
              ),
            DropdownButtonFormField<String>(
              key: ValueKey(
                'assign-car-output-${_position.value}-${editor.layout.length}',
              ),
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Assign a light to this location',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final output in outputs)
                  DropdownMenuItem(
                    value: outputKey(output),
                    child: Text(
                      '${outputType(output)} · ${nodeSuffix(output.nodeMac)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: editor.busy
                  ? null
                  : (key) {
                      if (key == null) return;
                      final output = outputs.firstWhere(
                        (output) => outputKey(output) == key,
                      );
                      editor.place(output);
                      editor.assignPosition(key, _position);
                      editor.select(key);
                      unawaited(editor.identify(key));
                    },
            ),
            const SizedBox(height: 12),
            Text(
              'Assigned lights form one continuous line from the rear left, up the left side, across the dash and down the right side to the rear right door.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            if (unassigned.isNotEmpty) ...[
              const Divider(height: 28),
              Text(
                '${unassigned.length} ${unassigned.length == 1 ? 'light needs a location' : 'lights need locations'}',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Existing positions are kept until you assign a location. Advanced shows all positions and overlaps.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final row in unassigned)
                    ActionChip(
                      label: Text(editor.titleFor(row)),
                      avatar: const Icon(Icons.place_outlined, size: 18),
                      onPressed: () => editor.select(placementKey(row)),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CarPainter extends CustomPainter {
  final ColorScheme colors;
  _CarPainter(this.colors);
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    RRect panel(
      double left,
      double top,
      double right,
      double bottom, {
      double radius = 5,
    }) => RRect.fromRectAndRadius(
      Rect.fromLTRB(left * w, top * h, right * w, bottom * h),
      Radius.circular(radius),
    );
    final seam = Paint()
      ..color = colors.outline.withValues(alpha: .5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    // Tires sit behind the body, with the front and rear axles clearly visible.
    for (final x in [.195, .745]) {
      for (final y in [.225, .775]) {
        final tire = panel(x, y, x + .06, y + .105);
        canvas.drawRRect(tire, Paint()..color = const Color(0xff101014));
        canvas.drawRRect(tire, seam);
        canvas.drawLine(
          Offset((x + .03) * w, (y + .015) * h),
          Offset((x + .03) * w, (y + .09) * h),
          seam,
        );
      }
    }
    // Mirrors protrude ahead of the front doors.
    for (final left in [true, false]) {
      final mirror = Path()
        ..moveTo((left ? .255 : .745) * w, .325 * h)
        ..lineTo((left ? .19 : .81) * w, .333 * h)
        ..quadraticBezierTo(
          (left ? .175 : .825) * w,
          .35 * h,
          (left ? .205 : .795) * w,
          .355 * h,
        )
        ..lineTo((left ? .255 : .745) * w, .348 * h)
        ..close();
      canvas.drawPath(mirror, Paint()..color = colors.surfaceContainerHighest);
      canvas.drawPath(mirror, seam);
    }
    final body = Path()
      ..moveTo(.405 * w, .075 * h)
      ..cubicTo(.30 * w, .075 * h, .265 * w, .13 * h, .25 * w, .235 * h)
      ..cubicTo(.235 * w, .30 * h, .225 * w, .35 * h, .23 * w, .43 * h)
      ..lineTo(.23 * w, .79 * h)
      ..cubicTo(.23 * w, .88 * h, .25 * w, .925 * h, .33 * w, .94 * h)
      ..quadraticBezierTo(.5 * w, .965 * h, .67 * w, .94 * h)
      ..cubicTo(.75 * w, .925 * h, .77 * w, .88 * h, .77 * w, .79 * h)
      ..lineTo(.77 * w, .43 * h)
      ..cubicTo(.775 * w, .35 * h, .765 * w, .30 * h, .75 * w, .235 * h)
      ..cubicTo(.735 * w, .13 * h, .70 * w, .075 * h, .595 * w, .075 * h)
      ..quadraticBezierTo(.5 * w, .06 * h, .405 * w, .075 * h)
      ..close();
    canvas.drawShadow(body, Colors.black, 5, false);
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          colors: [
            colors.surfaceContainerHighest,
            colors.surfaceContainerHigh,
            colors.surfaceContainerHighest,
          ],
        ).createShader(body.getBounds()),
    );
    canvas.drawPath(
      body,
      Paint()
        ..color = colors.outline.withValues(alpha: .75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    // Bonnet creases and bumper establish which end of the car is the front.
    canvas.drawPath(
      Path()
        ..moveTo(.34 * w, .13 * h)
        ..quadraticBezierTo(.31 * w, .17 * h, .30 * w, .235 * h)
        ..moveTo(.66 * w, .13 * h)
        ..quadraticBezierTo(.69 * w, .17 * h, .70 * w, .235 * h)
        ..moveTo(.37 * w, .105 * h)
        ..quadraticBezierTo(.5 * w, .09 * h, .63 * w, .105 * h),
      seam,
    );
    canvas.drawRRect(
      panel(.405, .115, .595, .13, radius: 3),
      Paint()..color = colors.outlineVariant,
    );
    final headlight = Paint()..color = colors.onSurface.withValues(alpha: .75);
    canvas.drawPath(
      Path()
        ..moveTo(.30 * w, .135 * h)
        ..lineTo(.365 * w, .12 * h)
        ..lineTo(.365 * w, .145 * h)
        ..lineTo(.29 * w, .16 * h)
        ..close(),
      headlight,
    );
    canvas.drawPath(
      Path()
        ..moveTo(.70 * w, .135 * h)
        ..lineTo(.635 * w, .12 * h)
        ..lineTo(.635 * w, .145 * h)
        ..lineTo(.71 * w, .16 * h)
        ..close(),
      headlight,
    );
    final glass = Paint()..color = colors.primary.withValues(alpha: .16);
    final windshield = Path()
      ..moveTo(.32 * w, .245 * h)
      ..quadraticBezierTo(.5 * w, .225 * h, .68 * w, .245 * h)
      ..lineTo(.72 * w, .325 * h)
      ..quadraticBezierTo(.5 * w, .35 * h, .28 * w, .325 * h)
      ..close();
    canvas.drawPath(windshield, glass);
    canvas.drawPath(windshield, seam);
    // Side windows and door seams, rather than one undifferentiated capsule.
    for (final left in [true, false]) {
      final outer = left ? .255 : .745, inner = left ? .305 : .695;
      for (final y in [.365, .59]) {
        final window = Path()
          ..moveTo(outer * w, y * h)
          ..lineTo(inner * w, (y + .015) * h)
          ..lineTo(inner * w, (y + .17) * h)
          ..lineTo(outer * w, (y + .185) * h)
          ..close();
        canvas.drawPath(window, glass);
        canvas.drawPath(window, seam);
      }
      canvas.drawLine(
        Offset((left ? .23 : .77) * w, .565 * h),
        Offset(inner * w, .565 * h),
        seam,
      );
      for (final y in [.47, .70]) {
        canvas.drawRRect(
          panel(left ? .245 : .735, y, left ? .265 : .755, y + .035, radius: 2),
          Paint()..color = colors.outline.withValues(alpha: .65),
        );
      }
    }
    // Front bucket seats with headrests, rear bench, and center tunnel.
    for (final x in [.315, .545]) {
      canvas.drawRRect(panel(x, .49, x + .14, .645, radius: 9), seam);
      canvas.drawRRect(panel(x + .025, .475, x + .115, .505, radius: 4), seam);
      canvas.drawLine(
        Offset(x * w, .60 * h),
        Offset((x + .14) * w, .60 * h),
        seam,
      );
    }
    canvas.drawRRect(panel(.31, .79, .69, .84, radius: 7), seam);
    canvas.drawRRect(panel(.475, .41, .525, .75, radius: 8), seam);
    final steering = Paint()
      ..color = colors.outline.withValues(alpha: .8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(.37 * w, .395 * h), .032 * w, steering);
    canvas.drawLine(
      Offset(.338 * w, .395 * h),
      Offset(.402 * w, .395 * h),
      steering,
    );
    final rearGlass = Path()
      ..moveTo(.3 * w, .855 * h)
      ..lineTo(.7 * w, .855 * h)
      ..lineTo(.66 * w, .90 * h)
      ..quadraticBezierTo(.5 * w, .915 * h, .34 * w, .90 * h)
      ..close();
    canvas.drawPath(rearGlass, glass);
    canvas.drawPath(rearGlass, seam);
    final tail = Paint()..color = colors.tertiary.withValues(alpha: .8);
    canvas.drawRRect(panel(.28, .905, .35, .92, radius: 3), tail);
    canvas.drawRRect(panel(.65, .905, .72, .92, radius: 3), tail);
    final route = Path()
      ..moveTo(w * .17, h * .83)
      ..lineTo(w * .17, h * .14)
      ..quadraticBezierTo(w * .17, h * .06, w * .3, h * .06)
      ..lineTo(w * .7, h * .06)
      ..quadraticBezierTo(w * .83, h * .06, w * .83, h * .14)
      ..lineTo(w * .83, h * .83);
    canvas.drawPath(
      route,
      Paint()
        ..color = colors.primary.withValues(alpha: .65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    final arrow = Paint()
      ..color = colors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(
      Path()
        ..moveTo(w * .17 - 5, h * .54 + 6)
        ..lineTo(w * .17, h * .54)
        ..lineTo(w * .17 + 5, h * .54 + 6),
      arrow,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * .5 - 6, h * .06 - 5)
        ..lineTo(w * .5, h * .06)
        ..lineTo(w * .5 - 6, h * .06 + 5),
      arrow,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * .83 - 5, h * .54 - 6)
        ..lineTo(w * .83, h * .54)
        ..lineTo(w * .83 + 5, h * .54 - 6),
      arrow,
    );
    canvas.drawCircle(
      Offset(w * .17, h * .83),
      5,
      Paint()..color = colors.primary,
    );
    canvas.drawCircle(
      Offset(w * .83, h * .83),
      5,
      Paint()..color = colors.tertiary,
    );
  }

  @override
  bool shouldRepaint(covariant _CarPainter oldDelegate) =>
      oldDelegate.colors != colors;
}
