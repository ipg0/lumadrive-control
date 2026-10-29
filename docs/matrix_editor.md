# Matrix and animation configurator

Open **Matrix & animations** from the connected controller home screen. The editor
uses the saved device configuration, preserves the car layout, and keeps a local
draft per controller. **Apply** validates, persists, and deploys the revision;
editing and previewing alone do not change physical outputs.

## Table

Add named entries in the Table tab, even when the animation library is empty.
Each entry offers **Create animation** inline: configure a simple effect and
choose **Use animation** to select it without leaving the entry or losing its
name, priority, and trigger settings. Saving the entry adds its new animation to
the draft together; cancelling the entry discards unused inline creations.
Each entry
selects an animation, a trigger, an Always condition, and priority 0–255. Higher
priorities render last with alpha blending. Arrow controls change registration
order; equal priorities render in the displayed order. Removing an entry changes
only the local draft until Apply.

Default state starts when the revision activates and restarts finite effects after
their duration. GPIO edge triggers select a node, a firmware-reported input pin,
and rising or falling edge. Each matching edge restarts the effect. Pins reserved
for wiring, role/discovery or flash are omitted. Inputs need external biasing.
Shared source definitions are copied when editing an entry so other entries keep
their trigger behavior.

## Simple animations

The Animations tab supports static color, blink, breathe, flowing gradient, and rainbow.
Use color presets or six-digit RGB hex values and an opacity slider. Duration zero
holds indefinitely; periods are milliseconds (zero uses 1,000 ms). Blink sets on
time from 1–100%. A flowing gradient adds a second RGBA color, wavelength in pixels
(zero spans the entire canvas), and reverse direction. Every effect uses the
single global layout; no per-animation output targeting exists.
Presets use saturated RGB values, including pure red `FF0000`, green `00FF00`,
and blue `0000FF`; white is a separate preset.

The on-phone preview shows one cycle across the global canvas with Play/Pause and
a phase slider. Duration is a separate playback lifetime setting. Existing
keyframe animations remain intact and selectable by table entries; this screen
does not edit keyframes. Duplicate copies animation data with a new stable ID.
An animation referenced by an entry cannot be deleted.

## Saving and recovery

**Apply animation** in the animation editor saves that animation to the controller
immediately and updates entries already using it. It preserves unrelated local
table and animation drafts and does not require the table's Apply button. The
form shows progress and keeps entered values after an error so Apply can be retried.
**Save draft** keeps animation changes only on the phone, including while offline.
A new library animation plays once assigned to an applied table entry.

Saved entry forms become durable local draft changes; the table's **Apply** sends
those changes together. Back/Cancel closes an unfinished form without committing
its temporary fields. Table Apply is disabled while a form is open, offline,
invalid, or in conflict. Nodes report deployment readiness after a save;
unavailable nodes recover when they reconnect.

Matrix updates carry an expected revision and master session and preserve layout
on the device. A concurrent layout-only change can rebase the draft; competing
matrix changes retain the draft and require loading the saved matrix. Disconnect
keeps the editor open with a Reconnect action for its original controller. Switching
controllers closes that editor without sending its draft to another device.

Protocol APIs: `MeshController.readMatrix()` returns a frozen `MatrixDocument`;
decode its `config` as `MatrixConfig`. `updateMatrix(MatrixUpdate(...))` yields
upload progress through the existing MTU-aware begin/chunk/commit transport.
Regenerate bindings using `bash ../proto/generate.sh`. Update all participating
nodes and the app together, since inventory now includes GPIO capability masks.

Run `flutter test` and `dart analyze`; firmware checks are described in
[Distributed matrix protocol](../../firmware/docs/matrix_protocol.md).
