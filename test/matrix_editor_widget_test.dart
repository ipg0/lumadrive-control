import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumadrive_control/controllers/matrix_editor_controller.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/widgets/pages/matrix_editor_page.dart';
import 'package:lumadrive_control/widgets/matrix/simple_animation_preview.dart';

import 'matrix_editor_fakes.dart';

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
  Future<MatrixEditorController> open(
    WidgetTester tester, {
    double width = 390,
    MatrixConfig? config,
  }) async {
    tester.view.physicalSize = Size(width, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = MatrixEditorController(
      repository: FakeMatrixEditorRepository()
        ..document = editorDocument(config),
      store: MemoryMatrixStore(),
      pollInterval: Duration.zero,
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
          ),
          home: RepaintBoundary(
            key: const ValueKey('matrix-capture'),
            child: MatrixEditorPage(controller: controller),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  testWidgets(
    'creates an animation inside an entry while keeping entry settings',
    (tester) async {
      final empty = editorFixture()
        ..effects.clear()
        ..entries.clear()
        ..sources.clear()
        ..conditions.clear();
      final editor = await open(tester, width: 320, config: empty);
      await tester.tap(find.byKey(const ValueKey('add-entry')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('entry-name')),
        'Brake warning',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('entry-priority')));
      await tester.enterText(
        find.byKey(const ValueKey('entry-priority')),
        '77',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      final create = find.byKey(const ValueKey('create-entry-animation'));
      await tester.ensureVisible(create);
      await tester.pumpAndSettle();
      await tester.tap(create);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('entry-name')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const ValueKey('animation-name')));
      await tester.enterText(
        find.byKey(const ValueKey('animation-name')),
        'Quick pulse',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('animation-kind')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('animation-kind')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Breathe').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      expect(find.text('Use animation'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      expect(editor.config.effects, isEmpty);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('entry-name')))
            .controller!
            .text,
        'Brake warning',
      );
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('entry-priority')))
            .controller!
            .text,
        '77',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('save-entry')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('save-entry')));
      await tester.pumpAndSettle();
      expect(editor.config.entries.single.name, 'Brake warning');
      expect(editor.config.entries.single.priority, 77);
      expect(
        editor.config.entries.single.effectId,
        editor.config.effects.single.id,
      );
      expect(editor.config.effects.single.name, 'Quick pulse');
      expect(editor.config.effects.single.kind, MatrixEffect_Kind.BREATHE);
      expect((editor.repository as FakeMatrixEditorRepository).applied, isNull);
      expect(editor.validationError, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('cancelling an entry discards its unused inline animation', (
    tester,
  ) async {
    final editor = await open(tester);
    await tester.tap(find.byKey(const ValueKey('add-entry')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('create-entry-animation')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-animation')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(editor.config.effects.length, 1);
    expect(editor.config.entries.length, 1);
    expect(editor.dirty, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'pure primary presets apply immediately and a failed Apply can be retried',
    (tester) async {
      final editor = await open(tester);
      final repository = editor.repository as FakeMatrixEditorRepository;
      await tester.tap(find.text('Animations (1)'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('matrix-animation-1')));
      await tester.pumpAndSettle();
      for (final hex in ['FF0000', '0000FF', '00FF00']) {
        final swatch = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics && widget.properties.label == 'Color #$hex',
        );
        await tester.ensureVisible(swatch);
        await tester.pumpAndSettle();
        await tester.tap(swatch);
        await tester.pumpAndSettle();
      }
      repository.failApply = true;
      await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Unable to persist matrix'), findsWidgets);
      expect(find.byKey(const ValueKey('animation-name')), findsOneWidget);
      expect(
        MatrixConfig.fromBuffer(repository.document.config)
            .effects
            .single
            .green,
        0,
      );
      repository.failApply = false;
      await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      expect(repository.applied!.effects.single.red, 0);
      expect(repository.applied!.effects.single.green, 255);
      expect(repository.applied!.effects.single.blue, 0);
      expect(editor.dirty, isFalse);
      expect(find.byKey(const ValueKey('animation-name')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('reads current MCU state without replacing a draft', (
    tester,
  ) async {
    final editor = await open(tester);
    editor.saveEffect(editor.effect(1)!.deepCopy()..name = 'My draft');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('read-current-matrix')));
    await tester.pumpAndSettle();
    expect(
      find.text('Read from MCU: 1 entries · 1 animations · 1 outputs'),
      findsOneWidget,
    );
    expect(editor.effect(1)!.name, 'My draft');
    expect(editor.dirty, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rainbow offers opacity and shared canvas geometry', (
    tester,
  ) async {
    final editor = await open(tester);
    editor.saveEffect(
      MatrixEffect(
        id: 2,
        name: 'Rainbow',
        kind: MatrixEffect_Kind.RAINBOW,
        alpha: 255,
        periodMs: 8000,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Animations (2)'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('matrix-animation-2')));
    await tester.pumpAndSettle();
    expect(find.text('Opacity'), findsOneWidget);
    expect(find.text('Primary color'), findsNothing);
    await tester.ensureVisible(
      find.byKey(const ValueKey('animation-wavelength')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('animation-wavelength')),
      '30',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
    await tester.tap(find.byKey(const ValueKey('save-animation')));
    await tester.pumpAndSettle();
    expect(editor.effect(2)!.wavelengthPixels, 30);
    expect(editor.effect(2)!.periodMs, 8000);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'creates a simple animation and applies it without changing the layout',
    (tester) async {
      final editor = await open(tester, width: 320);
      await tester.tap(find.text('Animations (1)'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('add-animation')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('animation-name')),
        'Warning blink',
      );
      await tester.tap(find.byKey(const ValueKey('animation-kind')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Blink').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('animation-period')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('animation-period')),
        '500',
      );
      await tester.enterText(
        find.byKey(const ValueKey('animation-duty')),
        '25',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
      await tester.tap(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      expect(editor.config.effects.last.name, 'Warning blink');
      expect(editor.config.effects.last.kind, MatrixEffect_Kind.BLINK);
      expect(editor.config.effects.last.alpha, 255);
      expect(editor.config.effects.last.periodMs, 500);
      expect(editor.config.effects.last.dutyPercent, 25);
      expect(
        (editor.repository as FakeMatrixEditorRepository).applied,
        isNotNull,
      );
      expect(editor.dirty, isFalse);
      expect(editor.config.layout.single.to, 60);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('edits a slave GPIO trigger and rejects invalid priority', (
    tester,
  ) async {
    final editor = await open(tester);
    await tester.tap(find.byKey(const ValueKey('matrix-entry-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('entry-trigger')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('GPIO edge').last);
    await tester.pumpAndSettle();
    final node = find.byWidgetPredicate(
      (w) => w is DropdownButtonFormField<String>,
    );
    await tester.ensureVisible(node);
    await tester.tap(node);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Node ·').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('entry-priority')));
    await tester.enterText(find.byKey(const ValueKey('entry-priority')), '256');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-entry')));
    await tester.tap(find.byKey(const ValueKey('save-entry')));
    await tester.pumpAndSettle();
    expect(find.text('Enter 0–255'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('entry-priority')), '10');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-entry')));
    await tester.tap(find.byKey(const ValueKey('save-entry')));
    await tester.pumpAndSettle();
    final trigger = editor.source(editor.config.entries.single.sourceId)!;
    expect(trigger.kind, MatrixSource_Kind.GPIO_EDGE);
    expect(trigger.nodeMac.first, 4);
    expect(trigger.gpio, 12);
    expect(editor.config.entries.single.priority, 10);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'flowing gradient exposes geometry, colors and preview with no overflow',
    (tester) async {
      final editor = await open(tester);
      editor.saveEffect(
        MatrixEffect(
          id: 2,
          name: 'Cabin flow',
          kind: MatrixEffect_Kind.FLOWING_GRADIENT,
          red: 255,
          alpha: 255,
          secondaryColor: MatrixColor(blue: 255, alpha: 128),
          periodMs: 3000,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Animations (2)'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('matrix-animation-2')));
      await tester.pumpAndSettle();
      expect(find.text('Color 2'), findsOneWidget);
      await tester.ensureVisible(
        find.byKey(const ValueKey('animation-wavelength')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('animation-wavelength')),
        '20',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Reverse flow'));
      await tester.tap(find.text('Reverse flow'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
      await tester.tap(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      expect(editor.effect(2)!.reverse, isTrue);
      expect(editor.effect(2)!.wavelengthPixels, 20);
      expect(editor.effect(2)!.secondaryColor.alpha, 128);
      expect(tester.takeException(), isNull);
      final path = Platform.environment['MATRIX_SCREENSHOT'];
      if (path != null) {
        await tester.drag(find.byType(ListView).first, const Offset(0, 1600));
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('matrix-capture')),
          );
          final image = await boundary.toImage(),
              data = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(path).writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }
    },
  );
  testWidgets(
    'gradient palette can add, reorder, remove and save eight colors',
    (tester) async {
      final editor = await open(tester);
      editor.saveEffect(
        MatrixEffect(
          id: 2,
          name: 'Palette',
          kind: MatrixEffect_Kind.FLOWING_GRADIENT,
          red: 255,
          alpha: 255,
          secondaryColor: MatrixColor(blue: 255, alpha: 128),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Animations (2)'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('matrix-animation-2')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<IconButton>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is IconButton && widget.tooltip == 'Remove color 1',
              ),
            )
            .onPressed,
        isNull,
      );
      for (var i = 0; i < 6; i++) {
        await tester.ensureVisible(
          find.byKey(const ValueKey('add-gradient-color')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('add-gradient-color')));
        await tester.pumpAndSettle();
      }
      expect(
        tester
            .widget<TextButton>(
              find.byKey(const ValueKey('add-gradient-color')),
            )
            .onPressed,
        isNull,
      );
      await tester.ensureVisible(find.byTooltip('Move color 2 earlier'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Move color 2 earlier'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Remove color 3'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Remove color 3'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('save-animation')));
      await tester.pumpAndSettle();
      final stops = editor.effect(2)!.gradientColors;
      expect(stops, hasLength(7));
      expect(stops[0].blue, 255);
      expect(stops[0].alpha, 128);
      expect(stops[1].red, 255);
      expect(stops[2].green, 255);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('on boot saves a trigger without GPIO settings', (tester) async {
    final editor = await open(tester);
    await tester.tap(find.byKey(const ValueKey('matrix-entry-1')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('entry-trigger')));
    await tester.tap(find.byKey(const ValueKey('entry-trigger')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('On boot').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-entry')));
    await tester.tap(find.byKey(const ValueKey('save-entry')));
    await tester.pumpAndSettle();
    final source = editor.source(editor.config.entries.single.sourceId)!;
    expect(source.kind, MatrixSource_Kind.ON_BOOT);
    expect(source.nodeMac, isEmpty);
    expect(editor.canApply, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets('new entry suggests names and allows an opaque background', (
    tester,
  ) async {
    final config = editorFixture()..modes.add(MatrixMode(id: 1, name: 'Night'));
    final editor = await open(tester, config: config);
    await tester.tap(find.byKey(const ValueKey('add-entry')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('entry-transparency')), findsNothing);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('entry-priority')))
          .controller!
          .text,
      '15',
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('entry-name')))
          .controller!
          .text,
      contains('Default state'),
    );
    await tester.ensureVisible(find.byKey(const ValueKey('entry-trigger')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('entry-trigger')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('On mode switched').last);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const ValueKey('entry-transparency')),
          )
          .value,
      isTrue,
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('create-entry-animation')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('create-entry-animation')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('animation-name')))
          .controller!
          .text,
      'Static color',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('animation-kind')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('animation-kind')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Blink').last);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('animation-name')))
          .controller!
          .text,
      'Blink',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('animation-duration')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('animation-duration')),
      '1200',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-animation')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('entry-transparency')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('entry-transparency')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('entry-mode')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('entry-mode')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mode: Night').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-entry')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-entry')));
    await tester.pumpAndSettle();
    expect(editor.config.entries, hasLength(2));
    final foreground = editor.config.entries.last;
    expect(foreground.name, 'Blink · Mode switched');
    expect(foreground.priority, 15);
    expect(foreground.opaqueBackground, isTrue);
    expect(editor.effect(foreground.effectId)!.durationMs, 1200);
    expect(editor.config.conditions.last.modeId, 1);
  });
  testWidgets('one-shot fill derives pass time from duration', (tester) async {
    final editor = await open(tester);
    await tester.tap(find.byKey(const ValueKey('matrix-entry-1')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('create-entry-animation')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('create-entry-animation')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('animation-kind')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('animation-kind')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fill').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('fill-once')), findsOneWidget);
    expect(find.byKey(const ValueKey('animation-period')), findsNothing);
    await tester.ensureVisible(
      find.byKey(const ValueKey('animation-duration')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('animation-duration')),
      '2400',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-animation')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-animation')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('save-entry')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-entry')));
    await tester.pumpAndSettle();
    final fill = editor.config.effects.singleWhere(
      (e) => e.kind == MatrixEffect_Kind.FILL,
    );
    expect(fill.loop, isFalse);
    expect(fill.durationMs, 2400);
    expect(fill.periodMs, 2400);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'Back closes an unfinished form and disconnect preserves a completed draft',
    (tester) async {
      final editor = await open(tester);
      editor.saveEffect(editor.effect(1)!.deepCopy()..name = 'Draft');
      await tester.tap(find.byKey(const ValueKey('matrix-entry-1')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('entry-name')),
        'Not saved',
      );
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(editor.config.entries.single.name, 'Ambient');
      editor.connectionChanged(false);
      await tester.pumpAndSettle();
      expect(editor.canApply, isFalse);
      expect(editor.dirty, isTrue);
      expect(find.textContaining('Controller disconnected'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  test(
    'preview samples blink, breathe and gradient across the global canvas',
    () {
      final blink = MatrixEffect(
        kind: MatrixEffect_Kind.BLINK,
        red: 255,
        alpha: 255,
        dutyPercent: 25,
      );
      expect(sampleSimpleAnimation(blink, 0, 0, 60).a, 1);
      expect(sampleSimpleAnimation(blink, 0.5, 0, 60).a, 0);
      final breathe = blink.deepCopy()..kind = MatrixEffect_Kind.BREATHE;
      expect(sampleSimpleAnimation(breathe, 0, 0, 60).a, 0);
      expect(sampleSimpleAnimation(breathe, 0.5, 0, 60).a, 1);
      final flow = breathe.deepCopy()
        ..kind = MatrixEffect_Kind.FLOWING_GRADIENT
        ..secondaryColor = MatrixColor(blue: 255, alpha: 255);
      expect(sampleSimpleAnimation(flow, 0, 0, 60), const Color(0xffff0000));
      expect(sampleSimpleAnimation(flow, 0, 30, 60), const Color(0xff0000ff));
      expect(
        sampleSimpleAnimation(flow, 0.25, 15, 60),
        const Color(0xffff0000),
      );
      final rainbow = MatrixEffect(kind: MatrixEffect_Kind.RAINBOW, alpha: 255);
      final fill = MatrixEffect(
        kind: MatrixEffect_Kind.FILL,
        red: 255,
        alpha: 255,
        durationMs: 1000,
      );
      expect(sampleSimpleAnimation(fill, 0.5, 29, 60), const Color(0xffff0000));
      expect(sampleSimpleAnimation(fill, 0.5, 30, 60), Colors.transparent);
      expect(sampleSimpleAnimation(fill, 1, 59, 60), const Color(0xffff0000));
      fill.reverse = true;
      expect(sampleSimpleAnimation(fill, 0.5, 30, 60), const Color(0xffff0000));
      expect(sampleSimpleAnimation(fill, 0.5, 29, 60), Colors.transparent);
      flow.gradientColors.addAll([
        MatrixColor(red: 255, alpha: 255),
        MatrixColor(green: 255, alpha: 128),
        MatrixColor(blue: 255, alpha: 0),
        MatrixColor(red: 255, green: 255, blue: 255, alpha: 255),
      ]);
      expect(sampleSimpleAnimation(flow, 0, 15, 60), const Color(0x8000ff00));
      expect(sampleSimpleAnimation(flow, 0, 30, 60), const Color(0x000000ff));
      expect(
        sampleSimpleAnimation(flow, 0.125, 0, 60),
        const Color(0xffff8080),
      );
      expect(
        sampleSimpleAnimation(flow, 0.125, 15, 60),
        const Color(0xc0808000),
      );
      expect(sampleSimpleAnimation(rainbow, 0, 0, 60), const Color(0xffff0000));
      expect(
        sampleSimpleAnimation(rainbow, 0, 30, 60),
        const Color(0xff00ffff),
      );
      expect(
        sampleSimpleAnimation(rainbow, 0.25, 15, 60),
        const Color(0xffff0000),
      );
    },
  );
}
