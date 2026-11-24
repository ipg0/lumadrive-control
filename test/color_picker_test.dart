import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/widgets/matrix/animation_editor.dart';

void main() {
  testWidgets(
    'picker previews hex, validates, applies, and preserves opacity',
    (tester) async {
      var color = MatrixColor()
        ..red = 12
        ..green = 34
        ..blue = 56
        ..alpha = 123;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => SingleChildScrollView(
                child: MatrixColorEditor(
                  label: 'Color',
                  color: color,
                  onChanged: (value) => setState(() => color = value),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('pick-color-Color')));
      await tester.pumpAndSettle();
      expect(find.byType(ColorPickerArea), findsOneWidget);
      expect(
        tester
            .widget<ColorPickerArea>(find.byType(ColorPickerArea))
            .paletteType,
        PaletteType.hsvWithHue,
      );
      final hex = find.byKey(const ValueKey('color-picker-hex'));
      expect(tester.widget<TextFormField>(hex).controller!.text, '0C2238');
      await tester.enterText(hex, '12');
      await tester.tap(find.text('Use color'));
      await tester.pumpAndSettle();
      expect(find.text('Enter six hexadecimal digits'), findsOneWidget);
      await tester.enterText(hex, '4A72C1');
      await tester.pump();
      final preview = tester.widget<Container>(
        find.byKey(const ValueKey('color-picker-preview')),
      );
      expect(
        (preview.decoration! as BoxDecoration).color,
        const Color(0xff4a72c1),
      );
      await tester.tap(find.text('Use color'));
      await tester.pumpAndSettle();
      expect(
        [color.red, color.green, color.blue, color.alpha],
        [74, 114, 193, 123],
      );
      expect(find.text('Choose color · #4A72C1'), findsOneWidget);
    },
  );

  testWidgets('visual picker changes color and cancellation discards changes', (
    tester,
  ) async {
    var color = MatrixColor()
      ..red = 255
      ..alpha = 255;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: MatrixColorEditor(
                label: 'Color',
                color: color,
                onChanged: (value) => setState(() => color = value),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('pick-color-Color')));
    await tester.pumpAndSettle();
    final area = find.byType(ColorPickerArea);
    await tester.tapAt(tester.getCenter(area));
    await tester.pumpAndSettle();
    final preview = tester.widget<Container>(
      find.byKey(const ValueKey('color-picker-preview')),
    );
    expect(
      (preview.decoration! as BoxDecoration).color,
      isNot(const Color(0xffff0000)),
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect([color.red, color.green, color.blue], [255, 0, 0]);
  });

  testWidgets('preset updates the picker but only commits when confirmed', (
    tester,
  ) async {
    var color = MatrixColor()
      ..red = 255
      ..alpha = 123;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: MatrixColorEditor(
                label: 'Color',
                color: color,
                onChanged: (value) => setState(() => color = value),
              ),
            ),
          ),
        ),
      ),
    );
    final blue = find.bySemanticsLabel('Color #0000FF');
    expect(blue, findsNothing);
    await tester.tap(find.byKey(const ValueKey('pick-color-Color')));
    await tester.pumpAndSettle();
    await tester.tap(blue);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('color-picker-hex')))
          .controller!
          .text,
      '0000FF',
    );
    final preview = tester.widget<Container>(
      find.byKey(const ValueKey('color-picker-preview')),
    );
    expect(
      (preview.decoration! as BoxDecoration).color,
      const Color(0xff0000ff),
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect([color.red, color.green, color.blue, color.alpha], [255, 0, 0, 123]);
    await tester.tap(find.byKey(const ValueKey('pick-color-Color')));
    await tester.pumpAndSettle();
    await tester.tap(blue);
    await tester.tap(find.text('Use color'));
    await tester.pumpAndSettle();
    expect([color.red, color.green, color.blue, color.alpha], [0, 0, 255, 123]);
  });

  testWidgets('saturation and brightness field has the expected orientation', (
    tester,
  ) async {
    final color = MatrixColor()
      ..red = 255
      ..alpha = 255;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MatrixColorEditor(
              label: 'Color',
              color: color,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('pick-color-Color')));
    await tester.pumpAndSettle();
    final area = tester.getRect(find.byType(ColorPickerArea));
    Future<Color> sample(Offset point) async {
      await tester.tapAt(point);
      await tester.pumpAndSettle();
      return (tester
                  .widget<Container>(
                    find.byKey(const ValueKey('color-picker-preview')),
                  )
                  .decoration!
              as BoxDecoration)
          .color!;
    }

    final white = await sample(area.topLeft + const Offset(1, 1));
    expect(white.r, greaterThan(0.98));
    expect(white.g, greaterThan(0.98));
    expect(white.b, greaterThan(0.98));
    final red = await sample(area.topRight + const Offset(-1, 1));
    expect(red.r, greaterThan(0.98));
    expect(red.g, lessThan(0.02));
    expect(red.b, lessThan(0.02));
    final black = await sample(area.bottomCenter + const Offset(0, -1));
    expect(black.r, lessThan(0.02));
    expect(black.g, lessThan(0.02));
    expect(black.b, lessThan(0.02));
  });
}
