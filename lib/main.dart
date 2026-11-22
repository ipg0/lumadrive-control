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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff0be6f0),
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xff60e8f1),
          onPrimary: const Color(0xff00363b),
          primaryContainer: const Color(0xff004e57),
          onPrimaryContainer: const Color(0xffa6f6fb),
          secondary: const Color(0xffb8c2ff),
          onSecondary: const Color(0xff18286d),
          secondaryContainer: const Color(0xff303f86),
          onSecondaryContainer: const Color(0xffdee1ff),
          tertiary: const Color(0xffefaaff),
          onTertiary: const Color(0xff4b125b),
          tertiaryContainer: const Color(0xff652974),
          onTertiaryContainer: const Color(0xfff8d9ff),
          surface: const Color(0xff101720),
        ),
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
