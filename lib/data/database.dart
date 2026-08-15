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

@DriftDatabase(tables: [SavedDevices])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

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
}
