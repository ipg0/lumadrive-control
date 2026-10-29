# Matrix upload API

The connected master's `MeshController` provides configuration upload, status,
and the Car layout editor APIs. Protocol definitions are generated from
`../proto/mesh.proto`.

The **Matrix & animations** screen configures table entries and simple effects;
see the [configurator guide](matrix_editor.md) for its workflow and read/update APIs.

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
The span configures a strip's LED count, up to its reported `maxPixelCount`
(currently 2,048), or exactly one pixel for an individual RGB LED. Overlapping outputs
display the same global samples; gaps are allowed. The canvas ends at the
greatest boundary. Each node receives that same global extent and its own mappings.
See [Car layout](../../firmware/docs/layout.md) for examples and validation limits.

The default Simple editor assigns `carPosition` locations and packs their spans
from rear left around the car to rear right. Advanced edits the same coordinates
with a ruler, including overlaps. Switching modes preserves the draft. Inventory
`pixelCount` is the firmware's initial length; saved layout spans hold user lengths.
`identifyOutput(token, index, pixelCount: 120, reversed: true)` previews an unsaved
length/direction with a two-second progressive fill and one-second full hold,
without changing the saved matrix. The
compact identify envelope also fits MTU 23. Individual module LEDs pulse green.
Selecting a light from the car's assignment dropdown automatically invokes this
preview. The selected-output card can assign its light directly to the currently
selected segment; both widgets share `selectedCarPosition` in the editor controller.

Effects also support `KEYFRAMES`, `BLINK`, `BREATHE`, `FLOWING_GRADIENT`, and `RAINBOW`.
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

`RAINBOW` uses the full RGB spectrum and primary alpha, with the same period,
wavelength, and reverse controls. A fresh master persists a preconfigured
eight-second rainbow matrix. Every output starts at zero, so drivers overlap
and the canvas is only as long as the largest output. Newly discovered outputs
join this initial layout until any user configuration is saved. An explicitly
empty user matrix remains empty.

## Reading configuration state

```dart
final desired = await controller.readMatrix();
final current = await controller.readCurrentMatrix();
final playingConfig = MatrixConfig.fromBuffer(current.config);
// current.revision identifies the master's active configuration.
// activationPending reports a revision waiting to activate.
// persisted reports whether the returned configuration is saved in flash.
```

Both methods return a frozen `MatrixDocument` with full protobuf configuration
bytes, session, master MAC, input capabilities, and `activeRevision`.
`readMatrix()` includes an accepted revision still deploying; `readCurrentMatrix()`
retains the previous configuration until activation. Before any revision plays,
the active read returns revision zero with an empty configuration.
The Matrix & animations screen shows these revisions and offers **Read current
state** without replacing a local draft. Reads use bounded pages over the existing
encrypted BLE characteristics and work at the minimum ATT MTU of 23.

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

Limits: 32 entries, 32 definitions per category, six physical drivers per node,
84 placed light sources across up to 17 mesh nodes,
and 16 KiB encoded configuration bytes. Only the current configuration format
is supported; earlier development configurations can be discarded without migration.
Run API tests with
`flutter test test/matrix_client_test.dart`.

## Car layout editor API

The device home screen links to **Car layout**, which uses the existing dark
Material theme. Simple places lights on a car graphic; Advanced offers the shared
ruler with draggable output bars, View zoom, numeric positioning and overlaps.
Both support configurable strip lengths, reversal, friendly names, and device
availability. Drafts persist per controller on the phone.

```dart
final saved = await controller.readLayout();
final snapshot = saved.snapshot;
// Pixel counts come from firmware, not a hard-coded app wiring model.
final output = snapshot.outputs.first;
await controller.identifyOutput(saved.snapshotId, 0);
final placement = MatrixLayout(
  nodeMac: output.nodeMac, driver: output.driver,
  from: 0, to: output.pixelCount, name: 'Dashboard',
);
await for (final progress in controller.uploadLayout(LayoutUpdate(
  expectedRevision: snapshot.revision,
  masterSession: snapshot.masterSession,
  layout: [placement],
))) {
  // Render transfer progress and deployment status.
}
```

`readLayout()` reads a frozen paged snapshot of saved placements and firmware
inventory. `identifyOutput()` takes an index from that snapshot, acknowledges
the actual node, and runs a two-second fill followed by a one-second hold using the optional draft
length and direction. A point source pulses green instead.
The editor obtains a fresh snapshot before Identify to avoid expired tokens.
`uploadLayout()` replaces the layout while preserving effects, sources,
conditions, and entries on the master. Expected revision and session prevent
overwriting concurrent changes. Invalid uploads leave the active matrix running.
All nodes and the app must use the updated protocol.

Driver slots 1–6 are independent of hardware type. Use `LayoutOutput.driverKind`
to distinguish strips from RGB modules. A two-LED 595 reports two outputs with
the same `driver` and different `sourceIndex` values (0/1), each `pixelCount: 1`.
Include `sourceIndex` in every `MatrixLayout` and in output identity. The two LEDs
can have unrelated positions. The editor shows them as individual point lights;
Identify affects only the selected LED. Inventory pages may total up to 32 KiB.

`LayoutEditorController` owns draft validation, inventory polling, conflict
handling, progress, and disk persistence. `LayoutRepository` isolates hardware
for tests. Run editor and API checks with `flutter test`; widget tests cover
narrow-screen input, reversal, overlap touch targets, placement, and disconnects.
