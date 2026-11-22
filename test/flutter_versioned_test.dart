import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory repository;
  late String script;

  Future<ProcessResult> git(List<String> arguments) async {
    final result = await Process.run('git', arguments, workingDirectory: repository.path);
    expect(result.exitCode, 0, reason: '${result.stderr}');
    return result;
  }

  Future<ProcessResult> versioned(List<String> arguments, {Map<String, String>? environment}) =>
      Process.run('bash', [script, ...arguments], workingDirectory: repository.path, environment: environment);

  setUp(() async {
    repository = await Directory.systemTemp.createTemp('lumadrive_version_test_');
    final tool = await Directory('${repository.path}/tool').create();
    script = '${tool.path}/flutter_versioned.sh';
    await File('tool/flutter_versioned.sh').copy(script);
    await git(['init', '-q']);
    await git(['config', 'user.name', 'Version test']);
    await git(['config', 'user.email', 'test@example.invalid']);
    await File('${repository.path}/tracked').writeAsString('one');
    await git(['add', 'tracked']);
    await git(['commit', '-qm', 'Initial commit']);
  });

  tearDown(() async => repository.delete(recursive: true));

  test('uses the nearest release tag and tracks commit count', () async {
    var result = await versioned(['--print-version']);
    expect(result.exitCode, 0);
    expect(result.stdout, '0.0.0+1\n');
    await git(['tag', 'v0.1.1']);
    result = await versioned(['--print-version']);
    expect(result.stdout, '0.1.1+1\n');
    await File('${repository.path}/tracked').writeAsString('two');
    await git(['commit', '-qam', 'Next commit']);
    result = await versioned(['--print-version']);
    expect(result.stdout, '0.1.1+2\n');
  });

  test('passes the version to Flutter and accepts a CI build number', () async {
    await git(['tag', '0.2.0']);
    final flutter = File('${repository.path}/fake_flutter');
    await flutter.writeAsString('#!/bin/sh\nprintf "%s\\n" "\u0024@"\n');
    await Process.run('chmod', ['+x', flutter.path]);
    final result = await versioned(['build', 'apk', '--release'], environment: {
      'FLUTTER_BIN': flutter.path,
      'LUMADRIVE_BUILD_NUMBER': '42',
    });
    expect(result.exitCode, 0, reason: '${result.stderr}');
    expect(result.stdout, contains('--build-name=0.2.0\n--build-number=42\n'));
    final invalid = await versioned(['--print-version'], environment: {'LUMADRIVE_BUILD_NUMBER': '0'});
    expect(invalid.exitCode, isNot(0));
  });
}
