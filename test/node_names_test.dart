import 'dart:async';

import 'package:drift/native.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';
import 'package:lumadrive_control/controllers/mesh_controller.dart';
import 'package:lumadrive_control/data/database.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/repositories/database_repository.dart';
import 'package:lumadrive_control/widgets/pages/device_home_page.dart';

import 'connection_fakes.dart';

class NamedNodesMeshController extends MeshController {
  @override
  Future<MeshState> build() async => MeshState(
    interopState: MeshInteropState(nodes: [
      MeshInteropNode(mac: [2, 0, 0, 0, 0, 1], lastSyncedAt: Int64(1000000)),
    ]),
    masterDevice: firstController,
  );
}

class NamesRepository extends Fake implements DatabaseRepository {
  final names = <String, String>{};
  final changes = StreamController<Map<String, String>>.broadcast(sync: true);
  @override
  Stream<Map<String, String>> watchNodeNames(String controllerId) async* {
    yield Map.of(names);
    yield* changes.stream;
  }

  @override
  Future<void> setNodeName(String controllerId, String nodeMac, String name) async {
    if (name.isEmpty) { names.remove(nodeMac); } else { names[nodeMac] = name; }
    changes.add(Map.of(names));
  }
}

void main() {
  test('upgrades an existing saved-device database without losing controllers', () async {
    final database = AppDatabase(NativeDatabase.memory(setup: (db) {
      db.execute('CREATE TABLE saved_devices (remote_id TEXT NOT NULL PRIMARY KEY, adv_name TEXT NOT NULL, last_connected INTEGER NOT NULL)');
      db.execute("INSERT INTO saved_devices VALUES ('controller-a', 'My controller', 1)");
      db.execute('PRAGMA user_version = 1');
    }));
    addTearDown(database.close);
    expect((await database.getAllSavedDevices()).single.advName, 'My controller');
    await database.setNodeName('controller-a', '02:00:00:00:00:01', 'Front');
    expect((await database.watchNodeNames('controller-a').first).single.name, 'Front');
  });

  test('node names persist independently per controller and can be cleared', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database.setNodeName('controller-a', '02:00:00:00:00:01', 'Front');
    await database.setNodeName('controller-b', '02:00:00:00:00:01', 'Rear');
    expect((await database.watchNodeNames('controller-a').first).single.name, 'Front');
    expect((await database.watchNodeNames('controller-b').first).single.name, 'Rear');
    await database.setNodeName('controller-a', '02:00:00:00:00:01', '');
    expect(await database.watchNodeNames('controller-a').first, isEmpty);
    expect((await database.watchNodeNames('controller-b').first).single.name, 'Rear');
  });

  testWidgets('renames and clears a node while retaining its address and status', (tester) async {
    final repository = NamesRepository();
    addTearDown(repository.changes.close);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        bleControllerProvider.overrideWith(TestConnectionController.new),
        meshControllerProvider.overrideWith(NamedNodesMeshController.new),
        databaseRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(home: DeviceHomePage()),
    ));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Node 02:00:00:00:00:01'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Node 02:00:00:00:00:01'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('node-name-input')), '  Front doors  ');
    await tester.tap(find.text('Save')); await tester.pumpAndSettle();
    expect(find.text('Front doors'), findsOneWidget);
    expect(find.text('Online · 02:00:00:00:00:01'), findsOneWidget);
    await tester.ensureVisible(find.text('Front doors'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Front doors')); await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('node-name-input')), '');
    await tester.tap(find.text('Save')); await tester.pumpAndSettle();
    expect(find.text('Node 02:00:00:00:00:01'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
