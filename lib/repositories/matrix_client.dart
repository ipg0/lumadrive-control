import 'dart:async';
import 'dart:math';

import 'package:lumadrive_control/generated/mesh.pb.dart';

abstract interface class MatrixTransport {
  int get mtu;
  Future<void> write(List<int> bytes);
  Future<List<int>> readStatus();
  Stream<List<int>> get invalidations;
}

class MatrixUploadException implements Exception {
  final String message;
  final MatrixStatus? status;
  MatrixUploadException(this.message, [this.status]);
  @override
  String toString() => 'MatrixUploadException: $message';
}

class MatrixUploadProgress {
  final int transferredBytes;
  final int totalBytes;
  final MatrixStatus status;
  const MatrixUploadProgress(
    this.transferredBytes,
    this.totalBytes,
    this.status,
  );
}

class LayoutReadResult {
  final LayoutSnapshot snapshot;
  final int snapshotId;
  const LayoutReadResult(this.snapshot, this.snapshotId);
}

/// BLE framing and upload orchestration, independent of Flutter or a BLE plugin.
class MatrixClient {
  final MatrixTransport _transport;
  bool _uploading = false;
  final Future<List<int>> Function()? readLayoutResponse;
  // Cached GATT values may outlive this client or BLE connection.
  int _requestId = Random.secure().nextInt(0xffffffff);
  MatrixClient(this._transport, {this.readLayoutResponse});

  Future<LayoutResponse> _layoutCall(LayoutRequest request) async {
    final read = readLayoutResponse;
    if (read == null) {
      throw StateError(
        'Layout configuration is unavailable on this controller',
      );
    }
    _requestId = _requestId % 0xffffffff + 1;
    request.requestId = _requestId;
    await _write(MatrixUpload(layoutRequest: request));
    final timer = Stopwatch()..start();
    while (timer.elapsed < const Duration(seconds: 5)) {
      final response = LayoutResponse.fromBuffer(
        await read().timeout(const Duration(seconds: 5)),
      );
      if (response.requestId == request.requestId) {
        if (response.error.isNotEmpty) {
          throw MatrixUploadException(response.error);
        }
        return response;
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    throw MatrixUploadException('Controller did not respond. Try again.');
  }

  Future<LayoutReadResult> readLayout() async {
    final result = await _readPages(LayoutRequest_Operation.READ, 32768);
    return LayoutReadResult(
      LayoutSnapshot.fromBuffer(result.$1)..freeze(),
      result.$2,
    );
  }

  Future<MatrixDocument> readMatrix() async {
    final result = await _readPages(LayoutRequest_Operation.READ_MATRIX, 32768);
    return MatrixDocument.fromBuffer(result.$1)..freeze();
  }

  Future<MatrixDocument> readCurrentMatrix() async {
    final result = await _readPages(
      LayoutRequest_Operation.READ_ACTIVE_MATRIX,
      32768,
    );
    return MatrixDocument.fromBuffer(result.$1)..freeze();
  }

  Future<(List<int>, int)> _readPages(
    LayoutRequest_Operation operation,
    int limit,
  ) async {
    if (_uploading) throw StateError('Controller is busy');
    _uploading = true;
    try {
      final bytes = <int>[];
      var snapshotId = 0;
      int? total;
      do {
        final response = await _layoutCall(
          LayoutRequest(
            operation: operation,
            snapshotId: snapshotId,
            offset: bytes.length,
          ),
        );
        if (response.totalSize > limit ||
            response.totalSize == 0 ||
            response.snapshotId == 0 ||
            response.offset != bytes.length ||
            (snapshotId != 0 && response.snapshotId != snapshotId) ||
            (total != null && total != response.totalSize) ||
            response.data.isEmpty ||
            bytes.length + response.data.length > response.totalSize) {
          throw MatrixUploadException(
            'Incomplete configuration received. Refresh and try again.',
          );
        }
        snapshotId = response.snapshotId;
        total = response.totalSize;
        bytes.addAll(response.data);
        if (response.complete != (bytes.length == total)) {
          throw MatrixUploadException('Invalid layout response');
        }
      } while (bytes.length < total);
      return (bytes, snapshotId);
    } finally {
      _uploading = false;
    }
  }

  Future<void> identifyOutput(
    int snapshotId,
    int outputIndex, {
    int pixelCount = 0,
    bool reversed = false,
    bool wholeNode = false,
  }) async {
    if (outputIndex < 0 ||
        outputIndex > 203 ||
        pixelCount < 0 ||
        pixelCount > 2048 ||
        (wholeNode && (pixelCount != 0 || reversed))) {
      throw ArgumentError('Unsupported identify output or LED count');
    }
    if (_uploading) throw StateError('Controller is busy');
    _uploading = true;
    try {
      final response = await _layoutCall(
        LayoutRequest(
          operation: LayoutRequest_Operation.IDENTIFY,
          snapshotId: snapshotId,
          identifyOptions:
              outputIndex |
              (pixelCount << 8) |
              (reversed ? 1 << 20 : 0) |
              (wholeNode ? 1 << 21 : 0),
        ),
      );
      if (!response.complete) {
        throw MatrixUploadException('Unable to identify output');
      }
    } finally {
      _uploading = false;
    }
  }

  Future<void> previewAnimation(int effectId) async {
    if (effectId <= 0 || effectId > 0xffffffff) {
      throw ArgumentError('Invalid animation ID');
    }
    if (_uploading) throw StateError('Controller is busy');
    _uploading = true;
    try {
      final response = await _layoutCall(
        LayoutRequest(
          operation: LayoutRequest_Operation.PREVIEW,
          identifyOptions: effectId,
        ),
      );
      if (!response.complete) {
        throw MatrixUploadException('Unable to preview animation');
      }
    } finally {
      _uploading = false;
    }
  }

  static int crc32(List<int> bytes) {
    var crc = 0xffffffff;
    for (final byte in bytes) {
      crc ^= byte;
      for (var bit = 0; bit < 8; bit++) {
        crc = (crc >>> 1) ^ ((crc & 1) == 1 ? 0xedb88320 : 0);
      }
    }
    return (crc ^ 0xffffffff) & 0xffffffff;
  }

  Future<MatrixStatus> getStatus() async =>
      MatrixStatus.fromBuffer(await _transport.readStatus())..freeze();

  Stream<MatrixStatus> watchStatus() {
    late StreamController<MatrixStatus> output;
    StreamSubscription<List<int>>? subscription;
    var cancelled = false;
    var pending = Future<void>.value();
    void refresh() {
      pending = pending.then((_) async {
        if (cancelled) return;
        try {
          final status = await getStatus();
          if (!cancelled) output.add(status);
        } catch (error, stack) {
          if (!cancelled) output.addError(error, stack);
        }
      });
    }

    output = StreamController<MatrixStatus>(
      onListen: () {
        subscription = _transport.invalidations.listen(
          (_) => refresh(),
          onError: output.addError,
          onDone: () {
            cancelled = true;
            unawaited(output.close());
          },
        );
        refresh();
      },
      onCancel: () async {
        cancelled = true;
        await subscription?.cancel();
      },
    );
    return output.stream;
  }

  Future<void> _write(MatrixUpload message) async {
    final bytes = message.writeToBuffer();
    if (bytes.length > min(512, _transport.mtu - 3)) {
      throw MatrixUploadException('Negotiated BLE MTU cannot fit upload frame');
    }
    await _transport.write(bytes).timeout(const Duration(seconds: 15));
  }

  Future<MatrixStatus> _wait(
    int transferId,
    bool Function(MatrixStatus) predicate, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final timer = Stopwatch()..start();
    while (timer.elapsed < timeout) {
      final status = await getStatus().timeout(const Duration(seconds: 5));
      if (status.transferId == transferId) {
        if (status.stage == MatrixStatus_Stage.FAILED) {
          throw MatrixUploadException(status.error, status);
        }
        if (predicate(status)) return status;
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    throw MatrixUploadException('Timed out waiting for matrix transfer status');
  }

  Stream<MatrixUploadProgress> upload(MatrixConfig config) async* {
    if (config.schemaVersion != 0) {
      throw MatrixUploadException('Unsupported matrix schema version');
    }
    final bytes = config.writeToBuffer();
    // An explicit zero schema field keeps an empty v0 matrix transferable.
    yield* _uploadBytes(bytes.isEmpty ? [8, 0] : bytes, 0);
  }

  Stream<MatrixUploadProgress> uploadLayout(LayoutUpdate update) =>
      _uploadBytes(update.writeToBuffer(), 1);

  Stream<MatrixUploadProgress> updateMatrix(MatrixUpdate update) =>
      _uploadBytes(update.writeToBuffer(), 2);

  Stream<MatrixUploadProgress> _uploadBytes(List<int> bytes, int kind) async* {
    if (_uploading) {
      throw MatrixUploadException('An upload is already in progress');
    }
    if (bytes.isEmpty || bytes.length > 16384) {
      throw MatrixUploadException(
        'Matrix exceeds the 16 KiB configuration limit',
      );
    }
    _uploading = true;
    final id = Random.secure().nextInt(0xffffffff) + 1;
    var complete = false;
    try {
      final begin = TransferBegin(
        transferId: id,
        totalSize: bytes.length,
        crc32: crc32(bytes),
      );
      await _write(
        kind == 1
            ? MatrixUpload(layoutBegin: begin)
            : kind == 2
            ? MatrixUpload(matrixBegin: begin)
            : MatrixUpload(begin: begin),
      );
      var status = await _wait(
        id,
        (s) => s.stage == MatrixStatus_Stage.RECEIVING,
      );
      yield MatrixUploadProgress(0, bytes.length, status);
      var offset = 0;
      while (offset < bytes.length) {
        var length = min(
          min(480, max(1, _transport.mtu - 16)),
          bytes.length - offset,
        );
        late MatrixUpload frame;
        while (length > 0) {
          frame = MatrixUpload(
            chunk: TransferChunk(
              transferId: id,
              offset: offset,
              data: bytes.sublist(offset, offset + length),
            ),
          );
          if (frame.writeToBuffer().length <= min(512, _transport.mtu - 3)) {
            break;
          }
          length--;
        }
        if (length == 0) throw MatrixUploadException('BLE MTU is too small');
        await _write(frame);
        offset += length;
        // Application ACK supplies backpressure to the bounded firmware queue.
        status = await _wait(id, (s) => s.receivedBytes >= offset);
        yield MatrixUploadProgress(offset, bytes.length, status);
      }
      await _write(MatrixUpload(commit: id));
      status = await _wait(
        id,
        (s) => s.stage == MatrixStatus_Stage.ACTIVE,
        timeout: const Duration(seconds: 120),
      );
      complete = true;
      yield MatrixUploadProgress(bytes.length, bytes.length, status);
    } finally {
      if (!complete) {
        try {
          await _write(MatrixUpload(abort: id));
        } catch (_) {
          // Preserve the original failure; the device also expires partial uploads.
        }
      }
      _uploading = false;
    }
  }
}
