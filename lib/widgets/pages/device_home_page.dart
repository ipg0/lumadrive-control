import 'dart:async';

import 'package:animations/animations.dart';
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
import 'package:skeletonizer/skeletonizer.dart';

class DeviceHomePage extends ConsumerStatefulWidget {
  const DeviceHomePage({super.key});

  @override
  ConsumerState<DeviceHomePage> createState() => _DeviceHomePageState();
}

class _NodeNameDialog extends StatefulWidget {
  const _NodeNameDialog({required this.address, this.current});
  final String address;
  final String? current;

  @override
  State<_NodeNameDialog> createState() => _NodeNameDialogState();
}

class _NodeNameDialogState extends State<_NodeNameDialog> {
  late final TextEditingController _name = TextEditingController(text: widget.current);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Name node'),
    content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.address, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 12),
      TextField(
        key: const ValueKey('node-name-input'),
        controller: _name,
        autofocus: true,
        maxLength: 32,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Node name',
          hintText: 'For example, Front doors',
          helperText: 'Saved on this device. Leave blank to use the address.',
          helperMaxLines: 2,
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => Navigator.of(context).pop(_name.text.trim()),
      ),
    ]),
    actions: [
      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
      FilledButton(
        onPressed: () => Navigator.of(context).pop(_name.text.trim()),
        child: const Text('Save'),
      ),
    ],
  );
}

class _DeviceHomePageState extends ConsumerState<DeviceHomePage> {
  Timer? _statusRefreshTimer;

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
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
        child: ListTile(
          title: Text(mesh.masterDevice.advName),
          subtitle: Text('Controller'),
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
          trailing: const Tooltip(message: 'Rename node', child: Icon(Icons.edit_outlined)),
        ),
      ),
    );
  }

  Widget _buildMeshList(BuildContext context, WidgetRef ref, MeshState mesh) {
    final names = mesh.interopState.nodes.isEmpty
        ? const <String, String>{}
        : ref.watch(nodeNamesProvider(mesh.masterDevice.remoteId)).value ?? const <String, String>{};
    return Column(
      children: [
        const ModeDashboard(),
        const SizedBox(height: 12),
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
              return _buildMasterMeshListNode(context, ref, mesh);
            } else {
              return _buildSlaveMeshListNode(context, ref, mesh, index - 1, names);
            }
          },
        ),
      ],
    );
  }

  Future<void> _renameNode(String controllerId, String address, String? current) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _NodeNameDialog(address: address, current: current),
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
