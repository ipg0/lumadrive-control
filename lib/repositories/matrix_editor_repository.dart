import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/repositories/matrix_client.dart';

abstract interface class MatrixEditorRepository {
  Future<MatrixDocument> read();
  Future<MatrixDocument> current();
  Future<MatrixStatus> status();
  Stream<MatrixUploadProgress> apply(MatrixUpdate update);
  Future<void> preview(int effectId);
}

class ConnectedMatrixEditorRepository implements MatrixEditorRepository {
  final bool Function() isAvailable;
  final Future<MatrixDocument> Function() readDocument;
  final Future<MatrixDocument> Function() readActiveDocument;
  final Future<MatrixStatus> Function() readStatus;
  final Stream<MatrixUploadProgress> Function(MatrixUpdate) updateMatrix;
  final Future<void> Function(int)? previewAnimation;
  ConnectedMatrixEditorRepository({
    required this.isAvailable,
    required this.readDocument,
    required this.readActiveDocument,
    required this.readStatus,
    required this.updateMatrix,
    this.previewAnimation,
  });
  void _check() {
    if (!isAvailable()) throw StateError('This controller is disconnected');
  }

  @override
  Future<MatrixDocument> read() async {
    _check();
    final value = await readDocument();
    _check();
    return value;
  }

  @override
  Future<MatrixDocument> current() async {
    _check();
    final value = await readActiveDocument();
    _check();
    return value;
  }

  @override
  Future<MatrixStatus> status() async {
    _check();
    final value = await readStatus();
    _check();
    return value;
  }

  @override
  Stream<MatrixUploadProgress> apply(MatrixUpdate update) async* {
    _check();
    await for (final value in updateMatrix(update)) {
      _check();
      yield value;
    }
    _check();
  }

  @override
  Future<void> preview(int effectId) async {
    _check();
    final callback = previewAnimation;
    if (callback == null) throw StateError('Animation preview is unavailable');
    await callback(effectId);
    _check();
  }
}

class MatrixDraft {
  final MatrixDocument document;
  final MatrixConfig config;
  MatrixDraft(this.document, this.config);
}

abstract interface class MatrixDraftStore {
  Future<MatrixDraft?> read();
  Future<void> save(MatrixDraft draft);
}

class FileMatrixDraftStore implements MatrixDraftStore {
  final String controllerId;
  FileMatrixDraftStore(this.controllerId);
  Future<File> _file() async {
    final root = await getApplicationSupportDirectory();
    final directory = Directory('${root.path}/matrix_drafts');
    await directory.create(recursive: true);
    return File(
      '${directory.path}/${base64Url.encode(utf8.encode(controllerId))}.json',
    );
  }

  @override
  Future<MatrixDraft?> read() async {
    final file = await _file();
    if (!await file.exists()) return null;
    try {
      final data =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      if (data['version'] != 1) return null;
      return MatrixDraft(
        MatrixDocument.fromBuffer(base64Decode(data['document'] as String))
          ..freeze(),
        MatrixConfig.fromBuffer(base64Decode(data['config'] as String)),
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  @override
  Future<void> save(MatrixDraft draft) async {
    final file = await _file();
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(
      jsonEncode({
        'version': 1,
        'document': base64Encode(draft.document.writeToBuffer()),
        'config': base64Encode(draft.config.writeToBuffer()),
      }),
      flush: true,
    );
    await temporary.rename(file.path);
  }
}

final matrixDraftStoreProvider = Provider.family<MatrixDraftStore, String>(
  (ref, id) => FileMatrixDraftStore(id),
);
