import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:lumadrive_control/routing/route_observer.dart';
import 'package:animations/animations.dart';
import 'package:lumadrive_control/widgets/pages/device_select_page.dart';
import 'package:lumadrive_control/widgets/pages/device_add_page.dart';
import 'package:lumadrive_control/widgets/pages/saved_device_connection_page.dart';
import 'package:lumadrive_control/widgets/pages/device_home_page.dart';

CustomTransitionPage<T> _sharedAxisTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.horizontal,
        child: child,
      );
    },
  );
}

final appRouter = GoRouter(
  observers: [routeObserver],
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _sharedAxisTransition(
        context: context,
        state: state,
        child: const DeviceSelectPage(),
      ),
    ),
    GoRoute(
      path: '/pair',
      pageBuilder: (context, state) => _sharedAxisTransition(
        context: context,
        state: state,
        child: const DeviceAddPage(),
      ),
    ),
    GoRoute(
      path: '/connect',
      pageBuilder: (context, state) => _sharedAxisTransition(
        context: context,
        state: state,
        child: const SavedDeviceConnectionPage(),
      ),
    ),
    GoRoute(
      path: '/device',
      pageBuilder: (context, state) => _sharedAxisTransition(
        context: context,
        state: state,
        child: const DeviceHomePage(),
      ),
    ),
  ],
);
