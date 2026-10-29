import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/routing/app_router.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:relative_time/relative_time.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      MCPToolkitBinding.instance
        ..initialize()
        ..initializeFlutterToolkit();
      runApp(const ProviderScope(child: MyApp()));
    },
    (error, stack) => MCPToolkitBinding.instance.handleZoneError(error, stack),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Lumadrive Control',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple, brightness: .dark),
        useMaterial3: true,
      ),
      routerConfig: ref.watch(appRouterProvider),
      localizationsDelegates: [
        ...GlobalMaterialLocalizations.delegates,
        RelativeTimeLocalizations.delegate,
      ],
      supportedLocales: [const Locale('en')],
    );
  }
}
