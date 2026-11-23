import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/widgets/matrix/animation_editor.dart';
import 'package:lumadrive_control/widgets/matrix/simple_animation_preview.dart';

void main() {
  test('dimming preview uses black with the configured opacity', () {
    final effect = MatrixEffect(kind: MatrixEffect_Kind.DIMMING, alpha: 128);
    expect(sampleSimpleAnimation(effect, 0, 0, 10), const Color(0x80000000));
  });

  testWidgets('dimming editor saves the selected percentage as black alpha', (
    tester,
  ) async {
    MatrixEffect? saved;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AnimationEditor(
              initial: MatrixEffect(
                kind: MatrixEffect_Kind.STATIC_COLOR,
                red: 255,
                alpha: 255,
              ),
              canvasSize: 10,
              onSave: (effect) {
                saved = effect;
                return true;
              },
              onCancel: () {},
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('animation-kind')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dimming').last);
    await tester.pumpAndSettle();
    final slider = find.byKey(const ValueKey('animation-dim-amount'));
    expect(tester.widget<Slider>(slider).value, 50);
    tester.widget<Slider>(slider).onChanged!(25);
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
    await tester.tap(find.byKey(const ValueKey('save-animation')));
    await tester.pump();
    expect(saved, isNotNull);
    expect(saved!.kind, MatrixEffect_Kind.DIMMING);
    expect(
      [saved!.red, saved!.green, saved!.blue, saved!.alpha],
      [0, 0, 0, 64],
    );
  });
}
