import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lumadrive_control/utils/stringify_mac.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';
import 'package:lumadrive_control/controllers/mesh_controller.dart';
import 'package:relative_time/relative_time.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DeviceHomePage extends ConsumerStatefulWidget {
  const DeviceHomePage({super.key});

  @override
  ConsumerState<DeviceHomePage> createState() => _DeviceHomePageState();
}

class _DeviceHomePageState extends ConsumerState<DeviceHomePage> {
  Timer? _relativeTimeRefreshTimer;

  @override
  void initState() {
    super.initState();
    _relativeTimeRefreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _relativeTimeRefreshTimer?.cancel();
    super.dispose();
  }

  Widget _buildLoadingSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        key: const ValueKey('mesh-loading'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
              child: const ListTile(
                title: Text('AA:AA:AA:AA:AA:AA'),
                subtitle: Text('Online 1 minute ago'),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMasterMeshListNode(
    BuildContext context,
    WidgetRef ref,
    MeshState mesh,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
        child: ListTile(
          title: Text(mesh.masterDevice.advName),
          subtitle: Text("Master"),
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: const Icon(
              Icons.circle,
              color: Colors.greenAccent,
              size: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlaveMeshListNode(
    BuildContext context,
    WidgetRef ref,
    MeshState mesh,
    int index,
  ) {
    final node = mesh.interopState.nodes[index];
    final nodeOnline = ref
        .read(meshControllerProvider.notifier)
        .getNodeOnlineStatus(node);
    final lastSyncedAt = ref
        .read(meshControllerProvider.notifier)
        .getNodeLastSyncedAt(node);
    final lastSyncedRelative = lastSyncedAt?.relativeTime(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
        child: ListTile(
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: nodeOnline
                ? const Icon(Icons.circle, color: Colors.greenAccent, size: 12)
                : const Icon(Icons.circle, color: Colors.redAccent, size: 12),
          ),
          title: Text('Slave ${macBytesToString(node.mac)}'),
          subtitle: Text(
            '${nodeOnline ? 'Online' : 'Offline'} (synced $lastSyncedRelative)',
          ),
        ),
      ),
    );
  }

  Widget _buildMeshList(BuildContext context, WidgetRef ref, MeshState mesh) {
    return Column(
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            leading: Icon(
              Icons.table_rows_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Matrix & animations'),
            subtitle: const Text(
              'Configure triggers, layers and animation settings',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(
              Uri(
                path: '/device/matrix',
                queryParameters: {'controller': mesh.masterDevice.remoteId},
              ).toString(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            leading: Icon(
              Icons.view_timeline_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Car layout'),
            subtitle: const Text(
              'Arrange strips and modules on one shared canvas',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(
              Uri(
                path: '/device/layout',
                queryParameters: {'controller': mesh.masterDevice.remoteId},
              ).toString(),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Nodes', style: Theme.of(context).textTheme.titleMedium),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          key: const ValueKey('mesh-list'),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mesh.interopState.nodes.length + 1,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildMasterMeshListNode(context, ref, mesh);
            } else {
              return _buildSlaveMeshListNode(context, ref, mesh, index - 1);
            }
          },
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    final connected = ref.watch(bleControllerProvider) is BleConnected;
    return Column(
      key: const ValueKey('mesh-error'),
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 16,
      children: [
        Text(
          connected
              ? 'Could not load controller state'
              : 'Lost connection to device',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
              Icon(
                Icons.link_off,
                size: 48,
                color: Theme.of(context).colorScheme.onError,
              ),
            ],
          ),
        ),
        Text(
          error.toString(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (connected)
          FilledButton.icon(
            onPressed: () => ref.invalidate(meshControllerProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ElevatedButton.icon(
          onPressed: () {
            ref.read(bleControllerProvider.notifier).disconnect();
            context.go('/');
          },
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back to controller list'),
        ),
      ],
    );
  }

  Widget _buildMeshContent(BuildContext context, WidgetRef ref) {
    final meshState = ref.watch(meshControllerProvider);

    if (meshState.isLoading) {
      return _buildLoadingSkeleton();
    }

    return PageTransitionSwitcher(
      duration: 300.milliseconds,
      transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
      child: meshState.when(
        data: (mesh) => _buildMeshList(context, ref, mesh),
        error: (error, stackTrace) => _buildErrorState(context, ref, error),
        loading: _buildLoadingSkeleton,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bleState = ref.watch(bleControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(bleState.deviceName ?? 'Controller'),
        actions: [
          IconButton(
            tooltip: 'Disconnect controller',
            icon: const Icon(Icons.bluetooth_disabled),
            onPressed: () =>
                ref.read(bleControllerProvider.notifier).disconnect(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(child: _buildMeshContent(context, ref)),
      ),
    );
  }
}
