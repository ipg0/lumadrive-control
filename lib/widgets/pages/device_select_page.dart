import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lumadrive_control/controllers/ble_controller.dart';
import 'package:lumadrive_control/providers/saved_devices_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DeviceSelectPage extends ConsumerWidget {
  const DeviceSelectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(savedDevicesProvider);
    final devicesEmpty =
        !devicesAsync.isLoading && (devicesAsync.value?.isEmpty ?? true);

    return Scaffold(
      appBar: AppBar(title: Text('Select controller')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(bleControllerProvider.notifier).reset();
          context.push('/pair');
        },
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: Skeletonizer(
            enabled: devicesAsync.isLoading,
            child: devicesEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 16,
                      children: [
                        Icon(
                          Icons.link_off,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        Text(
                          "No saved controllers",
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: devicesAsync.value?.length ?? 5,
                    itemBuilder: (context, index) {
                      final device = devicesAsync.value?.elementAtOrNull(index);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {
                            if (device != null) {
                              ref
                                  .read(bleControllerProvider.notifier)
                                  .connectToSavedDevice(device);
                              context.push('/connect');
                            }
                          },
                          child: ListTile(
                            title: Text(
                              device?.advName ?? "Loading...",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            subtitle: Text(
                              device?.remoteId.toString() ?? "Loading...",
                            ),
                            leading: Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(Icons.bluetooth, size: 24),
                            ),
                            trailing: IconButton(
                              onPressed: () async {
                                if (device == null) return;

                                final shouldDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Delete controller?'),
                                      content: Text(
                                        'This will remove ${device.advName} from your saved controllers.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        FilledButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (shouldDelete == true) {
                                  ref
                                      .read(bleControllerProvider.notifier)
                                      .deleteSavedDevice(device.remoteId);
                                }
                              },
                              icon: Icon(
                                Icons.delete,
                                size: 24,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
