import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fixnum/fixnum.dart';
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
      case MatrixUpload_Operation.layoutRequest:
        throw StateError('Layout read is not configured for this test');
      case MatrixUpload_Operation.layoutBegin:
      case MatrixUpload_Operation.matrixBegin:
      case MatrixUpload_Operation.begin:
        final begin = frame.hasLayoutBegin()
            ? frame.layoutBegin
            : frame.hasMatrixBegin()
            ? frame.matrixBegin
            : frame.begin;
        expectedCrc = begin.crc32;
        expectedSize = begin.totalSize;
        received.clear();
        status = MatrixStatus(
          transferId: begin.transferId,
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
  schemaVersion: 0,
  effects: [
    MatrixEffect(
      id: 1,
      kind: MatrixEffect_Kind.STATIC_COLOR,
      red: 255,
      alpha: 255,
    ),
  ],
  sources: [MatrixSource(id: 2, kind: MatrixSource_Kind.DEFAULT_STATE)],
  conditions: [MatrixCondition(id: 3, kind: MatrixCondition_Kind.ALWAYS)],
  entries: List.generate(
    32,
    (i) => MatrixEntry(
      id: i + 1,
      effectId: 1,
      sourceId: 2,
      conditionId: 3,
      priority: i,
    ),
  ),
  layout: List.generate(
    17,
    (j) => MatrixLayout(
      nodeMac: [2 + j * 2, 1, 2, 3, 4, 5],
      driver: MatrixDriver.WS2812,
      from: j * 60,
      to: (j + 1) * 60,
    ),
  ),
);

class LayoutTransport extends FakeTransport {
  final snapshot = LayoutSnapshot(
    masterSession: Int64(123),
    revision: Int64(7),
    masterMac: [2, 1, 2, 3, 4, 5],
    layout: config().layout.map(
      (row) => row.deepCopy()..name = 'Door lighting',
    ),
    outputs: [
      LayoutOutput(
        nodeMac: [2, 1, 2, 3, 4, 5],
        driver: MatrixDriver.WS2812,
        pixelCount: 60,
        online: true,
        ready: true,
        known: true,
      ),
    ],
  );
  LayoutResponse response = LayoutResponse();
  MatrixDocument? document;
  void Function(LayoutResponse)? corrupt;
  String? error;
  bool disconnected = false;
  bool staleRead = false;
  bool activeRead = false;
  LayoutTransport(super.mtu);

  Future<List<int>> readResponse() async {
    if (disconnected) throw StateError('Disconnected');
    if (staleRead) {
      staleRead = false;
      return LayoutResponse().writeToBuffer();
    }
    return response.writeToBuffer();
  }

  @override
  Future<void> write(List<int> bytes) async {
    final frame = MatrixUpload.fromBuffer(bytes);
    if (!frame.hasLayoutRequest()) return super.write(bytes);
    expect(bytes.length, lessThanOrEqualTo(mtu - 3));
    frames.add(frame);
    final request = frame.layoutRequest;
    response = LayoutResponse(requestId: request.requestId);
    if (error != null) {
      response.error = error!;
      return;
    }
    if (request.operation == LayoutRequest_Operation.PREVIEW) {
      response.complete = true;
    } else if (request.operation == LayoutRequest_Operation.IDENTIFY) {
      expect(request.snapshotId, 0x12345678);
      expect(request.outputIndex, 0);
      response.complete = true;
    } else {
      expect(request.snapshotId, request.offset == 0 ? 0 : 0x12345678);
      expect(
        request.operation,
        document == null
            ? LayoutRequest_Operation.READ
            : activeRead
            ? LayoutRequest_Operation.READ_ACTIVE_MATRIX
            : LayoutRequest_Operation.READ_MATRIX,
      );
      final data = document?.writeToBuffer() ?? snapshot.writeToBuffer();
      final end = (request.offset + 320).clamp(0, data.length);
      response
        ..snapshotId = 0x12345678
        ..totalSize = data.length
        ..offset = request.offset
        ..data = data.sublist(request.offset, end)
        ..complete = end == data.length;
    }
    corrupt?.call(response);
  }
}

void main() {
  test(
    'empty v0 configuration remains transferable at minimum BLE MTU',
    () async {
      final transport = FakeTransport(23);
      addTearDown(transport.notifications.close);
      final result = await MatrixClient(transport).upload(MatrixConfig()).last;
      expect(result.status.stage, MatrixStatus_Stage.ACTIVE);
      expect(transport.received, [8, 0]);
      expect(MatrixConfig.fromBuffer(transport.received).schemaVersion, 0);
    },
  );
  test(
    'matrix document can carry a full 16 KiB configuration plus node metadata',
    () async {
      final document = MatrixDocument(
        config: List.filled(16384, 1),
        revision: Int64(9),
        masterSession: Int64(10),
        nodes: [
          MatrixInputNode(
            nodeMac: [2, 1, 2, 3, 4, 5],
            known: true,
            gpios: List.generate(40, (i) => i),
          ),
        ],
      );
      final transport = LayoutTransport(23)..document = document;
      addTearDown(transport.notifications.close);
      final read = await MatrixClient(
        transport,
        readLayoutResponse: transport.readResponse,
      ).readMatrix();
      expect(read, document);
      expect(transport.frames.length, greaterThan(50));
    },
  );
  for (final mtu in [23, 185]) {
    test(
      'reads the active matrix separately from the saved revision at MTU $mtu',
      () async {
        final transport = LayoutTransport(mtu)
          ..activeRead = true
          ..document = MatrixDocument(
            config: (config()..factoryDefault = true).writeToBuffer(),
            revision: Int64(6),
            activeRevision: Int64(6),
            masterSession: Int64(123),
            activationPending: true,
            persisted: true,
          );
        addTearDown(transport.notifications.close);
        final document = await MatrixClient(
          transport,
          readLayoutResponse: transport.readResponse,
        ).readCurrentMatrix();
        expect(document, transport.document);
        expect(document.isFrozen, isTrue);
        expect(MatrixConfig.fromBuffer(document.config).factoryDefault, isTrue);
        expect(transport.frames.length, greaterThan(1));
        expect(
          transport.frames.every(
            (frame) =>
                frame.layoutRequest.operation ==
                LayoutRequest_Operation.READ_ACTIVE_MATRIX,
          ),
          isTrue,
        );
      },
    );
    test(
      'reads the saved matrix and applies a layout-preserving patch at MTU $mtu',
      () async {
        final transport = LayoutTransport(mtu)
          ..document = MatrixDocument(
            config: config().writeToBuffer(),
            revision: Int64(7),
            masterSession: Int64(123),
          );
        addTearDown(transport.notifications.close);
        final client = MatrixClient(
          transport,
          readLayoutResponse: transport.readResponse,
        );
        final document = await client.readMatrix();
        expect(document, transport.document);
        final input = MatrixConfig.fromBuffer(document.config);
        final patch = MatrixUpdate(
          expectedRevision: document.revision,
          masterSession: document.masterSession,
          effects: input.effects,
          sources: input.sources,
          conditions: input.conditions,
          entries: input.entries,
        );
        final progress = await client.updateMatrix(patch).toList();
        expect(
          transport.frames.where((frame) => frame.hasMatrixBegin()).length,
          1,
        );
        expect(MatrixUpdate.fromBuffer(transport.received), patch);
        expect(progress.last.status.stage, MatrixStatus_Stage.ACTIVE);
      },
    );
    test('reads paged inventory and identifies output at MTU $mtu', () async {
      final transport = LayoutTransport(mtu)..staleRead = true;
      addTearDown(transport.notifications.close);
      final client = MatrixClient(
        transport,
        readLayoutResponse: transport.readResponse,
      );
      final result = await client.readLayout();
      expect(result.snapshot, transport.snapshot);
      expect(transport.frames.length, greaterThan(1));
      expect(result.snapshot.isFrozen, isTrue);
      await client.identifyOutput(result.snapshotId, 0);
      await client.identifyOutput(
        result.snapshotId,
        203,
        pixelCount: 2048,
        reversed: true,
      );
      expect(
        transport.frames.last.layoutRequest.identifyOptions,
        203 | (2048 << 8) | (1 << 20),
      );
      expect(
        MatrixUpload(
          layoutRequest: LayoutRequest(
            requestId: 0xffffffff,
            snapshotId: 0xffffffff,
            operation: LayoutRequest_Operation.IDENTIFY,
            identifyOptions: 203 | (2048 << 8) | (1 << 20),
          ),
        ).writeToBuffer().length,
        20,
      );
      expect(
        transport.frames.last.layoutRequest.operation,
        LayoutRequest_Operation.IDENTIFY,
      );
      await client.identifyOutput(result.snapshotId, 5, wholeNode: true);
      expect(
        transport.frames.last.layoutRequest.identifyOptions,
        5 | (1 << 21),
      );
      await client.previewAnimation(42);
      expect(
        transport.frames.last.layoutRequest.operation,
        LayoutRequest_Operation.PREVIEW,
      );
      expect(transport.frames.last.layoutRequest.identifyOptions, 42);
      await expectLater(
        client.identifyOutput(
          result.snapshotId,
          5,
          wholeNode: true,
          pixelCount: 8,
        ),
        throwsArgumentError,
      );
    });
    test('uploads only layout and optimistic revision at MTU $mtu', () async {
      final transport = FakeTransport(mtu);
      addTearDown(transport.notifications.close);
      final update = LayoutUpdate(
        expectedRevision: Int64(7),
        masterSession: Int64(123),
        layout: config().layout,
      );
      final progress = await MatrixClient(transport)
          .uploadLayout(update)
          .toList();
      expect(transport.frames.first.hasLayoutBegin(), isTrue);
      expect(transport.frames.any((frame) => frame.hasBegin()), isFalse);
      expect(LayoutUpdate.fromBuffer(transport.received), update);
      expect(progress.last.status.stage, MatrixStatus_Stage.ACTIVE);
    });
  }
  for (final defect in ['offset', 'token', 'length', 'empty', 'complete']) {
    test(
      'rejects malformed layout page: $defect and releases the client',
      () async {
        final transport = LayoutTransport(23);
        addTearDown(transport.notifications.close);
        transport.corrupt = (response) {
          switch (defect) {
            case 'offset':
              response.offset++;
            case 'token':
              if (response.offset > 0) response.snapshotId++;
            case 'length':
              response.totalSize = 16385;
            case 'empty':
              response.data = [];
            case 'complete':
              response.complete = !response.complete;
          }
        };
        final client = MatrixClient(
          transport,
          readLayoutResponse: transport.readResponse,
        );
        await expectLater(
          client.readLayout(),
          throwsA(isA<MatrixUploadException>()),
        );
        transport.corrupt = null;
        expect((await client.readLayout()).snapshot, transport.snapshot);
      },
    );
  }
  test(
    'layout validation and disconnect failures preserve future operations',
    () async {
      final transport = LayoutTransport(23)..error = 'Output is offline';
      addTearDown(transport.notifications.close);
      final client = MatrixClient(
        transport,
        readLayoutResponse: transport.readResponse,
      );
      await expectLater(
        client.identifyOutput(0x12345678, 0),
        throwsA(isA<MatrixUploadException>()),
      );
      transport.error = null;
      transport.disconnected = true;
      await expectLater(client.readLayout(), throwsStateError);
      transport.disconnected = false;
      expect((await client.readLayout()).snapshot, transport.snapshot);
    },
  );
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
      expect(
        transport.frames.where((f) => f.hasChunk()).length,
        greaterThan(1),
      );
      for (var i = 1; i < progress.length; i++) {
        expect(
          progress[i].transferredBytes,
          greaterThanOrEqualTo(progress[i - 1].transferredBytes),
        );
      }
    });
  }
  test(
    'validation failure returns structured status and aborts the upload',
    () async {
      final transport = FakeTransport(185)..rejectCommit = true;
      addTearDown(transport.notifications.close);
      await expectLater(
        MatrixClient(transport).upload(config()).toList(),
        throwsA(
          isA<MatrixUploadException>().having(
            (e) => e.status?.error,
            'status error',
            'Target node is not paired',
          ),
        ),
      );
      expect(transport.frames.last.hasAbort(), isTrue);
    },
  );
  test(
    'uploads addressed keyframes and parametric animation settings',
    () async {
      final transport = FakeTransport(23);
      addTearDown(transport.notifications.close);
      final input = config();
      input.effects
        ..clear()
        ..addAll([
          MatrixEffect(
            id: 1,
            kind: MatrixEffect_Kind.KEYFRAMES,
            loop: true,
            keyframes: [
              MatrixKeyframe(
                timeMs: 0,
                trackId: 1,
                position: 3,
                width: 2,
                wrap: true,
                red: 255,
                alpha: 255,
                interpolation: MatrixInterpolation.SMOOTH,
              ),
              MatrixKeyframe(
                timeMs: 1000,
                trackId: 1,
                position: 63,
                width: 0,
                wrap: true,
                blue: 255,
                alpha: 128,
              ),
              MatrixKeyframe(
                timeMs: 0,
                trackId: 2,
                position: 8.5,
                green: 255,
                alpha: 255,
              ),
              MatrixKeyframe(
                timeMs: 1000,
                trackId: 2,
                position: -1,
                red: 255,
                alpha: 255,
              ),
            ],
          ),
          MatrixEffect(
            id: 2,
            kind: MatrixEffect_Kind.BLINK,
            red: 255,
            alpha: 255,
            periodMs: 500,
            dutyPercent: 25,
          ),
          MatrixEffect(
            id: 3,
            kind: MatrixEffect_Kind.BREATHE,
            green: 255,
            alpha: 255,
            periodMs: 2000,
          ),
          MatrixEffect(
            id: 4,
            kind: MatrixEffect_Kind.FLOWING_GRADIENT,
            red: 255,
            alpha: 255,
            periodMs: 3000,
            wavelengthPixels: 10,
            reverse: true,
            secondaryColor: MatrixColor(blue: 255, alpha: 255),
          ),
        ]);
      await MatrixClient(transport).upload(input).toList();
      final effects = MatrixConfig.fromBuffer(transport.received).effects;
      expect(transport.received, input.writeToBuffer());
      expect(effects[0].keyframes.first.trackId, 1);
      expect(effects[0].keyframes.first.position, 3);
      expect(effects[0].keyframes.first.width, 2);
      expect(effects[0].keyframes[1].hasWidth(), isTrue);
      expect(effects[0].keyframes[1].width, 0);
      expect(effects[0].keyframes.first.wrap, isTrue);
      expect(
        effects[0].keyframes.first.interpolation,
        MatrixInterpolation.SMOOTH,
      );
      expect(effects[0].keyframes.first.allPixels, isFalse);
      expect(effects[1].dutyPercent, 25);
      expect(effects[2].periodMs, 2000);
      expect(effects[3].secondaryColor.blue, 255);
      expect(effects[3].reverse, isTrue);
    },
  );
  test(
    'uploads one car layout with reversed and overlapping outputs',
    () async {
      final transport = FakeTransport(23);
      addTearDown(transport.notifications.close);
      final input = config();
      input.layout
        ..clear()
        ..addAll([
          MatrixLayout(
            nodeMac: [2, 1, 2, 3, 4, 5],
            driver: MatrixDriver.WS2812,
            from: 0,
            to: 60,
          ),
          MatrixLayout(
            nodeMac: [4, 1, 2, 3, 4, 5],
            driver: MatrixDriver.HC595,
            from: 12,
            to: 10,
          ),
        ]);
      await MatrixClient(transport).upload(input).toList();
      final received = MatrixConfig.fromBuffer(transport.received);
      expect(received.schemaVersion, 0);
      expect(received.layout.length, 2);
      expect(received.layout[0].to, 60);
      expect(received.layout[1].from, 12);
      expect(received.layout[1].to, 10);
      expect(received.entries.length, 32);
      expect(transport.received, input.writeToBuffer());
    },
  );
  test(
    'uploads a slave GPIO source without changing its identity or edge',
    () async {
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
    },
  );
  test('disconnect errors propagate and release the upload lock', () async {
    final transport = FakeTransport(185)..failWrite = true;
    addTearDown(transport.notifications.close);
    final client = MatrixClient(transport);
    await expectLater(client.upload(config()).toList(), throwsStateError);
    transport.failWrite = false;
    expect(
      (await client.upload(config()).last).status.stage,
      MatrixStatus_Stage.ACTIVE,
    );
  });
  test('cancelling progress sends abort and permits another upload', () async {
    final transport = FakeTransport(185);
    addTearDown(transport.notifications.close);
    final client = MatrixClient(transport);
    await client.upload(config()).first;
    expect(transport.frames.last.hasAbort(), isTrue);
    expect(
      (await client.upload(config()).last).status.stage,
      MatrixStatus_Stage.ACTIVE,
    );
  });
  test('invalid version is rejected before BLE writes', () async {
    final transport = FakeTransport(23);
    addTearDown(transport.notifications.close);
    await expectLater(
      MatrixClient(transport).upload(MatrixConfig(schemaVersion: 1)).toList(),
      throwsA(isA<MatrixUploadException>()),
    );
    expect(transport.frames, isEmpty);
  });
  test(
    'status watcher reads after invalidations and cancels cleanly',
    () async {
      final transport = FakeTransport(23);
      addTearDown(transport.notifications.close);
      final states = <MatrixStatus>[];
      final subscription = MatrixClient(transport)
          .watchStatus()
          .listen(states.add);
      await Future<void>.delayed(Duration.zero);
      transport.status.stage = MatrixStatus_Stage.ACTIVE;
      transport.notifications.add([1]);
      await Future<void>.delayed(Duration.zero);
      expect(states.map((s) => s.stage), [
        MatrixStatus_Stage.IDLE,
        MatrixStatus_Stage.ACTIVE,
      ]);
      await subscription.cancel();
    },
  );
}
