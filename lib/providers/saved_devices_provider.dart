import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/repositories/database_repository.dart';
import 'package:lumadrive_control/data/database.dart';

final savedDevicesProvider = StreamProvider<List<SavedDevice>>((ref) {
  return ref.watch(databaseRepositoryProvider).watchAllSavedDevices();
});
