# Matrix upload API

The connected master's `MeshController` provides configuration upload and status
without an editor UI. Protocol definitions are generated from `../proto/mesh.proto`.

```dart
final controller = ref.read(meshControllerProvider.notifier);
final status = await controller.getMatrixStatus();
final config = MatrixConfig(
  schemaVersion: 2,
  layout: [MatrixLayout(nodeMac: status.masterMac, driver: MatrixDriver.WS2812,
    from: 0, to: 60)],
  effects: [MatrixEffect(
    id: 1, kind: MatrixEffect_Kind.STATIC_COLOR,
    red: 255, green: 0, blue: 0, alpha: 255,
  )],
  sources: [MatrixSource(id: 1, kind: MatrixSource_Kind.DEFAULT_STATE)],
  conditions: [MatrixCondition(id: 1, kind: MatrixCondition_Kind.ALWAYS)],
  entries: [MatrixEntry(
    id: 1, effectId: 1, sourceId: 1, conditionId: 1, priority: 0,
  )],
);
await for (final progress in controller.uploadMatrixConfig(config)) {
  // Inspect transferredBytes, totalBytes, and status; update UI as appropriate.
}
```

IDs must be nonzero and unique within each entity category. A configuration
replaces the full matrix and is persisted on the master. Driver IDs refer to
firmware-owned hardware; uploads cannot change wiring. `layout` is the one physical
arrangement of the car, shared by every animation. Entries have no driver targets
or private layouts. Alpha zero is transparent; duration zero holds
indefinitely. The supported conditions are currently `ALWAYS`.

Layout elements identify a node/driver and boundary indices `from`/`to`.
`0 → 60` covers 60 pixels (0–59); `12 → 10` covers pixels 11,10 in reverse.
The span must equal the physical driver's pixel count. Overlapping outputs
display the same global samples; gaps are allowed. The canvas ends at the
greatest boundary. Each node receives that same global extent and its own mappings.
See [Car layout](../../firmware/docs/layout.md) for examples and validation limits.

Effects also support `KEYFRAMES`, `BLINK`, `BREATHE`, and `FLOWING_GRADIENT`.
Keyframes use stable `trackId` values with RGBA, fractional `position`/`width`,
`timeMs`, and `interpolation` (`LINEAR`, `STEP`, or `SMOOTH`). Interpolating geometry
moves/resizes shapes instead of requiring keyframes for every LED. `wrap: true`
flows shapes through the global canvas boundary. For example, two frames at positions 0
and 60 move a band around a 60-pixel canvas. Width defaults to one; explicit zero
collapses the shape. Set `allPixels: true` for a whole-canvas color track.
Each track starts at zero and has at least two frames; at most 16 frames may be
shared across all tracks. Tracks may overlap and composite in first-appearance
order. `wrap` and `allPixels` stay constant within each track. `loop: true` wraps
all tracks at the greatest frame time; otherwise each holds its last pose/color.
Uncovered pixels retain the layers below. Primary RGBA fields on `MatrixEffect`
are unused by keyframes.

Parametric effects use primary RGBA and `periodMs` (zero defaults to 1000).
Blink adds `dutyPercent` (zero defaults to 50); breathe smoothly varies alpha.
Flowing gradients span the shared canvas and require `secondaryColor: MatrixColor(...)` and optionally
`wavelengthPixels` and `reverse`. `durationMs` independently limits effect lifetime;
zero remains indefinite. For complete examples, see
[Animation effects](../../firmware/docs/animations.md).

For `GPIO_EDGE`, set `nodeMac` to the owning node's ESP-NOW MAC: `status.masterMac`
for a master input, or a paired slave's `nodeMac` from `status.nodes`. Set `gpio`
to a permitted input and `rising` for the desired edge. For example, a source
with `nodeMac: [4, 1, 2, 3, 4, 5], gpio: 12, rising: true` listens for rising edges
on GPIO12 of that slave. A source node need not have outputs in the car layout.
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

Limits: 32 entries, 32 definitions per category, 34 layout elements on 17 nodes,
and 16 KiB encoded configuration bytes. Only the current configuration format
is supported; earlier development configurations can be discarded without migration.
Run API tests with
`flutter test test/matrix_client_test.dart`.
