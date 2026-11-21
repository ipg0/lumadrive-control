import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

abstract interface class OtaTransport {
  int get mtu;
  Future<void> write(List<int> bytes);
  Future<List<int>> readStatus();
}

class OtaException implements Exception {
  final String message;
  const OtaException(this.message);
  @override
  String toString() => message;
}

class OtaClient {
  OtaClient(this._transport);
  final OtaTransport _transport;
  bool _busy = false;

  Uint8List _frame(int command, int id, [int? value, int? extra]) {
    final bytes = Uint8List(5 + (value == null ? 0 : 4) + (extra == null ? 0 : 4));
    final data = ByteData.sublistView(bytes);
    data.setUint8(0, command);
    data.setUint32(1, id, Endian.little);
    if (value != null) data.setUint32(5, value, Endian.little);
    if (extra != null) data.setUint32(9, extra, Endian.little);
    return bytes;
  }

  int _crc32(Uint8List bytes) {
    var crc = 0xffffffff;
    for (final byte in bytes) {
      crc ^= byte;
      for (var i = 0; i < 8; i++) {
        crc = (crc >> 1) ^ ((crc & 1) == 1 ? 0xedb88320 : 0);
      }
    }
    return (crc ^ 0xffffffff) & 0xffffffff;
  }

  Future<void> _wait(int id, int offset, int stage) async {
    final timer = Stopwatch()..start();
    while (timer.elapsed < const Duration(seconds: 30)) {
      final bytes = await _transport.readStatus();
      if (bytes.length != 16) throw const OtaException('Invalid update status');
      final data = ByteData.sublistView(Uint8List.fromList(bytes));
      if (data.getUint32(4, Endian.little) == id) {
        final actualStage = data.getUint8(0);
        if (actualStage == 3) {
          throw OtaException('Controller rejected the update (error ${data.getUint8(1)})');
        }
        if (actualStage == stage && data.getUint32(8, Endian.little) == offset) return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    throw const OtaException('Timed out waiting for the controller');
  }

  Stream<double> upload(Uint8List image) async* {
    if (_busy) throw const OtaException('An update is already in progress');
    if (image.isEmpty || image.length > 0xffffffff) throw const OtaException('Invalid firmware file');
    final payload = min(_transport.mtu - 3, 512) - 9;
    if (payload <= 0 || _transport.mtu - 3 < 13) throw const OtaException('Bluetooth MTU is too small');
    _busy = true;
    final id = Random.secure().nextInt(0xffffffff) + 1;
    var committed = false;
    try {
      await _transport.write(_frame(1, id, image.length, _crc32(image)));
      await _wait(id, 0, 1);
      yield 0;
      var offset = 0;
      while (offset < image.length) {
        final end = min(offset + payload, image.length);
        await _transport.write([..._frame(2, id, offset), ...image.sublist(offset, end)]);
        await _wait(id, end, 1);
        offset = end;
        yield offset / image.length;
      }
      await _transport.write(_frame(3, id));
      await _wait(id, image.length, 2);
      await _transport.write(_frame(5, id));
      await _wait(id, image.length, 4);
      committed = true;
      await _transport.write(_frame(6, id));
    } finally {
      if (!committed) {
        try { await _transport.write(_frame(4, id)); } catch (_) { /* disconnected */ }
      }
      _busy = false;
    }
  }
}
