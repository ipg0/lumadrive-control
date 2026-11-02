import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/repositories/matrix_client.dart';

abstract interface class LayoutRepository {
  Future<LayoutReadResult> read();
  Future<MatrixStatus> readStatus();
  Future<void> identify(
    int snapshotId,
    int outputIndex, {
    int pixelCount = 0,
    bool reversed = false,
  });
  Stream<MatrixUploadProgress> apply(LayoutUpdate update);
}

class ConnectedLayoutRepository implements LayoutRepository {
  final bool Function()? isAvailable;
  final Future<LayoutReadResult> Function() readLayout;
  final Future<MatrixStatus> Function() getStatus;
  final Future<void> Function(int, int, int, bool) identifyOutput;
  final Stream<MatrixUploadProgress> Function(LayoutUpdate) uploadLayout;
  ConnectedLayoutRepository({
    this.isAvailable,
    required this.readLayout,
    required this.getStatus,
    required this.identifyOutput,
    required this.uploadLayout,
  });
  @override
  Future<LayoutReadResult> read() async {
    _checkConnection();
    final result = await readLayout();
    _checkConnection();
    return result;
  }

  @override
  Future<MatrixStatus> readStatus() async {
    _checkConnection();
    final result = await getStatus();
    _checkConnection();
    return result;
  }

  @override
  Future<void> identify(
    int snapshotId,
    int outputIndex, {
    int pixelCount = 0,
    bool reversed = false,
  }) async {
    _checkConnection();
    await identifyOutput(snapshotId, outputIndex, pixelCount, reversed);
    _checkConnection();
  }

  @override
  Stream<MatrixUploadProgress> apply(LayoutUpdate update) async* {
    _checkConnection();
    await for (final progress in uploadLayout(update)) {
      _checkConnection();
      yield progress;
    }
    _checkConnection();
  }

  void _checkConnection() {
    if (isAvailable != null && !isAvailable!()) {
      throw StateError('This controller is disconnected');
    }
  }
}

class SavedLayoutDraft {
  final LayoutSnapshot snapshot;
  final List<MatrixLayout> layout;
  final int? centerIndex;
  SavedLayoutDraft(this.snapshot, this.layout, [this.centerIndex]);
}

abstract interface class LayoutDraftStore {
  Future<SavedLayoutDraft?> read();
  Future<void> save(SavedLayoutDraft draft);
}

class FileLayoutDraftStore implements LayoutDraftStore {
  final String controllerId;
  FileLayoutDraftStore(this.controllerId);
  Future<File> _file() async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory('${root.path}/layout_drafts');
    await directory.create(recursive: true);
    final key = base64Url.encode(utf8.encode(controllerId));
    return File('${directory.path}/$key.json');
  }

  @override
  Future<SavedLayoutDraft?> read() async {
    final file = await _file();
    if (!await file.exists()) return null;
    try {
      final data =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      if (data['version'] != 1) return null;
      final update = LayoutUpdate.fromBuffer(
        base64Decode(data['layout'] as String),
      );
      return SavedLayoutDraft(
        LayoutSnapshot.fromBuffer(base64Decode(data['snapshot'] as String))
          ..freeze(),
        update.layout.toList(),
        update.hasCenterIndex() ? update.centerIndex : null,
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  @override
  Future<void> save(SavedLayoutDraft draft) async {
    final file = await _file();
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(
      jsonEncode({
        'version': 1,
        'snapshot': base64Encode(draft.snapshot.writeToBuffer()),
        'layout': base64Encode(
          LayoutUpdate(
            layout: draft.layout,
            centerIndex: draft.centerIndex,
          ).writeToBuffer(),
        ),
      }),
      flush: true,
    );
    await temporary.rename(file.path);
  }
}

final layoutDraftStoreProvider = Provider.family<LayoutDraftStore, String>(
  (ref, id) => FileLayoutDraftStore(id),
);
