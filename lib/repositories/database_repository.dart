import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/data/database.dart';

class DatabaseRepository {
  final AppDatabase _database;

  DatabaseRepository(this._database);

  Future<void> deleteDevice(String remoteId) {
    return _database.deleteDevice(remoteId);
  }

  Future<void> upsertDevice({
    required String remoteId,
    required String advName,
    required DateTime lastConnected,
  }) {
    return _database.upsertDevice(
      SavedDevicesCompanion(
        remoteId: Value(remoteId),
        advName: Value(advName),
        lastConnected: Value(lastConnected),
      ),
    );
  }

  Stream<List<SavedDevice>> watchAllSavedDevices() {
    return _database.watchAllSavedDevices();
  }
}

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final databaseRepositoryProvider = Provider<DatabaseRepository>((ref) {
  return DatabaseRepository(ref.watch(databaseProvider));
});
