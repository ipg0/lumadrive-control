import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';
import 'package:lumadrive_control/controllers/mesh_controller.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/widgets/pages/device_home_page.dart';

import 'connection_fakes.dart';

class AlignmentMeshController extends MeshController {
  @override
  Future<MeshState> build() async => MeshState(
    interopState: MeshInteropState(),
    masterDevice: firstController,
  );
  void fail(String message) =>
      state = AsyncError(StateError(message), StackTrace.empty);
}

void main() {
  testWidgets(
    'disconnected screen stays centered after transitions and timer updates',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          bleControllerProvider.overrideWith(TestConnectionController.new),
          meshControllerProvider.overrideWith(AlignmentMeshController.new),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: DeviceHomePage()),
        ),
      );
      await tester.pumpAndSettle();
      final mesh = container.read(
        meshControllerProvider.notifier,
      ) as AlignmentMeshController;
      for (final error in [
        'Disconnected',
        'Connection to the lighting controller was unexpectedly interrupted. Please reconnect.',
      ]) {
        mesh.fail(error);
        await tester.pumpAndSettle();
        final content = find.byKey(const ValueKey('mesh-error'));
        final center = tester.getCenter(find.byType(Scaffold)).dx;
        expect(tester.getCenter(content).dx, closeTo(center, 0.1));
        await tester.pump(const Duration(seconds: 2));
        expect(tester.getCenter(content).dx, closeTo(center, 0.1));
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox());
    },
  );
}
