import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/repositories/matrix_client.dart';

class FakeTransport implements MatrixTransport {
  @override
  final int mtu;
  final frames = <MatrixUpload>[];
  final received = <int>[];
  final notifications = StreamController<List<int>>.broadcast();
  MatrixStatus status = MatrixStatus();
  int expectedCrc = 0;
  int expectedSize = 0;
  bool rejectCommit = false;
  bool failWrite = false;
  FakeTransport(this.mtu);

  @override
  Stream<List<int>> get invalidations => notifications.stream;

  @override
  Future<List<int>> readStatus() async => status.writeToBuffer();

  @override
  Future<void> write(List<int> bytes) async {
    if (failWrite) throw StateError('Disconnected');
    expect(bytes.length, lessThanOrEqualTo(mtu - 3));
    final frame = MatrixUpload.fromBuffer(bytes);
    frames.add(frame);
    switch (frame.whichOperation()) {
      case MatrixUpload_Operation.begin:
        expectedCrc = frame.begin.crc32;
        expectedSize = frame.begin.totalSize;
        received.clear();
        status = MatrixStatus(
          transferId: frame.begin.transferId,
          stage: MatrixStatus_Stage.RECEIVING,
        );
      case MatrixUpload_Operation.chunk:
        expect(frame.chunk.transferId, status.transferId);
        expect(frame.chunk.offset, received.length);
        received.addAll(frame.chunk.data);
        status.receivedBytes = received.length;
      case MatrixUpload_Operation.commit:
        expect(frame.commit, status.transferId);
        expect(received.length, expectedSize);
        expect(MatrixClient.crc32(received), expectedCrc);
        if (rejectCommit) {
          status.stage = MatrixStatus_Stage.FAILED;
          status.error = 'Target node is not paired';
        } else {
          status.stage = MatrixStatus_Stage.ACTIVE;
        }
      case MatrixUpload_Operation.abort:
        status.stage = MatrixStatus_Stage.IDLE;
      case MatrixUpload_Operation.notSet:
        fail('Empty upload envelope');
    }
  }
}

MatrixConfig config() => MatrixConfig(
  schemaVersion: 1,
  effects: [MatrixEffect(id: 1, kind: MatrixEffect_Kind.STATIC_COLOR,
    red: 255, alpha: 255)],
  sources: [MatrixSource(id: 2, kind: MatrixSource_Kind.DEFAULT_STATE)],
  conditions: [MatrixCondition(id: 3, kind: MatrixCondition_Kind.ALWAYS)],
  entries: List.generate(32, (i) => MatrixEntry(
    id: i + 1, effectId: 1, sourceId: 2, conditionId: 3, priority: i,
    targets: List.generate(17, (j) => MatrixTarget(
      nodeMac: [2 + j * 2, 1, 2, 3, 4, 5], driver: MatrixDriver.WS2812,
    )),
  )),
);

void main() {
  test('IEEE CRC32 matches the firmware test vector', () {
    expect(MatrixClient.crc32('123456789'.codeUnits), 0xcbf43926);
  });
  for (final mtu in [23, 64, 185, 512]) {
    test('uploads multi-chunk configuration at MTU $mtu', () async {
      final transport = FakeTransport(mtu);
      addTearDown(transport.notifications.close);
      final input = config();
      final progress = await MatrixClient(transport).upload(input).toList();
      expect(transport.received, input.writeToBuffer());
      expect(progress.first.transferredBytes, 0);
      expect(progress.last.status.stage, MatrixStatus_Stage.ACTIVE);
      expect(progress.last.transferredBytes, input.writeToBuffer().length);
      expect(transport.frames.where((f) => f.hasChunk()).length, greaterThan(1));
      for (var i = 1; i < progress.length; i++) {
        expect(progress[i].transferredBytes, greaterThanOrEqualTo(progress[i - 1].transferredBytes));
      }
    });
  }
  test('validation failure returns structured status and aborts the upload', () async {
    final transport = FakeTransport(185)..rejectCommit = true;
    addTearDown(transport.notifications.close);
    await expectLater(MatrixClient(transport).upload(config()).toList(),
      throwsA(isA<MatrixUploadException>().having(
        (e) => e.status?.error, 'status error', 'Target node is not paired')));
    expect(transport.frames.last.hasAbort(), isTrue);
  });
  test('uploads a slave GPIO source without changing its identity or edge', () async {
    final transport = FakeTransport(23);
    addTearDown(transport.notifications.close);
    final input = config();
    input.sources[0]
      ..kind = MatrixSource_Kind.GPIO_EDGE
      ..nodeMac = [4, 1, 2, 3, 4, 5]
      ..gpio = 12
      ..rising = true;
    await MatrixClient(transport).upload(input).toList();
    final source = MatrixConfig.fromBuffer(transport.received).sources.single;
    expect(source.kind, MatrixSource_Kind.GPIO_EDGE);
    expect(source.nodeMac, [4, 1, 2, 3, 4, 5]);
    expect(source.gpio, 12);
    expect(source.rising, isTrue);
  });
  test('disconnect errors propagate and release the upload lock', () async {
    final transport = FakeTransport(185)..failWrite = true;
    addTearDown(transport.notifications.close);
    final client = MatrixClient(transport);
    await expectLater(client.upload(config()).toList(), throwsStateError);
    transport.failWrite = false;
    expect((await client.upload(config()).last).status.stage, MatrixStatus_Stage.ACTIVE);
  });
  test('cancelling progress sends abort and permits another upload', () async {
    final transport = FakeTransport(185);
    addTearDown(transport.notifications.close);
    final client = MatrixClient(transport);
    await client.upload(config()).first;
    expect(transport.frames.last.hasAbort(), isTrue);
    expect((await client.upload(config()).last).status.stage, MatrixStatus_Stage.ACTIVE);
  });
  test('invalid version is rejected before BLE writes', () async {
    final transport = FakeTransport(23);
    addTearDown(transport.notifications.close);
    await expectLater(MatrixClient(transport).upload(MatrixConfig(schemaVersion: 2)).toList(),
      throwsA(isA<MatrixUploadException>()));
    expect(transport.frames, isEmpty);
  });
  test('status watcher reads after invalidations and cancels cleanly', () async {
    final transport = FakeTransport(23);
    addTearDown(transport.notifications.close);
    final states = <MatrixStatus>[];
    final subscription = MatrixClient(transport).watchStatus().listen(states.add);
    await Future<void>.delayed(Duration.zero);
    transport.status.stage = MatrixStatus_Stage.ACTIVE;
    transport.notifications.add([1]);
    await Future<void>.delayed(Duration.zero);
    expect(states.map((s) => s.stage), [MatrixStatus_Stage.IDLE, MatrixStatus_Stage.ACTIVE]);
    await subscription.cancel();
  });
}
