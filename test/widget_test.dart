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
  TestWidgetsFlutterBinding.ensureInitialized();
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
    bool placed = false,
    double width = 390,
  }) async {
    tester.view.physicalSize = Size(width, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final editor = LayoutEditorController(
      repository: FakeLayoutRepository(snapshot: layoutFixture(placed: placed)),
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
            key: const ValueKey('capture'),
            child: LayoutEditorPage(controller: editor, initialAdvanced: true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return editor;
  }

  testWidgets('empty layout discovers outputs and supports placement', (
    tester,
  ) async {
    final editor = await open(tester);
    expect(find.text('Car layout'), findsOneWidget);
    expect(find.text('Arrange your lighting'), findsOneWidget);
    await tester.tap(find.byTooltip('Place LED strip · driver 1'));
    await tester.pumpAndSettle();
    expect(editor.layout.single.to, 60);
    expect(editor.layout.single.name, 'LED strip · driver 1 · 03:04:05');
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('layout-name')))
          .controller!
          .text,
      editor.layout.single.name,
    );
    expect(find.text('Selected output'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'two module LEDs are points with independent positions and no reversal control',
    (tester) async {
      final editor = await open(tester);
      final repository = editor.repository as FakeLayoutRepository;
      repository.snapshot.outputs
        ..clear()
        ..addAll([
          for (var source = 0; source < 2; source++)
            LayoutOutput(
              nodeMac: layoutSlaveMac,
              driver: MatrixDriver.DRIVER_6,
              driverKind: MatrixDriverKind.RGB_LED_MODULE,
              sourceIndex: source,
              pixelCount: 1,
              known: true,
              ready: true,
              online: true,
            ),
        ]);
      await editor.refresh();
      for (final output in editor.snapshot!.outputs.where(isPointSource)) {
        editor.place(output);
        editor.move(editor.selectedKey!, output.sourceIndex == 0 ? 10 : 70);
      }
      expect(editor.selected, isNotNull);
      expect(isPointSource(editor.outputFor(editor.selectedKey!)), isTrue);
      await tester.pumpAndSettle();
      expect(find.textContaining('RGB LED 1'), findsWidgets);
      expect(find.textContaining('RGB LED 2'), findsWidgets);
      expect(find.text('at 10'), findsOneWidget);
      expect(find.text('at 70'), findsOneWidget);
      await tester.drag(find.byType(ListView).first, const Offset(0, -350));
      await tester.pumpAndSettle();
      expect(find.text('Selected light'), findsOneWidget);
      expect(find.widgetWithText(SwitchListTile, 'Reverse direction'), findsNothing);
      expect(editor.layout.map((row) => row.sourceIndex), [0, 1]);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'precise position, reversal, naming and apply work on a narrow phone',
    (tester) async {
      final editor = await open(tester, width: 320);
      editor.place(editor.snapshot!.outputs[1]);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('layout-position')));
      await tester.enterText(
        find.byKey(const ValueKey('layout-position')),
        '10',
      );
      await tester.pumpAndSettle();
      final reverse = find.widgetWithText(SwitchListTile, 'Reverse direction');
      await tester.ensureVisible(reverse);
      await tester.tap(reverse);
      await tester.pumpAndSettle();
      expect(editor.selected!.from, 12);
      expect(editor.selected!.to, 10);
      await tester.ensureVisible(find.byKey(const ValueKey('layout-name')));
      await tester.enterText(
        find.byKey(const ValueKey('layout-name')),
        'Indicators',
      );
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('apply-layout')));
      await tester.pumpAndSettle();
      expect(editor.layout.single.name, 'Indicators');
      expect(editor.dirty, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'tiny overlapping modules have a selectable touch target and shared ruler',
    (tester) async {
      final editor = await open(tester, placed: true);
      editor.place(editor.snapshot!.outputs[1]);
      editor.move(editor.selectedKey!, 10);
      editor.reverse(editor.selectedKey!);
      await tester.pumpAndSettle();
      final bar = find.byKey(ValueKey('layout-bar-${editor.selectedKey}'));
      expect(tester.getSize(bar).width, greaterThanOrEqualTo(48));
      await tester.ensureVisible(bar);
      await tester.tap(bar);
      await tester.pumpAndSettle();
      expect(find.text('Shared canvas · 60 pixels'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final path = Platform.environment['LAYOUT_SCREENSHOT'];
      if (path != null) {
        await tester.drag(find.byType(ListView).first, const Offset(0, 1500));
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('capture')),
          );
          final image = await boundary.toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(path).writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }
    },
  );
  testWidgets(
    'offline editing keeps the draft and displays the disconnected state',
    (tester) async {
      final editor = await open(tester, placed: true);
      (editor.repository as FakeLayoutRepository).disconnected = true;
      await editor.refresh();
      await tester.pumpAndSettle();
      expect(find.textContaining('Controller disconnected'), findsOneWidget);
      expect(editor.layout.single.name, 'Left footwell');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('zoom, drag and backgrounding preserve an editable draft', (
    tester,
  ) async {
    final editor = await open(tester, placed: true);
    final bar = find.byKey(
      ValueKey(
        'layout-bar-${editor.layout.first.nodeMac.join(':')}/${editor.layout.first.driver.value}',
      ),
    );
    final initialWidth = tester.getSize(bar).width;
    await tester.tap(find.byTooltip('Zoom in view'));
    await tester.pumpAndSettle();
    expect(tester.getSize(bar).width, greaterThan(initialWidth));
    await tester.drag(bar, const Offset(36, 0));
    await tester.pumpAndSettle();
    expect(editor.layout.single.from, greaterThan(0));
    expect(editor.dirty, isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pumpAndSettle();
    expect(
      (editor.store as MemoryLayoutStore).value!.layout.single.from,
      editor.layout.single.from,
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(tester.takeException(), isNull);
  });
}
