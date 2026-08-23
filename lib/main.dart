import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/routing/app_router.dart';
import 'package:relative_time/relative_time.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lumadrive Control',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple, brightness: .dark),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
      localizationsDelegates: [
        ...GlobalMaterialLocalizations.delegates,
        RelativeTimeLocalizations.delegate,
      ],
      supportedLocales: [const Locale('en')],
    );
  }
}
