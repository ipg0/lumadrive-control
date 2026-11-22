import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final firmwareReleaseRepositoryProvider = Provider<FirmwareReleaseRepository>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return FirmwareReleaseRepository(client);
});

class FirmwareRelease {
  const FirmwareRelease({required this.version, required this.assetName, required this.url, required this.size});
  final String version;
  final String assetName;
  final Uri url;
  final int size;
}

class FirmwareReleaseException implements Exception {
  const FirmwareReleaseException(this.message);
  final String message;
  @override
  String toString() => message;
}

class FirmwareReleaseRepository {
  FirmwareReleaseRepository(this._client);
  final http.Client _client;
  static final _latest = Uri.https('api.github.com', '/repos/ipg0/lumadrive-firmware/releases/latest');
  static const _maximumImageBytes = 8 * 1024 * 1024;
  static const _timeout = Duration(seconds: 30);

  Future<FirmwareRelease> latest() async {
    final response = await _client.get(_latest, headers: {
      'Accept': 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
    }).timeout(_timeout);
    if (response.statusCode == 404) throw const FirmwareReleaseException('No published firmware release was found.');
    if (response.statusCode != 200) throw FirmwareReleaseException('GitHub returned HTTP ${response.statusCode}.');
    final dynamic decoded;
    try { decoded = jsonDecode(response.body); } on FormatException {
      throw const FirmwareReleaseException('GitHub returned an invalid release.');
    }
    if (decoded is! Map<String, dynamic> || decoded['tag_name'] is! String || decoded['assets'] is! List) {
      throw const FirmwareReleaseException('GitHub returned an invalid release.');
    }
    final version = decoded['tag_name'] as String;
    final assets = (decoded['assets'] as List).whereType<Map<String, dynamic>>().where((asset) {
      final name = asset['name'];
      return name is String && RegExp(r'^lumadrive-.+-esp32dev\.bin$').hasMatch(name) && asset['state'] == 'uploaded';
    }).toList();
    final exact = assets.where((asset) => asset['name'] == 'lumadrive-$version-esp32dev.bin').toList();
    final matches = exact.isNotEmpty ? exact : assets;
    if (matches.isEmpty) throw const FirmwareReleaseException('The latest release has no ESP32 firmware file.');
    if (matches.length != 1) throw const FirmwareReleaseException('The latest release has multiple matching firmware files.');
    final asset = matches.single;
    final url = asset['browser_download_url'] is String ? Uri.tryParse(asset['browser_download_url'] as String) : null;
    final size = asset['size'];
    if (version.isEmpty || url == null || url.scheme != 'https' || url.host != 'github.com' ||
        !url.path.startsWith('/ipg0/lumadrive-firmware/releases/download/') ||
        size is! int || size <= 0 || size > _maximumImageBytes) {
      throw const FirmwareReleaseException('The firmware release contains an invalid download.');
    }
    return FirmwareRelease(version: version, assetName: asset['name'] as String, url: url, size: size);
  }

  Future<Uint8List> download(FirmwareRelease release, {void Function(double)? onProgress}) async {
    final response = await _client.send(http.Request('GET', release.url)).timeout(_timeout);
    if (response.statusCode != 200) throw FirmwareReleaseException('Firmware download failed (HTTP ${response.statusCode}).');
    if (response.contentLength != null && response.contentLength != release.size) {
      throw const FirmwareReleaseException('The firmware download size does not match the release.');
    }
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in response.stream.timeout(_timeout)) {
      if (bytes.length + chunk.length > release.size || bytes.length + chunk.length > _maximumImageBytes) {
        throw const FirmwareReleaseException('The firmware download is larger than expected.');
      }
      bytes.add(chunk);
      onProgress?.call(bytes.length / release.size);
    }
    if (bytes.length != release.size) throw const FirmwareReleaseException('The firmware download is incomplete.');
    return bytes.takeBytes();
  }
}
