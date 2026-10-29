import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';
import 'package:flutter/material.dart';
import 'package:lumadrive_control/routing/route_observer.dart';
import 'package:animations/animations.dart';
import 'package:lumadrive_control/widgets/pages/device_select_page.dart';
import 'package:lumadrive_control/widgets/pages/device_add_page.dart';
import 'package:lumadrive_control/widgets/pages/saved_device_connection_page.dart';
import 'package:lumadrive_control/widgets/pages/device_home_page.dart';
import 'package:lumadrive_control/widgets/pages/layout_editor_page.dart';
import 'package:lumadrive_control/widgets/pages/matrix_editor_page.dart';

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

/// Route guards follow connection readiness; the layout route retains its owner
/// while offline so its saved draft remains accessible.
String? connectionRedirect(BleState connection, Uri uri) {
  final path = uri.path;
  if (path == '/device/layout' || path == '/device/matrix') {
    final owner = uri.queryParameters['controller'];
    if (owner == null || owner.isEmpty) {
      if (connection is! BleConnected) return '/';
      return Uri(
        path: path,
        queryParameters: {'controller': connection.device.remoteId},
      ).toString();
    }
    if (connection is BleConnected && connection.device.remoteId != owner) {
      return '/device';
    }
    if (connection is BleConnecting && connection.device.remoteId != owner) {
      return '/connect';
    }
    return null;
  }
  if (connection is BleConnected &&
      (path == '/' || path == '/pair' || path == '/connect')) {
    return '/device';
  }
  if (path == '/connect' &&
      (connection is BleIdle || connection is BleScanning)) {
    return connection is BleScanning ? '/pair' : '/';
  }
  if (path == '/device' && connection is! BleConnected) {
    if (connection is BleConnecting) return '/connect';
    if (connection is BleError && connection.device != null) return null;
    return '/';
  }
  return null;
}

GoRouter createAppRouter({
  required BleState Function() connection,
  Listenable? refreshListenable,
  String initialLocation = '/',
}) => GoRouter(
  initialLocation: initialLocation,
  refreshListenable: refreshListenable,
  redirect: (context, state) => connectionRedirect(connection(), state.uri),
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
      routes: [
        GoRoute(
          path: 'matrix',
          pageBuilder: (context, state) => _sharedAxisTransition(
            context: context,
            state: state,
            child: MatrixEditorPage(
              key: ValueKey(state.uri.queryParameters['controller']),
              controllerId: state.uri.queryParameters['controller'],
            ),
          ),
        ),
        GoRoute(
          path: 'layout',
          pageBuilder: (context, state) => _sharedAxisTransition(
            context: context,
            state: state,
            child: LayoutEditorPage(
              key: ValueKey(state.uri.queryParameters['controller']),
              controllerId: state.uri.queryParameters['controller'],
            ),
          ),
        ),
      ],
    ),
  ],
);

class _RouterRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh();
  ref.listen(bleControllerProvider, (_, _) => refresh.refresh());
  final router = createAppRouter(
    connection: () => ref.read(bleControllerProvider),
    refreshListenable: refresh,
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
