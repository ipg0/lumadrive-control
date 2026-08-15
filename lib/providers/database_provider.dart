import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/data/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close); // clean up the DB connection when no longer needed
  return db;
});

// Reactive stream of saved devices — auto-updates on any insert/update/delete
final savedDevicesProvider = StreamProvider<List<SavedDevice>>((ref) {
  return ref.watch(databaseProvider).watchAllSavedDevices();
});
