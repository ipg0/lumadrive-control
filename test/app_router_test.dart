import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';
import 'package:lumadrive_control/main.dart';
import 'package:lumadrive_control/providers/saved_devices_provider.dart';
import 'package:lumadrive_control/repositories/ble_repository.dart';
import 'package:lumadrive_control/routing/app_router.dart';
import 'package:lumadrive_control/repositories/layout_repository.dart';

import 'connection_fakes.dart';
import 'layout_fakes.dart';

void main() {
  final service = TestBleService('service');
  final ready = BleConnected(firstController, lumadriveService: service);
  test('connection routes have defined guards for every BLE state', () {
    final states = <BleState>[
      const BleIdle(),
      const BleScanning({}),
      const BleConnecting(firstController),
      ready,
      const BleError('Disconnected', device: firstController),
    ];
    final expected = {
      '/': [null, null, null, '/device', null],
      '/pair': [null, null, null, '/device', null],
      '/connect': ['/', '/pair', null, '/device', null],
      '/device': ['/', '/', '/connect', null, null],
      '/device/layout': [
        '/',
        '/',
        '/',
        '/device/layout?controller=first-controller',
        '/',
      ],
      '/device/matrix': [
        '/',
        '/',
        '/',
        '/device/matrix?controller=first-controller',
        '/',
      ],
    };
    for (final entry in expected.entries) {
      for (var i = 0; i < states.length; i++) {
        expect(
          connectionRedirect(states[i], Uri.parse(entry.key)),
          entry.value[i],
          reason: '${states[i].runtimeType} at ${entry.key}',
        );
      }
    }
  });
  test(
    'layout ownership survives disconnection and fences another controller',
    () {
      final layout = Uri.parse('/device/layout?controller=first-controller');
      expect(connectionRedirect(const BleIdle(), layout), isNull);
      expect(connectionRedirect(const BleError('Lost'), layout), isNull);
      expect(connectionRedirect(ready, layout), isNull);
      expect(
        connectionRedirect(
          BleConnected(secondController, lumadriveService: service),
          layout,
        ),
        '/device',
      );
      expect(
        connectionRedirect(const BleConnecting(secondController), layout),
        '/connect',
      );
    },
  );
  testWidgets(
    'service-ready state navigates automatically and disconnect returns to selection',
    (tester) async {
      final repository = TestBleRepository();
      final container = ProviderContainer(
        overrides: [
          bleRepositoryProvider.overrideWithValue(repository),
          bleControllerProvider.overrideWith(TestConnectionController.new),
          savedDevicesProvider.overrideWith((ref) => Stream.value([])),
        ],
      );
      final connection = container.read(
        bleControllerProvider.notifier,
      ) as TestConnectionController;
      addTearDown(() async {
        container.dispose();
        await repository.close();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const MyApp()),
      );
      await tester.pumpAndSettle();
      final router = container.read(appRouterProvider);
      connection.emit(const BleConnecting(firstController));
      router.push('/connect');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Connecting to controller'), findsOneWidget);
      connection.emit(ready);
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/device');
      expect(find.byTooltip('Car layout'), findsOneWidget);
      repository.meshStreams[service]!.addError(StateError('Mesh unavailable'));
      await tester.pumpAndSettle();
      expect(find.text('Could not load controller state'), findsOneWidget);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Car layout'), findsOneWidget);
      await tester.tap(find.byTooltip('Disconnect controller'));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/');
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'Back cancels connection work instead of leaving a blank connect screen',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          bleControllerProvider.overrideWith(TestConnectionController.new),
          savedDevicesProvider.overrideWith((ref) => Stream.value([])),
        ],
      );
      final connection = container.read(
        bleControllerProvider.notifier,
      ) as TestConnectionController;
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const MyApp()),
      );
      await tester.pumpAndSettle();
      final router = container.read(appRouterProvider);
      connection.emit(const BleConnecting(firstController));
      router.push('/connect');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(router.canPop(), isTrue);
      router.pop();
      await tester.pumpAndSettle();
      expect(container.read(bleControllerProvider), isA<BleIdle>());
      expect(router.routeInformationProvider.value.uri.path, '/');
      router.go('/connect');
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/');
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'layout has a home parent, remains open offline and rejects a different controller',
    (tester) async {
      final repository = TestBleRepository();
      final container = ProviderContainer(
        overrides: [
          bleRepositoryProvider.overrideWithValue(repository),
          bleControllerProvider.overrideWith(TestConnectionController.new),
          layoutDraftStoreProvider.overrideWith(
            (ref, id) => MemoryLayoutStore(),
          ),
          savedDevicesProvider.overrideWith((ref) => Stream.value([])),
        ],
      );
      addTearDown(() async {
        container.dispose();
        await repository.close();
      });
      final connection = container.read(
        bleControllerProvider.notifier,
      ) as TestConnectionController;
      connection.emit(ready);
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const MyApp()),
      );
      await tester.pumpAndSettle();
      final router = container.read(appRouterProvider);
      await tester.tap(find.byTooltip('Car layout'));
      await tester.pumpAndSettle();
      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        '/device/layout',
      );
      expect(router.canPop(), isTrue);
      expect(
        router
            .routerDelegate
            .currentConfiguration
            .uri
            .queryParameters['controller'],
        firstController.remoteId,
      );
      router.pop();
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.path, '/device');
      await tester.tap(find.byTooltip('Car layout'));
      await tester.pumpAndSettle();
      connection.emit(const BleError('Disconnected', device: firstController));
      await tester.pumpAndSettle();
      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        '/device/layout',
      );
      expect(find.text('Reconnect'), findsOneWidget);
      connection.emit(
        BleConnected(secondController, lumadriveService: service),
      );
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.path, '/device');
      expect(find.text(secondController.advName), findsWidgets);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('saved-device loading errors have a retry state', (tester) async {
    var fail = true;
    final container = ProviderContainer(
      overrides: [
        bleControllerProvider.overrideWith(TestConnectionController.new),
        savedDevicesProvider.overrideWith(
          (ref) => fail
              ? Stream.error(StateError('Database unavailable'))
              : Stream.value([]),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Could not load saved controllers'), findsOneWidget);
    expect(find.text('No saved controllers'), findsNothing);
    fail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('No saved controllers'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
