import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumadrive_control/controllers/mesh_controller.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/widgets/firmware_versions_dialog.dart';

import 'connection_fakes.dart';

class VersionsMeshController extends MeshController {
  static bool fail = false;
  @override
  Future<MeshState> build() async => MeshState(
    interopState: MeshInteropState(), masterDevice: firstController,
  );
  @override
  Future<MatrixDocument> readMatrix() async {
    if (fail) throw StateError('Disconnected');
    return MatrixDocument(
      masterMac: [2, 0, 0, 0, 0, 1],
      masterFirmwareVersion: 'controller-build',
      nodes: [
        MatrixInputNode(nodeMac: [2, 0, 0, 0, 0, 1], online: true, firmwareVersion: 'controller-build'),
        MatrixInputNode(nodeMac: [2, 0, 0, 0, 0, 2], online: true, firmwareVersion: 'node-build'),
        MatrixInputNode(nodeMac: [2, 0, 0, 0, 0, 3], online: false, firmwareVersion: 'old-build'),
        MatrixInputNode(nodeMac: [2, 0, 0, 0, 0, 4], online: false),
      ],
    );
  }
}

void main() {
  testWidgets('shows versions for the controller and nodes, including unknown and cached offline values', (tester) async {
    VersionsMeshController.fail = false;
    await tester.pumpWidget(ProviderScope(
      overrides: [meshControllerProvider.overrideWith(VersionsMeshController.new)],
      child: const MaterialApp(home: Scaffold(body: FirmwareVersionsDialog())),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Controller'), findsOneWidget);
    expect(find.text('controller-build'), findsOneWidget);
    expect(find.text('node-build'), findsOneWidget);
    expect(find.text('old-build · Offline, last known'), findsOneWidget);
    expect(find.text('Unknown · Offline'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('offers a retry when versions cannot be loaded', (tester) async {
    VersionsMeshController.fail = true;
    await tester.pumpWidget(ProviderScope(
      overrides: [meshControllerProvider.overrideWith(VersionsMeshController.new)],
      child: const MaterialApp(home: Scaffold(body: FirmwareVersionsDialog())),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('Could not read firmware versions'), findsOneWidget);
    VersionsMeshController.fail = false;
    await tester.tap(find.text('Refresh')); await tester.pumpAndSettle();
    expect(find.text('controller-build'), findsOneWidget);
  });
}
