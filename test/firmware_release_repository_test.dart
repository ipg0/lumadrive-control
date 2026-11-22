import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lumadrive_control/repositories/firmware_release_repository.dart';

Map<String, Object> release({List<Object>? assets}) => {
  'tag_name': 'v0.1.0',
  'assets': assets ?? [asset('lumadrive-v0.1.0-esp32dev.bin')],
};

Map<String, Object> asset(String name) => {
  'name': name,
  'state': 'uploaded',
  'size': 3,
  'browser_download_url': 'https://github.com/ipg0/lumadrive-firmware/releases/download/v0.1.0/$name',
};

void main() {
  test('finds the latest matching release asset and downloads it', () async {
    final client = MockClient((request) async {
      if (request.url.host == 'api.github.com') {
        expect(request.url.path, '/repos/ipg0/lumadrive-firmware/releases/latest');
        return http.Response(jsonEncode(release(assets: [asset('other.bin'), asset('lumadrive-v0.1.0-esp32dev.bin')])), 200);
      }
      return http.Response.bytes([1, 2, 3], 200);
    });
    final repository = FirmwareReleaseRepository(client);
    final latest = await repository.latest();
    expect(latest.version, 'v0.1.0');
    expect(latest.assetName, 'lumadrive-v0.1.0-esp32dev.bin');
    final progress = <double>[];
    expect(await repository.download(latest, onProgress: progress.add), [1, 2, 3]);
    expect(progress.last, 1);
  });

  test('reports missing or ambiguous firmware assets', () async {
    for (final assets in [<Object>[], [asset('lumadrive-a-esp32dev.bin'), asset('lumadrive-b-esp32dev.bin')]]) {
      final repository = FirmwareReleaseRepository(MockClient((_) async => http.Response(jsonEncode(release(assets: assets)), 200)));
      await expectLater(repository.latest(), throwsA(isA<FirmwareReleaseException>()));
    }
  });

  test('reports unavailable releases and malformed download URLs', () async {
    final unavailable = FirmwareReleaseRepository(MockClient((_) async => http.Response('', 404)));
    await expectLater(unavailable.latest(), throwsA(isA<FirmwareReleaseException>()));
    final invalid = asset('lumadrive-v0.1.0-esp32dev.bin')..['browser_download_url'] = 'https://example.com/firmware.bin';
    final repository = FirmwareReleaseRepository(MockClient((_) async => http.Response(jsonEncode(release(assets: [invalid])), 200)));
    await expectLater(repository.latest(), throwsA(isA<FirmwareReleaseException>()));
  });

  test('rejects truncated firmware', () async {
    final repository = FirmwareReleaseRepository(MockClient((_) async => http.Response.bytes([1, 2], 200)));
    final latest = FirmwareRelease(version: 'v0.1.0', assetName: 'firmware.bin', url: Uri.https('github.com', '/file'), size: 3);
    await expectLater(repository.download(latest), throwsA(isA<FirmwareReleaseException>()));
  });
}
