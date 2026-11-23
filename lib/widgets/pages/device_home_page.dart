import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lumadrive_control/utils/stringify_mac.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';
import 'package:lumadrive_control/controllers/mesh_controller.dart';
import 'package:lumadrive_control/repositories/database_repository.dart';
import 'package:lumadrive_control/widgets/matrix/mode_dashboard.dart';
import 'package:lumadrive_control/widgets/firmware_update_dialog.dart';
import 'package:lumadrive_control/widgets/firmware_versions_dialog.dart';
import 'package:lumadrive_control/widgets/node_name_dialog.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DeviceHomePage extends ConsumerStatefulWidget {
  const DeviceHomePage({super.key});

  @override
  ConsumerState<DeviceHomePage> createState() => _DeviceHomePageState();
}

class _DeviceHomePageState extends ConsumerState<DeviceHomePage> {
  Timer? _statusRefreshTimer;
  bool _identifyingNode = false;
  bool _resolvingController = false;
  String? _controllerAddress;

  @override
  void initState() {
    super.initState();
    _statusRefreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _statusRefreshTimer?.cancel();
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
    Map<String, String> names,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
        child: ListTile(
          title: Text(names[_controllerAddress] ?? mesh.masterDevice.advName),
          subtitle: Text('Controller'),
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: const Icon(
              Icons.circle,
              color: Colors.greenAccent,
              size: 12,
            ),
          ),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(tooltip: 'Identify controller', onPressed: _identifyingNode ? null : () => _identifyNode(null), icon: const Icon(Icons.highlight_outlined)),
            IconButton(tooltip: 'Rename controller', onPressed: _identifyingNode ? null : () => _renameController(mesh.masterDevice.remoteId, names), icon: const Icon(Icons.edit_outlined)),
          ]),
        ),
      ),
    );
  }

  Widget _buildSlaveMeshListNode(
    BuildContext context,
    WidgetRef ref,
    MeshState mesh,
    int index,
    Map<String, String> names,
  ) {
    final node = mesh.interopState.nodes[index];
    final address = macBytesToString(node.mac);
    final name = names[address];
    final nodeOnline = ref
        .read(meshControllerProvider.notifier)
        .getNodeOnlineStatus(node);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () => _renameNode(mesh.masterDevice.remoteId, address, name),
        style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
        child: ListTile(
          leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: nodeOnline
                ? const Icon(Icons.circle, color: Colors.greenAccent, size: 12)
                : const Icon(Icons.circle, color: Colors.redAccent, size: 12),
          ),
          title: Text(name ?? 'Node $address', maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${nodeOnline ? 'Online' : 'Offline'}${name == null ? '' : ' · $address'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(tooltip: 'Identify node', onPressed: !nodeOnline || _identifyingNode ? null : () => _identifyNode(node.mac), icon: const Icon(Icons.highlight_outlined)),
            IconButton(tooltip: 'Rename node', onPressed: () => _renameNode(mesh.masterDevice.remoteId, address, name), icon: const Icon(Icons.edit_outlined)),
          ]),
        ),
      ),
    );
  }

  Widget _buildMeshList(BuildContext context, WidgetRef ref, MeshState mesh) {
    if (_controllerAddress == null && !_resolvingController) {
      _resolvingController = true;
      Future<void>.microtask(_resolveControllerAddress);
    }
    final names = ref.watch(nodeNamesProvider(mesh.masterDevice.remoteId)).value ?? const <String, String>{};
    return Column(
      children: [
        const ModeDashboard(),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            leading: Icon(
              Icons.table_rows_outlined,
              color: Theme.of(context).colorScheme.secondary,
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
        Card(
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            leading: Icon(Icons.system_update_alt, color: Theme.of(context).colorScheme.primary),
            title: const Text('Update firmware'),
            subtitle: const Text('Install a firmware file on the controller'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showDialog<void>(context: context, barrierDismissible: false, builder: (_) => const FirmwareUpdateDialog()),
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(),
        ),
        Row(
          children: [
            Expanded(child: Text('Nodes', style: Theme.of(context).textTheme.titleMedium)),
            TextButton.icon(
              onPressed: () => showDialog<void>(context: context, builder: (_) => const FirmwareVersionsDialog()),
              icon: const Icon(Icons.info_outline),
              label: const Text('Versions'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.builder(
          key: const ValueKey('mesh-list'),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mesh.interopState.nodes.length + 1,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildMasterMeshListNode(context, ref, mesh, names);
            } else {
              return _buildSlaveMeshListNode(context, ref, mesh, index - 1, names);
            }
          },
        ),
      ],
    );
  }

  Future<void> _resolveControllerAddress() async {
    try {
      final status = await ref.read(meshControllerProvider.notifier).getMatrixStatus();
      if (mounted && status.masterMac.length == 6) {
        setState(() => _controllerAddress = macBytesToString(status.masterMac));
      }
    } catch (_) {
      // The controller status can be unavailable while reconnecting.
    } finally {
      _resolvingController = false;
    }
  }

  Future<void> _identifyNode(List<int>? nodeMac) async {
    setState(() => _identifyingNode = true);
    try {
      final controller = ref.read(meshControllerProvider.notifier);
      final result = await controller.readLayout();
      final target = nodeMac ?? result.snapshot.masterMac;
      final index = result.snapshot.outputs.indexWhere((output) =>
          listEquals(output.nodeMac, target) && output.known && output.ready && output.online);
      if (index < 0) throw StateError('No available lights found on this node');
      await controller.identifyOutput(result.snapshotId, index, wholeNode: true);
      if (mounted && nodeMac == null) setState(() => _controllerAddress = macBytesToString(target));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not identify node: $error')));
    } finally {
      if (mounted) setState(() => _identifyingNode = false);
    }
  }

  Future<void> _renameController(String controllerId, Map<String, String> names) async {
    try {
      final snapshot = await ref.read(meshControllerProvider.notifier).readLayout();
      final address = macBytesToString(snapshot.snapshot.masterMac);
      if (!mounted) return;
      setState(() => _controllerAddress = address);
      await _renameNode(controllerId, address, names[address]);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not read controller identity: $error')));
    }
  }

  Future<void> _renameNode(String controllerId, String address, String? current) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => NodeNameDialog(address: address, current: current),
    );
    if (name == null || !mounted) return;
    try {
      await ref.read(databaseRepositoryProvider).setNodeName(controllerId, address, name);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save the node name. Try again.')),
        );
      }
    }
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    final connected = ref.watch(bleControllerProvider) is BleConnected;
    return SizedBox(
      width: double.infinity,
      child: Column(
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
      ),
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
          if (bleState.device != null)
            IconButton(
              tooltip: 'Car layout',
              icon: const Icon(Icons.directions_car_outlined),
              onPressed: () => context.go(Uri(path: '/device/layout', queryParameters: {'controller': bleState.device!.remoteId}).toString()),
            ),
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
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: _buildMeshContent(context, ref),
          ),
        ),
      ),
    );
  }
}
