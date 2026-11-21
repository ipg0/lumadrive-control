import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class SavedDevices extends Table {
  TextColumn get remoteId => text()();
  TextColumn get advName => text()();
  DateTimeColumn get lastConnected => dateTime()();

  @override
  Set<Column> get primaryKey => {remoteId};
}

class NodeNames extends Table {
  TextColumn get controllerId => text()();
  TextColumn get nodeMac => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {controllerId, nodeMac};
}

@DriftDatabase(tables: [SavedDevices, NodeNames])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(nodeNames);
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'lumadrive_control',
      native: const DriftNativeOptions(),
    );
  }

  Future<List<SavedDevice>> getAllSavedDevices() => select(savedDevices).get();

  Future<void> upsertDevice(SavedDevicesCompanion device) =>
      into(savedDevices).insertOnConflictUpdate(device);

  Future<void> deleteDevice(String remoteId) =>
      (delete(savedDevices)..where((d) => d.remoteId.equals(remoteId))).go();

  Stream<List<SavedDevice>> watchAllSavedDevices() =>
      select(savedDevices).watch();

  Stream<List<NodeName>> watchNodeNames(String controllerId) =>
      (select(nodeNames)..where((row) => row.controllerId.equals(controllerId)))
          .watch();

  Future<void> setNodeName(String controllerId, String nodeMac, String name) {
    if (name.isEmpty) {
      return (delete(nodeNames)..where(
        (row) => row.controllerId.equals(controllerId) & row.nodeMac.equals(nodeMac),
      )).go().then((_) {});
    }
    return into(nodeNames).insertOnConflictUpdate(NodeNamesCompanion.insert(
      controllerId: controllerId, nodeMac: nodeMac, name: name,
    ));
  }
}
