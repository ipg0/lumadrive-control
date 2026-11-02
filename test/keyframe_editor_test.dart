import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/widgets/matrix/animation_editor.dart';
import 'package:lumadrive_control/widgets/matrix/keyframe_editor.dart';

void main() {
  test('preview samples motion, wrapping, opacity and track order', () {
    final effect = MatrixEffect(
      kind: MatrixEffect_Kind.KEYFRAMES,
      keyframes: [
        MatrixKeyframe(
          trackId: 1,
          timeMs: 0,
          position: 0,
          width: 2,
          red: 255,
          alpha: 255,
          wrap: true,
        ),
        MatrixKeyframe(
          trackId: 1,
          timeMs: 1000,
          position: 4,
          width: 2,
          red: 255,
          alpha: 255,
          wrap: true,
        ),
      ],
    );
    expect(validateKeyframes(effect), isNull);
    expect(sampleKeyframes(effect, 500, 2, 4), const Color(0xffff0000));
    expect(sampleKeyframes(effect, 500, 0, 4), Colors.transparent);
    expect(sampleKeyframes(effect, 1000, 0, 4), const Color(0xffff0000));
    effect.keyframes.addAll([
      MatrixKeyframe(
        trackId: 2,
        timeMs: 0,
        allPixels: true,
        blue: 255,
        alpha: 128,
      ),
      MatrixKeyframe(
        trackId: 2,
        timeMs: 1000,
        allPixels: true,
        blue: 255,
        alpha: 128,
      ),
    ]);
    expect(sampleKeyframes(effect, 0, 0, 4), const Color(0xff7f0080));
    effect.loop = true;
    expect(hasKeyframeLoopJump(effect, 4), isFalse);
    effect.keyframes[1].position = 3;
    expect(hasKeyframeLoopJump(effect, 4), isTrue);
    effect.keyframes[1].timeMs = 0;
    expect(validateKeyframes(effect), isNotNull);
  });

  testWidgets(
    'create, edit and save a keyframed animation on a narrow screen',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
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
                canvasSize: 60,
        centerIndex: 12,
                onCancel: () {},
                onSave: (effect) {
                  saved = effect;
                  return true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('animation-kind')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keyframes').last);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('keyframe-canvas')), findsOneWidget);
    expect(find.byKey(const ValueKey('keyframe-center-marker')), findsOneWidget);
    expect(find.text('Center: 12'), findsOneWidget);
      final add = find.byKey(const ValueKey('add-keyframe'));
      await tester.ensureVisible(add);
      await tester.pumpAndSettle();
      await tester.tap(add);
      await tester.pumpAndSettle();
      expect(find.textContaining('3/16 keyframes'), findsOneWidget);
      final handle = find.byKey(const ValueKey('keyframe-width-handle'));
      await tester.ensureVisible(handle);
      await tester.pumpAndSettle();
      await tester.drag(handle, const Offset(80, 0));
      await tester.pumpAndSettle();
      final position = find.byKey(const ValueKey('keyframe-position'));
      await tester.ensureVisible(position);
      await tester.pumpAndSettle();
      await tester.enterText(position, '20.5');
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      final save = find.byKey(const ValueKey('save-animation'));
      await tester.ensureVisible(save);
      await tester.pumpAndSettle();
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(saved, isNotNull);
      expect(saved!.keyframes.length, 3);
      expect(saved!.keyframes[1].timeMs, 1000);
      expect(saved!.keyframes[1].position, closeTo(20.5, .001));
      expect(saved!.keyframes[1].width, greaterThan(6));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('rejects overlapping times before saving', (tester) async {
    MatrixEffect? saved;
    final effect = MatrixEffect(
      kind: MatrixEffect_Kind.KEYFRAMES,
      keyframes: defaultKeyframes(20),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AnimationEditor(
              initial: effect,
              canvasSize: 20,
              onCancel: () {},
              onSave: (value) {
                saved = value;
                return true;
              },
            ),
          ),
        ),
      ),
    );
    final last = find.byKey(const ValueKey('keyframe-1-2000'));
    await tester.ensureVisible(last);
    await tester.pumpAndSettle();
    await tester.tap(last);
    await tester.pumpAndSettle();
    final time = find.byKey(const ValueKey('keyframe-time'));
    await tester.ensureVisible(time);
    await tester.pumpAndSettle();
    await tester.enterText(time, '0');
    await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final save = find.byKey(const ValueKey('save-animation'));
    await tester.ensureVisible(save);
    await tester.pumpAndSettle();
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(saved, isNull);
    expect(
      find.text('Use a time between neighbouring keyframes.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
