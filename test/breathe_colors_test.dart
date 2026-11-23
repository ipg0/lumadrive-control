import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/widgets/matrix/animation_editor.dart';
import 'package:lumadrive_control/widgets/matrix/simple_animation_preview.dart';

void main() {
  test('breathe previews a smooth cyclic RGBA palette', () {
    final effect = MatrixEffect(
      kind: MatrixEffect_Kind.BREATHE,
      gradientColors: [
        MatrixColor(red: 255, alpha: 255),
        MatrixColor(green: 255, alpha: 127),
        MatrixColor(blue: 255, alpha: 255),
      ],
    );
    expect(sampleSimpleAnimation(effect, 0, 0, 10), const Color(0xffff0000));
    expect(
      sampleSimpleAnimation(effect, 1 / 6, 0, 10),
      const Color(0xbf808000),
    );
    expect(
      sampleSimpleAnimation(effect, 1 / 3, 0, 10),
      const Color(0x7f00ff00),
    );
    expect(sampleSimpleAnimation(effect, 1, 0, 10), const Color(0xffff0000));
  });

  testWidgets('editor enables, extends and saves a breathe palette', (
    tester,
  ) async {
    MatrixEffect? saved;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AnimationEditor(
              initial: MatrixEffect(
                kind: MatrixEffect_Kind.BREATHE,
                red: 255,
                alpha: 255,
              ),
              canvasSize: 10,
              onSave: (value) {
                saved = value;
                return true;
              },
              onCancel: () {},
            ),
          ),
        ),
      ),
    );
    final toggle = find.byKey(const ValueKey('breathe-cycle-colors'));
    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(find.text('Cycle colors · 2/8'), findsOneWidget);
    final add = find.byKey(const ValueKey('add-gradient-color'));
    await tester.ensureVisible(add);
    await tester.pumpAndSettle();
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(find.text('Cycle colors · 3/8'), findsOneWidget);
    final save = find.byKey(const ValueKey('save-animation'));
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pump();
    expect(saved!.kind, MatrixEffect_Kind.BREATHE);
    expect(saved!.gradientColors.length, 3);
    expect(saved!.gradientColors.first.red, 255);
  });
}
