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
  const MatrixUploadProgress(this.transferredBytes, this.totalBytes, this.status);
}

/// BLE framing and upload orchestration, independent of Flutter or a BLE plugin.
class MatrixClient {
  final MatrixTransport _transport;
  bool _uploading = false;
  MatrixClient(this._transport);

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
          onDone: () { cancelled = true; unawaited(output.close()); },
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
    if (_uploading) throw MatrixUploadException('An upload is already in progress');
    if (config.schemaVersion != 2) {
      throw MatrixUploadException('Unsupported matrix schema version');
    }
    final bytes = config.writeToBuffer();
    if (bytes.isEmpty || bytes.length > 16384) {
      throw MatrixUploadException('Matrix exceeds the 16 KiB configuration limit');
    }
    _uploading = true;
    final id = Random.secure().nextInt(0xffffffff) + 1;
    var complete = false;
    try {
      await _write(MatrixUpload(begin: TransferBegin(
        transferId: id, totalSize: bytes.length, crc32: crc32(bytes),
      )));
      var status = await _wait(id, (s) => s.stage == MatrixStatus_Stage.RECEIVING);
      yield MatrixUploadProgress(0, bytes.length, status);
      var offset = 0;
      while (offset < bytes.length) {
        var length = min(min(480, max(1, _transport.mtu - 16)), bytes.length - offset);
        late MatrixUpload frame;
        while (length > 0) {
          frame = MatrixUpload(chunk: TransferChunk(
            transferId: id, offset: offset,
            data: bytes.sublist(offset, offset + length),
          ));
          if (frame.writeToBuffer().length <= min(512, _transport.mtu - 3)) break;
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
      status = await _wait(id, (s) => s.stage == MatrixStatus_Stage.ACTIVE,
          timeout: const Duration(seconds: 120));
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
