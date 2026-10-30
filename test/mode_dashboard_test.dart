import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumadrive_control/controllers/mesh_controller.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/repositories/matrix_client.dart';
import 'package:lumadrive_control/widgets/matrix/mode_dashboard.dart';

import 'connection_fakes.dart';
import 'matrix_editor_fakes.dart';

final modeRepository = FakeMatrixEditorRepository();

class ModeTestController extends MeshController {
  @override
  Future<MeshState> build() async => MeshState(
    interopState: MeshInteropState(),
    masterDevice: firstController,
  );
  @override
  Future<MatrixDocument> readCurrentMatrix() => modeRepository.current();
  @override
  Future<MatrixDocument> readMatrix() => modeRepository.read();
  @override
  Stream<MatrixUploadProgress> updateMatrix(MatrixUpdate update) =>
      modeRepository.apply(update);
}

void main() {
  testWidgets('create and switch modes using the saved configuration', (
    tester,
  ) async {
    modeRepository.document = editorDocument();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          meshControllerProvider.overrideWith(ModeTestController.new),
        ],
        child: const MaterialApp(home: Scaffold(body: ModeDashboard())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Default'), findsOneWidget);
    await tester.tap(find.byTooltip('Create mode'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Night');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(modeRepository.applied!.modes.single.name, 'Night');
    expect(modeRepository.applied!.activeModeId, 1);
    expect(find.text('Night'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('mode-button-0')));
    await tester.pumpAndSettle();
    expect(modeRepository.applied!.activeModeId, 0);
    expect(modeRepository.applied!.modes.single.name, 'Night');
    expect(find.text('Default'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('launchpad wraps responsively and keeps add last', (
    tester,
  ) async {
    final config = editorFixture()
      ..modes.addAll(
        List.generate(5, (i) => MatrixMode(id: i + 1, name: 'Mode ${i + 1}')),
      )
      ..activeModeId = 2;
    modeRepository.document = editorDocument(config);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(372, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          meshControllerProvider.overrideWith(ModeTestController.new),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Padding(padding: EdgeInsets.all(18), child: ModeDashboard()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    Offset position(String key) => tester.getTopLeft(find.byKey(ValueKey(key)));
    expect(position('mode-button-0').dy, position('mode-button-3').dy);
    expect(
      position('mode-button-4').dy,
      greaterThan(position('mode-button-3').dy),
    );
    expect(position('add-mode').dx, greaterThan(position('mode-button-5').dx));
    final selected = tester.widget<Semantics>(
      find
          .descendant(
            of: find.byKey(const ValueKey('mode-button-2')),
            matching: find.byType(Semantics),
          )
          .first,
    );
    expect(selected.properties.selected, isTrue);
    tester.view.physicalSize = const Size(300, 900);
    await tester.pumpAndSettle();
    expect(position('mode-button-0').dy, position('mode-button-2').dy);
    expect(
      position('mode-button-3').dy,
      greaterThan(position('mode-button-2').dy),
    );
    tester.view.physicalSize = const Size(600, 900);
    await tester.pumpAndSettle();
    expect(position('mode-button-0').dy, position('add-mode').dy);
    expect(tester.takeException(), isNull);
  });
}
