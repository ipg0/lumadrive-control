import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/widgets/matrix/animation_editor.dart';
import 'package:lumadrive_control/widgets/matrix/simple_animation_preview.dart';

void main() {
  test('preview clips the effect and uses region-relative positions', () {
    final effect = MatrixEffect(
      kind: MatrixEffect_Kind.FILL,
      red: 255,
      alpha: 255,
      regionStart: 2,
      regionEnd: 6,
    );
    expect(sampleSimpleAnimation(effect, 0.5, 1, 8), Colors.transparent);
    expect(sampleSimpleAnimation(effect, 0.5, 2, 8), const Color(0xffff0000));
    expect(sampleSimpleAnimation(effect, 0.5, 4, 8), Colors.transparent);
    expect(sampleSimpleAnimation(effect, 1, 6, 8), Colors.transparent);
  });

  testWidgets(
    'selecting named and reversed sources fills the region boundaries',
    (tester) async {
      MatrixEffect? saved;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AnimationEditor(
                initial: MatrixEffect(
                  kind: MatrixEffect_Kind.STATIC_COLOR,
                  alpha: 255,
                ),
                canvasSize: 20,
                layout: [
                  MatrixLayout(
                    nodeMac: [2, 1, 2, 3, 4, 5],
                    driver: MatrixDriver.HC595,
                    from: 12,
                    to: 10,
                    name: 'Door light',
                  ),
                  MatrixLayout(
                    nodeMac: [4, 1, 2, 3, 4, 5],
                    driver: MatrixDriver.HC595,
                    from: 10,
                    to: 18,
                  ),
                ],
                outputCatalog: [
                  LayoutOutput(
                    nodeMac: [4, 1, 2, 3, 4, 5],
                    driver: MatrixDriver.HC595,
                    driverKind: MatrixDriverKind.LED_STRIP,
                  ),
                ],
                nodeNames: const {'04:01:02:03:04:05': 'Rear'},
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
      final from = find.byKey(const ValueKey('animation-region-from-source'));
      await tester.ensureVisible(from);
      await tester.pumpAndSettle();
      await tester.tap(from);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Door light').last);
      await tester.pumpAndSettle();
      final to = find.byKey(const ValueKey('animation-region-to-source'));
      await tester.ensureVisible(to);
      await tester.pumpAndSettle();
      await tester.tap(to);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Strip (2) - Rear').last);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextFormField>(
              find.byKey(const ValueKey('animation-region-start')),
            )
            .controller!
            .text,
        '10',
      );
      expect(
        tester
            .widget<TextFormField>(
              find.byKey(const ValueKey('animation-region-end')),
            )
            .controller!
            .text,
        '18',
      );
      final save = find.byKey(const ValueKey('save-animation'));
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pump();
      expect(saved!.regionStart, 10);
      expect(saved!.regionEnd, 18);
    },
  );
}
