import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumadrive_control/controllers/layout_editor_controller.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/widgets/pages/layout_editor_page.dart';

import 'layout_fakes.dart';

void main() {
  setUpAll(() async {
    for (final font in {
      'Roboto': 'LAYOUT_TEST_FONT',
      'MaterialIcons': 'LAYOUT_TEST_ICONS',
    }.entries) {
      final path = Platform.environment[font.value];
      if (path == null) continue;
      final loader = FontLoader(font.key)
        ..addFont(File(path).readAsBytes().then(ByteData.sublistView));
      await loader.load();
    }
  });
  Future<LayoutEditorController> open(
    WidgetTester tester, {
    double width = 390,
  }) async {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final snapshot = layoutFixture(placed: true);
    snapshot.outputs.first.maxPixelCount = 2048;
    final editor = LayoutEditorController(
      repository: FakeLayoutRepository(snapshot: snapshot),
      store: MemoryLayoutStore(),
      pollInterval: Duration.zero,
    );
    addTearDown(editor.dispose);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          home: RepaintBoundary(
            key: const ValueKey('car-capture'),
            child: LayoutEditorPage(controller: editor),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return editor;
  }

  testWidgets(
    'selected output assigns to the selected car segment after scrolling',
    (tester) async {
      final editor = await open(tester, width: 320);
      final segment = find.byKey(const ValueKey('car-16'));
      await tester.ensureVisible(segment);
      await tester.pumpAndSettle();
      await tester.tap(segment);
      await tester.pumpAndSettle();
      expect(editor.selectedCarPosition, CarPosition.FRONT_RIGHT_DOOR);
      editor.select(placementKey(editor.layout.single));
      await tester.pumpAndSettle();
      final assign = find.byKey(const ValueKey('assign-selected-segment'));
      await tester.scrollUntilVisible(
        assign,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Assign to Front right door'), findsOneWidget);
      await tester.tap(assign);
      await tester.pumpAndSettle();
      expect(editor.layout.single.carPosition, CarPosition.FRONT_RIGHT_DOOR);
      expect(editor.layout.single.to, 60);
      expect(tester.widget<FilledButton>(assign).onPressed, isNull);
      expect((editor.repository as FakeLayoutRepository).applied, isNull);
      await tester.drag(find.byType(ListView).first, const Offset(0, 3000));
      await tester.pumpAndSettle();
      expect(editor.selectedCarPosition, CarPosition.FRONT_RIGHT_DOOR);
      final rear = find.byKey(const ValueKey('car-1'));
      await tester.ensureVisible(rear);
      await tester.pumpAndSettle();
      await tester.tap(rear);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Handle'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Handle'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        assign,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Assign to Rear left door handle'), findsOneWidget);
      await tester.tap(assign);
      await tester.pumpAndSettle();
      expect(editor.layout.single.carPosition, CarPosition.REAR_LEFT_HANDLE);
      expect(editor.dirty, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('background refresh keeps Identify and Apply enabled', (
    tester,
  ) async {
    final editor = await open(tester);
    await tester.tap(find.text('Advanced'));
    await tester.pumpAndSettle();
    editor.select(placementKey(editor.layout.single));
    editor.resize(editor.selectedKey!, '61');
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -1400));
    await tester.pumpAndSettle();
    final repository = editor.repository as FakeLayoutRepository;
    final gate = Completer<void>();
    repository.readDelay = gate.future;
    final refresh = editor.refresh();
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('apply-layout')))
          .onPressed,
      isNotNull,
    );
    expect(
      tester
          .widget<OutlinedButton>(
            find.widgetWithText(OutlinedButton, 'Identify lights'),
          )
          .onPressed,
      isNotNull,
    );
    gate.complete();
    await refresh;
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('manual layout center can be changed and reset', (tester) async {
    final editor = await open(tester);
    final toggle = find.widgetWithText(SwitchListTile, 'Automatic center');
    await tester.scrollUntilVisible(toggle, 250, scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(editor.centerIndex, 30);
    final slider = find.byKey(const ValueKey('layout-center-slider'));
    await tester.ensureVisible(slider);
    await tester.pumpAndSettle();
    await tester.tapAt(tester.getTopLeft(slider) + Offset(tester.getSize(slider).width * .25, 20));
    await tester.pumpAndSettle();
    expect(editor.centerIndex, lessThan(30));
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(editor.centerIndex, isNull);
  });

  testWidgets('output name keeps focus through status changes and refresh', (
    tester,
  ) async {
    final editor = await open(tester);
    editor.select(placementKey(editor.layout.single));
    await tester.pumpAndSettle();
    final name = find.byKey(const ValueKey('layout-name'));
    await tester.ensureVisible(name);
    await tester.pumpAndSettle();
    await tester.tap(name);
    await tester.enterText(name, 'Front strip');
    await tester.pumpAndSettle();
    final focus = tester.widget<TextField>(name).focusNode!;
    expect(focus.hasFocus, isTrue);
    editor.connectionChanged(false);
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isTrue);
    expect(tester.widget<TextField>(name).controller!.text, 'Front strip');
    editor.connectionChanged(true);
    await tester.pumpAndSettle();
    expect(focus.hasFocus, isTrue);
    expect(tester.widget<TextField>(name).controller!.text, 'Front strip');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'simple car diagram assigns a light and exposes door handles and pockets',
    (tester) async {
      final editor = await open(tester);
      expect(find.byKey(const ValueKey('car-diagram')), findsOneWidget);
      expect(editor.dirty, isFalse);
      final capture = Platform.environment['CAR_LAYOUT_SCREENSHOT'];
      if (capture != null) {
        await tester.runAsync(() async {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('car-capture')),
          );
          final image = await boundary.toImage(pixelRatio: 2);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(capture).writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }
      final assign = find.byKey(const ValueKey('assign-car-output-1-1'));
      await tester.ensureVisible(assign);
      await tester.pumpAndSettle();
      await tester.tap(assign);
      await tester.pumpAndSettle();
      await tester.tap(find.text('LED strip · driver 1 · 03:04:05').last);
      await tester.pumpAndSettle();
      expect(editor.layout.single.carPosition, CarPosition.REAR_LEFT_DOOR);
      expect(editor.layout.single.from, 0);
      expect(editor.layout.single.to, 60);
      final repository = editor.repository as FakeLayoutRepository;
      expect(repository.identifiedIndex, 0);
      expect(repository.identifiedLength, 60);
      expect(repository.identifiedReversed, isFalse);
      final selector = find.byKey(const ValueKey('assign-car-output-1-1'));
      final length = find.byKey(const ValueKey('layout-length'));
      expect(find.text('Selected output'), findsNothing);
      expect(
        tester.getTopLeft(length).dy,
        greaterThan(tester.getBottomLeft(selector).dy),
      );
      await tester.ensureVisible(length);
      await tester.enterText(length, '61');
      await tester.pumpAndSettle();
      expect(editor.lengthFor(editor.layout.single), 61);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Handle'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Handle'));
      await tester.pumpAndSettle();
      expect(find.text('Rear left door handle'), findsWidgets);
      await tester.tap(find.text('Pocket'));
      await tester.pumpAndSettle();
      expect(find.text('Rear left door pocket'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'simple and advanced share one draft and length can grow beyond firmware default',
    (tester) async {
      final editor = await open(tester, width: 320);
      expect(
        tester
            .getRect(find.byKey(const ValueKey('car-5')))
            .overlaps(tester.getRect(find.byKey(const ValueKey('car-8')))),
        isFalse,
      );
      final before = editor.layout.single.writeToBuffer();
      await tester.tap(find.text('Advanced'));
      await tester.pumpAndSettle();
      expect(editor.layout.single.writeToBuffer(), before);
      expect(find.text('View zoom'), findsOneWidget);
      expect(find.byTooltip('Zoom in view'), findsOneWidget);
      editor.select(placementKey(editor.layout.single));
      await tester.pumpAndSettle();
      final length = find.byKey(const ValueKey('layout-length'));
      await tester.ensureVisible(length);
      await tester.enterText(length, '120');
      await tester.pumpAndSettle();
      expect(editor.layout.single.to, 120);
      await tester.enterText(length, '0');
      await tester.pumpAndSettle();
      expect(editor.canApply, isFalse);
      await tester.enterText(length, '120');
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).first, const Offset(0, 2200));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simple'));
      await tester.pumpAndSettle();
      expect(editor.layout.single.to, 120);
      expect(
        editor.layout.single.carPosition,
        CarPosition.POSITION_UNSPECIFIED,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
