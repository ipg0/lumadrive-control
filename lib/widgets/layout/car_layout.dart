import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lumadrive_control/controllers/layout_editor_controller.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/utils/car_positions.dart';
import 'package:lumadrive_control/widgets/layout/layout_output_editor.dart';

class CarLayout extends StatefulWidget {
  final LayoutEditorController controller;
  const CarLayout({super.key, required this.controller});
  @override
  State<CarLayout> createState() => _CarLayoutState();
}

class _CarLayoutState extends State<CarLayout> {
  int _pickerGeneration = 0;
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
                final width = constraints.maxWidth, height = width * 1.74;
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
                              ? colors.primaryContainer.withValues(alpha: .96)
                              : colors.surfaceContainerHigh.withValues(
                                  alpha: .92,
                                ),
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
                        .61,
                        size: 60,
                      ),
                      location(
                        CarPosition.REAR_RIGHT_FOOTWELL,
                        'Rear R\nfootwell',
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
            const SizedBox(height: 8),
            Text(
              'Lights at this location',
              style: theme.textTheme.titleSmall,
            ),
            for (final row in rows)
              ListTile(
                contentPadding: EdgeInsets.zero,
                selected: editor.selectedKey == placementKey(row),
                leading: const Icon(Icons.lightbulb_outline),
                title: Text(editor.titleFor(row)),
                subtitle: Text(
                  isPointSource(editor.outputFor(placementKey(row)))
                      ? 'RGB light'
                      : '${editor.lengthFor(row)} LEDs · ${row.from > row.to ? 'reversed' : 'forward'}',
                ),
                trailing: Icon(editor.selectedKey == placementKey(row)
                    ? Icons.check_circle_outline
                    : Icons.chevron_right),
                onTap: () => editor.select(placementKey(row)),
              ),
            if (rows.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('No lights assigned here yet. Choose one below.'),
              ),
            const SizedBox(height: 8),
            KeyedSubtree(
              key: ValueKey(
                'assign-car-output-${_position.value}-${editor.layout.length}',
              ),
              child: DropdownButtonFormField<String>(
                key: ValueKey(
                  'assign-car-selection-${_position.value}-$_pickerGeneration',
                ),
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Add or move a light here',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final output in outputs)
                    DropdownMenuItem(
                      value: outputKey(output),
                      child: Row(
                        children: [
                          Expanded(child: Text(
                            '${outputType(output)} · ${nodeSuffix(output.nodeMac)}',
                            overflow: TextOverflow.ellipsis,
                          )),
                          if (editor.layout.where((row) => placementKey(row) == outputKey(output)).firstOrNull case final placed?) ...[
                            const SizedBox(width: 8),
                            Flexible(child: Text(
                              placed.carPosition == _position
                                  ? 'Here'
                                  : placed.carPosition == CarPosition.POSITION_UNSPECIFIED
                                      ? 'Unassigned'
                                      : 'In ${carPositionLabels[placed.carPosition]}',
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                            )),
                          ],
                        ],
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
                        setState(() => _pickerGeneration++);
                      },
              ),
            ),
            if (editor.selected != null) ...[
              const Divider(height: 32),
              Text(
                editor.titleFor(editor.selected!),
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                editor.selected!.carPosition == _position
                    ? 'Editing a light at this location'
                    : editor.selected!.carPosition == CarPosition.POSITION_UNSPECIFIED
                        ? 'Selected light has no car location'
                        : 'Selected light is at ${carPositionLabels[editor.selected!.carPosition]}',
                style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
              ),
              if (editor.selected!.carPosition != _position) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    key: const ValueKey('assign-selected-segment'),
                    onPressed: editor.busy ? null : () => editor.assignPosition(editor.selectedKey!, _position),
                    icon: const Icon(Icons.add_location_alt_outlined),
                    label: Text('Assign to ${carPositionLabels[_position]}', textAlign: TextAlign.center),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              LayoutOutputEditor(
                key: ValueKey('editor-${editor.selectedKey}'),
                controller: editor,
                advanced: false,
              ),
            ],
            if (unassigned.isNotEmpty) ...[
              const SizedBox(height: 12),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text('${unassigned.length} ${unassigned.length == 1 ? 'light needs' : 'lights need'} a location'),
                children: [
                  for (final row in unassigned)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(editor.titleFor(row)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => editor.select(placementKey(row)),
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
      ..color = colors.outline.withValues(alpha: .48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    // Keep the route outside this transform so it stays aligned with the
    // location controls.
    canvas.save();
    canvas.translate(w * .5, h * .5);
    canvas.scale(1.08, .92);
    canvas.translate(-w * .5, -h * .5);
    // Tires sit behind the body, with the front and rear axles clearly visible.
    for (final x in [.195, .745]) {
      for (final y in [.225, .775]) {
        final tire = panel(x, y, x + .06, y + .105);
        canvas.drawRRect(tire, Paint()..color = const Color(0xff121217));
        canvas.drawRRect(tire, seam);
        for (final offset in [.02, .04]) {
          canvas.drawLine(
            Offset((x + offset) * w, (y + .015) * h),
            Offset((x + offset) * w, (y + .09) * h),
            seam,
          );
        }
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
      ..moveTo(.405 * w, .10 * h)
      ..quadraticBezierTo(.5 * w, .085 * h, .595 * w, .10 * h)
      // Long tapered bonnet, flowing into a pronounced front wheel arch.
      ..cubicTo(.67 * w, .105 * h, .71 * w, .15 * h, .74 * w, .225 * h)
      ..cubicTo(.77 * w, .27 * h, .78 * w, .31 * h, .765 * w, .36 * h)
      // Narrower waist between the two wider fenders.
      ..cubicTo(.745 * w, .43 * h, .745 * w, .60 * h, .76 * w, .68 * h)
      ..cubicTo(.78 * w, .74 * h, .79 * w, .80 * h, .77 * w, .85 * h)
      ..cubicTo(.75 * w, .905 * h, .71 * w, .935 * h, .655 * w, .94 * h)
      ..quadraticBezierTo(.5 * w, .953 * h, .345 * w, .94 * h)
      ..cubicTo(.29 * w, .935 * h, .25 * w, .905 * h, .23 * w, .85 * h)
      ..cubicTo(.21 * w, .80 * h, .22 * w, .74 * h, .24 * w, .68 * h)
      ..cubicTo(.255 * w, .60 * h, .255 * w, .43 * h, .235 * w, .36 * h)
      ..cubicTo(.22 * w, .31 * h, .23 * w, .27 * h, .26 * w, .225 * h)
      ..cubicTo(.29 * w, .15 * h, .33 * w, .105 * h, .405 * w, .10 * h)
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
    // A fine highlight along the shoulders gives the top-down silhouette depth.
    canvas.drawPath(
      Path()
        ..moveTo(.275 * w, .23 * h)
        ..cubicTo(.255 * w, .36 * h, .255 * w, .68 * h, .265 * w, .81 * h)
        ..moveTo(.725 * w, .23 * h)
        ..cubicTo(.745 * w, .36 * h, .745 * w, .68 * h, .735 * w, .81 * h),
      Paint()
        ..color = colors.onSurface.withValues(alpha: .13)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    // A wide, low grille and swept-back lamps distinguish the sedan's nose.
    canvas.drawPath(
      Path()
        ..moveTo(.355 * w, .15 * h)
        ..quadraticBezierTo(.32 * w, .20 * h, .315 * w, .245 * h)
        ..moveTo(.645 * w, .15 * h)
        ..quadraticBezierTo(.68 * w, .20 * h, .685 * w, .245 * h)
        ..moveTo(.35 * w, .135 * h)
        ..quadraticBezierTo(.5 * w, .12 * h, .65 * w, .135 * h),
      seam,
    );
    for (final grille in [
      panel(.405, .125, .492, .143, radius: 3),
      panel(.508, .125, .595, .143, radius: 3),
    ]) {
      canvas.drawRRect(grille, Paint()..color = colors.outlineVariant);
    }
    final headlight = Paint()..color = colors.onSurface.withValues(alpha: .75);
    canvas.drawPath(
      Path()
        ..moveTo(.30 * w, .165 * h)
        ..lineTo(.405 * w, .145 * h)
        ..lineTo(.375 * w, .17 * h)
        ..lineTo(.28 * w, .19 * h)
        ..close(),
      headlight,
    );
    canvas.drawPath(
      Path()
        ..moveTo(.70 * w, .165 * h)
        ..lineTo(.595 * w, .145 * h)
        ..lineTo(.625 * w, .17 * h)
        ..lineTo(.72 * w, .19 * h)
        ..close(),
      headlight,
    );
    // Recessed cabin and dashboard, visible through the controls without
    // competing with their labels.
    final cabin = Path()
      ..moveTo(.315 * w, .33 * h)
      ..quadraticBezierTo(.5 * w, .355 * h, .685 * w, .33 * h)
      ..lineTo(.70 * w, .835 * h)
      ..quadraticBezierTo(.5 * w, .86 * h, .30 * w, .835 * h)
      ..close();
    canvas.drawPath(
      cabin,
      Paint()..color = colors.surface.withValues(alpha: .55),
    );
    canvas.drawPath(cabin, seam);
    canvas.drawPath(
      Path()
        ..moveTo(.32 * w, .38 * h)
        ..quadraticBezierTo(.5 * w, .405 * h, .68 * w, .38 * h),
      Paint()
        ..color = colors.outline.withValues(alpha: .65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    final glass = Paint()..color = colors.primary.withValues(alpha: .14);
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
      final seat = panel(x, .49, x + .14, .645, radius: 9);
      canvas.drawRRect(
        seat,
        Paint()..color = colors.surfaceContainerHighest.withValues(alpha: .65),
      );
      canvas.drawRRect(seat, seam);
      final headrest = panel(x + .025, .475, x + .115, .505, radius: 4);
      canvas.drawRRect(
        headrest,
        Paint()..color = colors.surfaceContainerHighest,
      );
      canvas.drawRRect(headrest, seam);
      canvas.drawLine(
        Offset(x * w, .60 * h),
        Offset((x + .14) * w, .60 * h),
        seam,
      );
    }
    final bench = panel(.31, .79, .69, .84, radius: 7);
    canvas.drawRRect(
      bench,
      Paint()..color = colors.surfaceContainerHighest.withValues(alpha: .6),
    );
    canvas.drawRRect(bench, seam);
    final tunnel = panel(.475, .41, .525, .75, radius: 8);
    canvas.drawRRect(tunnel, Paint()..color = colors.surfaceContainerHigh);
    canvas.drawRRect(tunnel, seam);
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
    canvas.restore();
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
        ..color = colors.primary.withValues(alpha: .48)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
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
