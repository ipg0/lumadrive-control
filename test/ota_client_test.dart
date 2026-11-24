import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumadrive_control/repositories/ota_client.dart';

class FakeOtaTransport implements OtaTransport {
  @override
  int mtu = 23;
  int stage = 0, id = 0, offset = 0, total = 0, crc = 0;
  bool rejectCommit = false, aborted = false, rebooted = false;
  bool rejectReboot = false;
  final received = <int>[];
  final targets = <List<int>?>[];
  final completedTargets = <List<int>?>[];
  List<int>? target;
  @override
  Future<void> write(List<int> bytes) async {
    expect(bytes.length, lessThanOrEqualTo(mtu - 3));
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    final command = bytes[0];
    if (command == 1) {
      target = bytes.length == 19 ? bytes.sublist(13) : null;
      targets.add(target);
      received.clear();
      offset = 0;
      id = data.getUint32(1, Endian.little);
      total = data.getUint32(5, Endian.little);
      crc = data.getUint32(9, Endian.little);
      stage = 1;
    } else if (command == 2) {
      expect(data.getUint32(5, Endian.little), offset);
      received.addAll(bytes.sublist(9));
      offset = received.length;
    } else if (command == 3) {
      stage = rejectCommit ? 3 : 2;
    } else if (command == 4) {
      aborted = true;
    } else if (command == 5) {
      stage = 4;
    } else if (command == 6) {
      rebooted = true;
      if (target != null && rejectReboot) {
        stage = 3;
      } else {
        completedTargets.add(target);
        if (target != null) stage = 5;
      }
    }
  }

  @override
  Future<List<int>> readStatus() async {
    final bytes = Uint8List(16);
    final data = ByteData.sublistView(bytes);
    bytes[0] = stage;
    bytes[1] = stage == 3 ? 7 : 0;
    data.setUint32(4, id, Endian.little);
    data.setUint32(8, offset, Endian.little);
    data.setUint32(12, total, Endian.little);
    return bytes;
  }
}

void main() {
  test('uploads within the minimum MTU and reboots after validation', () async {
    final transport = FakeOtaTransport();
    final image = Uint8List.fromList(List.generate(83, (i) => i));
    final progress = await OtaClient(transport).upload(image).toList();
    expect(transport.received, image);
    expect(progress.first, 0);
    expect(progress.last, 1);
    expect(transport.rebooted, isTrue);
    expect(transport.aborted, isFalse);
  });
  test('aborts and does not reboot if validation fails', () async {
    final transport = FakeOtaTransport()..rejectCommit = true;
    await expectLater(
      OtaClient(transport).upload(Uint8List(12)).toList(),
      throwsA(isA<OtaException>()),
    );
    expect(transport.aborted, isTrue);
    expect(transport.rebooted, isFalse);
  });
  test('uses the standard CRC32 for the firmware image', () async {
    final transport = FakeOtaTransport();
    await OtaClient(transport)
        .upload(Uint8List.fromList('123456789'.codeUnits))
        .toList();
    expect(transport.crc, 0xcbf43926);
  });
  test('updates every node before the controller using minimum MTU', () async {
    final transport = FakeOtaTransport();
    final nodes = [
      [2, 0, 0, 0, 0, 1],
      [2, 0, 0, 0, 0, 2],
    ];
    final progress = await OtaClient(transport)
        .uploadAll(Uint8List(40), nodes)
        .toList();
    expect(transport.targets, [nodes[0], nodes[1], null]);
    expect(transport.completedTargets, [nodes[0], nodes[1], null]);
    expect(progress.last.overall, 1);
  });
  test('a node failure prevents updating the controller', () async {
    final transport = FakeOtaTransport()..rejectCommit = true;
    final nodes = [
      [2, 0, 0, 0, 0, 1],
    ];
    await expectLater(
      OtaClient(transport).uploadAll(Uint8List(12), nodes).toList(),
      throwsA(isA<OtaException>()),
    );
    expect(transport.targets, [nodes[0]]);
    expect(transport.completedTargets, isEmpty);
  });
  test(
    'does not mark a node complete or update the controller if restart fails',
    () async {
      final transport = FakeOtaTransport()..rejectReboot = true;
      final progress = <OtaFleetProgress>[];
      await expectLater(() async {
        await for (final value in OtaClient(transport).uploadAll(
          Uint8List(12),
          [
            [2, 0, 0, 0, 0, 1],
          ],
        )) {
          progress.add(value);
        }
      }(), throwsA(isA<OtaException>()));
      expect(progress.any((value) => value.completed), isFalse);
      expect(transport.targets.length, 1);
    },
  );
}
