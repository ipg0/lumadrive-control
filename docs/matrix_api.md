# Matrix upload API

The connected master's `MeshController` provides configuration upload and status
without an editor UI. Protocol definitions are generated from `../proto/mesh.proto`.

```dart
final controller = ref.read(meshControllerProvider.notifier);
final status = await controller.getMatrixStatus();
final config = MatrixConfig(
  schemaVersion: 1,
  effects: [MatrixEffect(
    id: 1, kind: MatrixEffect_Kind.STATIC_COLOR,
    red: 255, green: 0, blue: 0, alpha: 255,
  )],
  sources: [MatrixSource(id: 1, kind: MatrixSource_Kind.DEFAULT_STATE)],
  conditions: [MatrixCondition(id: 1, kind: MatrixCondition_Kind.ALWAYS)],
  entries: [MatrixEntry(
    id: 1, effectId: 1, sourceId: 1, conditionId: 1, priority: 0,
    targets: status.nodes.map((node) => MatrixTarget(
      nodeMac: node.nodeMac, driver: MatrixDriver.WS2812,
    )),
  )],
);
await for (final progress in controller.uploadMatrixConfig(config)) {
  // Inspect transferredBytes, totalBytes, and status; update UI as appropriate.
}
```

IDs must be nonzero and unique within each entity category. A configuration
replaces the full matrix and is persisted on the master. Driver IDs refer to
firmware-owned hardware; uploads cannot change wiring. An entry can target both
drivers of a node using distinct node/driver targets. Alpha zero is transparent; duration zero holds
indefinitely. The supported conditions are currently `ALWAYS`.

For `GPIO_EDGE`, set `nodeMac` to the owning node's ESP-NOW MAC: `status.masterMac`
for a master input, or a paired slave's `nodeMac` from `status.nodes`. Set `gpio`
to a permitted input and `rising` for the desired edge. For example, a source
with `nodeMac: [4, 1, 2, 3, 4, 5], gpio: 12, rising: true` listens for rising edges
on GPIO12 of that slave. A source node need not be an animation target.
Inputs require external biasing; firmware rejects reserved pins. Bluetooth
device IDs are not ESP-NOW MACs. All nodes must run firmware with GPIO reporting.
The master remains responsible for trigger evaluation; slaves report captured
timestamps through an acknowledged event stream. GPIO loss marks the affected
node `DEGRADED`; animation recovery cannot recreate physical edges lost offline.

`watchMatrixStatus()` emits status on notification invalidations. Its subscription
must be cancelled by its owner. `getMatrixStatus()` reads the current snapshot.
An upload stream finishes at master activation; offline/degraded targets may
still be recovering, so inspect per-node state. Playback uses shared-clock
timestamps with a 100 ms GPIO trigger lead and phase-correct late delivery.

`MatrixUploadException` carries validation/deployment status when available.
Transport failures propagate. Cancelling an upload stream aborts a partial
upload; an already accepted commit continues deployment. Only one upload per
client may run at a time. The client sizes protobuf envelopes for the negotiated
MTU and waits for application-level byte acknowledgements.

Limits: 32 entries, 32 definitions per category, 17 distinct node/driver targets per
entry, and 16 KiB encoded configuration bytes. Run API tests with
`flutter test test/matrix_client_test.dart`.
