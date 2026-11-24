import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lumadrive_control/repositories/firmware_release_repository.dart';
import 'package:lumadrive_control/widgets/firmware_update_dialog.dart';

void main() {
  testWidgets(
    'shows update success and failure beside the corresponding nodes',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OtaDeviceList(
              nodes: [
                [2, 0, 0, 0, 0, 1],
                [2, 0, 0, 0, 0, 2],
              ],
              completed: {0},
              failed: 1,
            ),
          ),
        ),
      );
      expect(find.text('Node 02:00:00:00:00:01'), findsOneWidget);
      expect(find.text('Node 02:00:00:00:00:02'), findsOneWidget);
      expect(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Node 02:00:00:00:00:01'),
          matching: find.byIcon(Icons.check_circle),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.widgetWithText(ListTile, 'Node 02:00:00:00:00:02'),
          matching: find.byIcon(Icons.error_outline),
        ),
        findsOneWidget,
      );
      expect(find.text('Controller'), findsOneWidget);
    },
  );
  testWidgets('downloads and selects the latest release', (tester) async {
    final repository = FirmwareReleaseRepository(
      MockClient((request) async {
        if (request.url.host == 'api.github.com') {
          return http.Response(
            jsonEncode({
              'tag_name': 'v0.1.0',
              'assets': [
                {
                  'name': 'lumadrive-v0.1.0-esp32dev.bin',
                  'state': 'uploaded',
                  'size': 3,
                  'browser_download_url': 'https://github.com/ipg0/lumadrive-firmware/releases/download/v0.1.0/lumadrive-v0.1.0-esp32dev.bin',
                },
              ],
            }),
            200,
          );
        }
        return http.Response.bytes([1, 2, 3], 200);
      }),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firmwareReleaseRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: Scaffold(body: FirmwareUpdateDialog())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('v0.1.0'), findsOneWidget);
    await tester.tap(find.text('Use latest release'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Or choose a firmware file'));
    await tester.pumpAndSettle();
    expect(
      find.text('Selected: lumadrive-v0.1.0-esp32dev.bin'),
      findsOneWidget,
    );
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Update'),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets(
    'keeps manual file selection available when release lookup fails',
    (tester) async {
      final repository = FirmwareReleaseRepository(
        MockClient((_) async => http.Response('', 404)),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            firmwareReleaseRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: Scaffold(body: FirmwareUpdateDialog()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('No published firmware release'),
        findsOneWidget,
      );
      final button = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'Choose .bin file'),
      );
      expect(button.onPressed, isNotNull);
    },
  );
}
