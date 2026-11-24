import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/repositories/layout_repository.dart';
import 'package:lumadrive_control/utils/stringify_mac.dart';

String layoutOutputKey(
  List<int> mac,
  MatrixDriver driver, [
  int sourceIndex = 0,
]) =>
    '${mac.join(':')}/${driver.value}${sourceIndex == 0 ? '' : '/$sourceIndex'}';
String placementKey(MatrixLayout row) =>
    layoutOutputKey(row.nodeMac, row.driver, row.sourceIndex);
String outputKey(LayoutOutput output) =>
    layoutOutputKey(output.nodeMac, output.driver, output.sourceIndex);
bool isPointSource(LayoutOutput? output) =>
    output?.driverKind == MatrixDriverKind.RGB_LED_MODULE;
String outputType(LayoutOutput output) {
  final kind = output.driverKind;
  if (kind == MatrixDriverKind.LED_STRIP) {
    return 'LED strip · driver ${output.driver.value}';
  }
  if (kind == MatrixDriverKind.RGB_LED_MODULE) {
    return 'RGB LED ${output.sourceIndex + 1} · driver ${output.driver.value}';
  }
  return 'Output ${output.driver.value} · source ${output.sourceIndex + 1}';
}

String nodeSuffix(List<int> mac) => mac
    .skip(math.max(0, mac.length - 3))
    .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
    .join(':');
String defaultOutputName(LayoutOutput output, {String? nodeName}) {
  final kind = output.driverKind;
  final point = kind == MatrixDriverKind.RGB_LED_MODULE;
  final strip = kind == MatrixDriverKind.LED_STRIP;
  final type = point
      ? 'LED'
      : strip
      ? 'Strip'
      : 'Output';
  final index =
      '${output.driver.value}${point ? ':${output.sourceIndex + 1}' : ''}';
  final node = nodeName == null || nodeName.trim().isEmpty
      ? nodeSuffix(output.nodeMac)
      : nodeName;
  return '$type ($index) - $node';
}

bool _sameLayout(List<MatrixLayout> a, List<MatrixLayout> b) => listEquals(
  LayoutUpdate(layout: a).writeToBuffer(),
  LayoutUpdate(layout: b).writeToBuffer(),
);
int automaticLayoutCenter(List<MatrixLayout> layout) {
  var extent = 0;
  int? left, right;
  for (final row in layout) {
    final low = math.min(row.from, row.to), high = math.max(row.from, row.to);
    extent = math.max(extent, high);
    if (row.carPosition == CarPosition.DASH_LEFT) {
      left = math.max(left ?? 0, high);
    }
    if (row.carPosition == CarPosition.DASH_RIGHT) {
      right = math.min(right ?? high, low);
    }
  }
  if (left != null && right != null) return (left + right) ~/ 2;
  return left ?? right ?? extent ~/ 2;
}

class LayoutEditorController extends ChangeNotifier {
  final LayoutRepository repository;
  final LayoutDraftStore store;
  LayoutSnapshot? snapshot;
  List<MatrixLayout> layout = [];
  Map<String, String> nodeNames = const {};
  int? centerIndex;
  String? selectedKey, error, notice, fieldError, identifyingKey;
  CarPosition selectedCarPosition = CarPosition.REAR_LEFT_DOOR;
  String? lengthError;
  bool loading = true, connected = false, applying = false, conflict = false;
  double? progress;
  MatrixStatus? deploymentStatus;
  bool _disposed = false, _refreshing = false;
  Timer? _poll, _persistTimer;
  Completer<void>? _refreshDone;
  Future<void> _writes = Future<void>.value();
  final Duration pollInterval;

  LayoutEditorController({
    required this.repository,
    required this.store,
    this.pollInterval = const Duration(seconds: 3),
  });

  bool get dirty =>
      snapshot != null &&
      (!_sameLayout(layout, snapshot!.layout) ||
          centerIndex !=
              (snapshot!.hasCenterIndex() ? snapshot!.centerIndex : null));
  int get resolvedCenter => centerIndex ?? automaticLayoutCenter(layout);
  void setCenter(int? value) {
    centerIndex = value;
    _edited();
  }

  bool get busy => applying || identifyingKey != null;
  bool get refreshing => _refreshing;
  void connectionChanged(bool available) {
    if (_disposed) return;
    if (available) {
      unawaited(refresh());
      return;
    }
    connected = false;
    if (snapshot != null) {
      final offline = LayoutSnapshot.fromBuffer(snapshot!.writeToBuffer());
      for (final output in offline.outputs) {
        output.online = false;
      }
      snapshot = offline..freeze();
    }
    _changed();
  }

  int get canvasSize => layout.fold(
    0,
    (extent, row) => math.max(extent, math.max(row.from, row.to)),
  );
  MatrixLayout? get selected {
    for (final row in layout) {
      if (placementKey(row) == selectedKey) return row;
    }
    return null;
  }

  LayoutOutput? outputFor(String key) {
    for (final output in snapshot?.outputs ?? <LayoutOutput>[]) {
      if (outputKey(output) == key) return output;
    }
    return null;
  }

  String outputTitle(LayoutOutput output) => defaultOutputName(
    output,
    nodeName: nodeNames[macBytesToString(output.nodeMac)],
  );
  String displayOutputTitle(LayoutOutput output) {
    final row = layout
        .where((row) => placementKey(row) == outputKey(output))
        .firstOrNull;
    return row == null ? outputTitle(output) : titleFor(row);
  }

  String titleFor(MatrixLayout row) => row.name.isNotEmpty
      ? row.name
      : outputTitle(
          outputFor(placementKey(row)) ??
              LayoutOutput(
                nodeMac: row.nodeMac,
                driver: row.driver,
                sourceIndex: row.sourceIndex,
              ),
        );
  int lengthFor(MatrixLayout row) {
    return (row.to - row.from).abs();
  }

  int maximumFor(LayoutOutput output) =>
      output.maxPixelCount > 0 ? output.maxPixelCount : output.pixelCount;

  String? get validationError {
    if (fieldError != null) return fieldError;
    if (lengthError != null) return lengthError;
    if (centerIndex != null &&
        (centerIndex! < 0 || centerIndex! > canvasSize)) {
      return 'Center must be within the shared layout.';
    }
    if (layout.length > 84) {
      return 'A layout can contain up to 84 light sources.';
    }
    final seen = <String>{};
    for (final row in layout) {
      if (row.driver.value < 1 ||
          row.driver.value > 6 ||
          row.sourceIndex < 0 ||
          row.sourceIndex >= 12) {
        return 'Unknown driver slot or light source.';
      }
      if (!seen.add(placementKey(row))) {
        return 'Each output can only be placed once.';
      }
      if (row.from == row.to ||
          row.from > 65536 ||
          row.to > 65536 ||
          row.from < 0 ||
          row.to < 0) {
        return 'Positions must fit between 0 and 65,536.';
      }
      final output = outputFor(placementKey(row));
      if (output != null &&
          output.known &&
          lengthFor(row) > maximumFor(output)) {
        return '${titleFor(row)} exceeds the device limit of ${maximumFor(output)} LEDs.';
      }
      if (utf8.encode(row.name).length > 128) return 'Output name is too long.';
    }
    return null;
  }

  bool get canApply =>
      connected && dirty && !busy && !conflict && validationError == null;

  MatrixNodeStatus_State? deploymentFor(List<int> mac) {
    final status = deploymentStatus;
    if (!connected ||
        status == null ||
        snapshot == null ||
        status.revision != snapshot!.revision ||
        status.masterSession != snapshot!.masterSession) {
      return null;
    }
    for (final node in status.nodes) {
      if (listEquals(node.nodeMac, mac)) return node.state;
    }
    return null;
  }

  String? get deploymentNotice {
    final pending = <String>{}, degraded = <String>{};
    for (final row in snapshot?.layout ?? <MatrixLayout>[]) {
      final state = deploymentFor(row.nodeMac);
      if (state == null || state == MatrixNodeStatus_State.READY) continue;
      (state == MatrixNodeStatus_State.DEGRADED ? degraded : pending).add(
        row.nodeMac.join(':'),
      );
    }
    if (degraded.isNotEmpty) {
      return '${degraded.length} ${degraded.length == 1 ? 'node reports' : 'nodes report'} degraded delivery. Check the affected devices.';
    }
    if (pending.isNotEmpty) {
      return 'Saved layout is waiting to sync with ${pending.length} ${pending.length == 1 ? 'node' : 'nodes'}. Available nodes continue playing.';
    }
    return null;
  }

  Future<void> initialize() async {
    try {
      final saved = await store.read();
      if (_disposed) return;
      if (saved != null) {
        snapshot = saved.snapshot;
        layout = saved.layout;
        centerIndex = saved.centerIndex;
        loading = false;
        connectionChanged(false);
      }
    } catch (_) {
      notice = 'Could not read the local draft.';
    }
    await refresh();
    if (!_disposed && pollInterval > Duration.zero) {
      _poll = Timer.periodic(pollInterval, (_) => unawaited(refresh()));
    }
  }

  Future<void> refresh({bool discardDraft = false}) async {
    if (_disposed || _refreshing || busy) return;
    _refreshing = true;
    final done = _refreshDone = Completer<void>();
    _changed();
    try {
      final response = await repository.read();
      final status = await repository.readStatus();
      if (_disposed) return;
      deploymentStatus = status;
      var fresh = response.snapshot;
      final previous = snapshot;
      // Offline inventory keeps the last actual device-reported lengths.
      if (previous != null) {
        fresh = LayoutSnapshot.fromBuffer(fresh.writeToBuffer());
        for (var i = 0; i < fresh.outputs.length; i++) {
          final output = fresh.outputs[i];
          if (output.online || output.known) continue;
          for (final old in previous.outputs) {
            if (outputKey(old) == outputKey(output) && old.known) {
              fresh.outputs[i] = LayoutOutput.fromBuffer(old.writeToBuffer())
                ..online = false;
              break;
            }
          }
        }
        for (final old in previous.outputs) {
          if (fresh.outputs.length < 204 &&
              !fresh.outputs.any(
                (output) => outputKey(old) == outputKey(output),
              )) {
            fresh.outputs.add(
              LayoutOutput.fromBuffer(old.writeToBuffer())..online = false,
            );
          }
        }
        fresh.freeze();
      }
      final hadDraft = dirty;
      if (discardDraft ||
          previous == null ||
          !hadDraft ||
          (_sameLayout(layout, fresh.layout) &&
              centerIndex ==
                  (fresh.hasCenterIndex() ? fresh.centerIndex : null))) {
        snapshot = fresh;
        layout = fresh.layout
            .map((row) => MatrixLayout.fromBuffer(row.writeToBuffer()))
            .toList();
        centerIndex = fresh.hasCenterIndex() ? fresh.centerIndex : null;
        conflict = false;
        fieldError = null;
        lengthError = null;
      } else if (previous.revision == fresh.revision &&
          listEquals(previous.masterMac, fresh.masterMac) &&
          _sameLayout(previous.layout, fresh.layout) &&
          (previous.hasCenterIndex() ? previous.centerIndex : null) ==
              (fresh.hasCenterIndex() ? fresh.centerIndex : null)) {
        snapshot = fresh;
        conflict = false;
      } else {
        conflict = true; // Keep the draft's original revision for optimistic concurrency.
        final retained = LayoutSnapshot.fromBuffer(previous.writeToBuffer());
        retained.outputs
          ..clear()
          ..addAll(fresh.outputs);
        snapshot = retained..freeze();
      }
      connected = true;
      error = null;
      if (selectedKey != null && selected == null) selectedKey = null;
      _persist();
    } catch (e) {
      if (_disposed) return;
      connected = false;
      error = _message(e);
      connectionChanged(false);
    } finally {
      _refreshing = false;
      _refreshDone = null;
      done.complete();
      if (!_disposed) {
        loading = false;
        _changed();
      }
    }
  }

  void select(String key) {
    selectedKey = key;
    fieldError = null;
    lengthError = null;
    _changed();
  }

  void selectCarPosition(CarPosition position) {
    if (busy) return;
    selectedCarPosition = position;
    _changed();
  }

  void place(LayoutOutput output, {String? afterKey}) {
    if (busy ||
        !output.known ||
        !output.ready ||
        output.pixelCount <= 0 ||
        output.pixelCount > 65536) {
      return;
    }
    final key = outputKey(output);
    if (layout.any((row) => placementKey(row) == key)) {
      select(key);
      return;
    }
    var start = canvasSize;
    for (final row in layout) {
      if (placementKey(row) == afterKey) start = math.max(row.from, row.to);
    }
    if (start + output.pixelCount > 65536) start = 0;
    layout = [
      ...layout,
      MatrixLayout(
        nodeMac: output.nodeMac,
        driver: output.driver,
        sourceIndex: output.sourceIndex,
        from: start,
        to: start + output.pixelCount,
      ),
    ];
    selectedKey = key;
    fieldError = null;
    _edited();
  }

  void remove(String key, {bool continuous = false}) {
    if (busy) return;
    layout = layout.where((row) => placementKey(row) != key).toList();
    if (selectedKey == key) {
      selectedKey = null;
      fieldError = null;
    }
    _edited();
    if (continuous) arrangeCar();
  }

  void rename(String key, String name) =>
      _replace(key, (row) => row..name = name);
  void resize(String key, String text, {bool continuous = false}) {
    final row = layout.where((row) => placementKey(row) == key).firstOrNull;
    final output = outputFor(key);
    final count = int.tryParse(text);
    final maximum = output == null ? 0 : maximumFor(output);
    if (row == null ||
        count == null ||
        count < 1 ||
        count > maximum ||
        math.min(row.from, row.to) + count > 65536 ||
        (isPointSource(output) && count != 1)) {
      lengthError = 'Enter an LED count between 1 and $maximum.';
      _changed();
      return;
    }
    lengthError = null;
    final start = math.min(row.from, row.to), reversed = row.from > row.to;
    _replace(key, (copy) {
      copy.from = reversed ? start + count : start;
      copy.to = reversed ? start : start + count;
      return copy;
    });
    if (continuous) arrangeCar();
  }

  void assignPosition(String key, CarPosition position) {
    _replace(key, (row) => row..carPosition = position);
    arrangeCar();
  }

  void arrangeCar() {
    if (busy) return;
    final assigned = layout
        .where((row) => row.carPosition != CarPosition.POSITION_UNSPECIFIED)
        .toList();
    final originalOrder = {
      for (var i = 0; i < layout.length; i++) placementKey(layout[i]): i,
    };
    assigned.sort((a, b) {
      final location = a.carPosition.value.compareTo(b.carPosition.value);
      return location != 0
          ? location
          : originalOrder[placementKey(a)]!.compareTo(
              originalOrder[placementKey(b)]!,
            );
    });
    if (assigned.fold<int>(0, (sum, row) => sum + lengthFor(row)) > 65536) {
      fieldError = 'The continuous layout exceeds 65,536 pixels.';
      _changed();
      return;
    }
    var start = 0;
    final replacements = <String, MatrixLayout>{};
    for (final row in assigned) {
      final length = lengthFor(row), reversed = row.from > row.to;
      replacements[placementKey(
        row,
      )] = MatrixLayout.fromBuffer(row.writeToBuffer())
        ..from = reversed ? start + length : start
        ..to = reversed ? start : start + length;
      start += length;
    }
    layout = layout
        .map((row) => replacements[placementKey(row)] ?? row)
        .toList();
    _edited();
  }

  void reverse(String key) => _replace(key, (row) {
    final from = row.from;
    row.from = row.to;
    row.to = from;
    return row;
  });
  void move(String key, int position, {double snapDistance = 0}) {
    for (final row in layout) {
      if (placementKey(row) != key) continue;
      final length = lengthFor(row);
      if (length <= 0 || length > 65536) {
        fieldError = 'Unsupported output length.';
        _changed();
        return;
      }
      fieldError = null;
      var start = position.clamp(0, 65536 - length);
      if (snapDistance > 0) {
        var distance = double.infinity;
        for (final other in layout) {
          if (placementKey(other) == key) continue;
          for (final edge in [other.from, other.to]) {
            for (final candidate in [edge, edge - length]) {
              final delta = (candidate - position).abs().toDouble();
              if (candidate >= 0 &&
                  candidate + length <= 65536 &&
                  delta <= snapDistance &&
                  delta < distance) {
                start = candidate;
                distance = delta;
              }
            }
          }
        }
      }
      _replace(key, (copy) {
        copy.carPosition = CarPosition.POSITION_UNSPECIFIED;
        copy.from = row.from < row.to ? start : start + length;
        copy.to = row.from < row.to ? start + length : start;
        return copy;
      });
      return;
    }
  }

  void positionText(String key, String text) {
    final position = int.tryParse(text);
    final row = layout.where((row) => placementKey(row) == key).firstOrNull;
    if (position == null ||
        row == null ||
        position < 0 ||
        position + lengthFor(row) > 65536) {
      fieldError =
          'Enter a position between 0 and ${row == null ? 65535 : 65536 - lengthFor(row)}.';
      _changed();
      return;
    }
    fieldError = null;
    move(key, position);
  }

  void _replace(String key, MatrixLayout Function(MatrixLayout) change) {
    if (busy) return;
    layout = layout
        .map(
          (row) => placementKey(row) == key
              ? change(MatrixLayout.fromBuffer(row.writeToBuffer()))
              : row,
        )
        .toList();
    _edited();
  }

  void _edited() {
    notice = null;
    _persist();
    _changed();
  }

  Future<void> identify(String key) async {
    if (busy || !connected || lengthError != null) return;
    identifyingKey = key;
    error = null;
    _changed();
    try {
      await _refreshDone?.future;
      if (_disposed || !connected) return;
      final current = await repository.read();
      final index = current.snapshot.outputs.indexWhere(
        (output) => outputKey(output) == key,
      );
      if (index < 0 ||
          !current.snapshot.outputs[index].online ||
          !current.snapshot.outputs[index].ready) {
        throw StateError('Output is offline or unavailable.');
      }
      final row = layout.where((row) => placementKey(row) == key).firstOrNull;
      await repository.identify(
        current.snapshotId,
        index,
        pixelCount: row == null ? 0 : lengthFor(row),
        reversed: row != null && row.from > row.to,
      );
      notice = isPointSource(current.snapshot.outputs[index])
          ? 'The selected LED pulses green. Normal lighting resumes automatically.'
          : 'The strip fills green using your draft length and direction, then holds fully lit for one second. Blue marks the end.';
    } catch (e) {
      error = _message(e);
    } finally {
      identifyingKey = null;
      _changed();
    }
  }

  Future<void> apply() async {
    if (!canApply || snapshot == null) return;
    applying = true;
    progress = 0;
    error = null;
    notice = null;
    _changed();
    try {
      await _refreshDone?.future;
      if (_disposed) return;
      if (!connected ||
          conflict ||
          validationError != null ||
          snapshot == null) {
        throw StateError(
          validationError ?? 'Refresh the controller before applying.',
        );
      }
      final update = LayoutUpdate(
        masterSession: snapshot!.masterSession,
        expectedRevision: snapshot!.revision,
        layout: layout,
        centerIndex: centerIndex,
      );
      await for (final value in repository.apply(update)) {
        if (_disposed) return;
        progress = value.totalBytes == 0
            ? 1
            : value.transferredBytes / value.totalBytes;
        deploymentStatus = value.status;
        _changed();
      }
      final current = await repository.read();
      if (_disposed) return;
      snapshot = current.snapshot;
      layout = snapshot!.layout
          .map((row) => MatrixLayout.fromBuffer(row.writeToBuffer()))
          .toList();
      centerIndex = snapshot!.hasCenterIndex() ? snapshot!.centerIndex : null;
      conflict = false;
      notice = 'Layout saved to controller.';
      _persist();
    } catch (e) {
      error = _message(e);
      if (error!.contains('changed on controller')) conflict = true;
    } finally {
      applying = false;
      progress = null;
      _changed();
    }
  }

  static String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Bad state: |MatrixUploadException: )'),
    '',
  );
  void _changed() {
    if (!_disposed) notifyListeners();
  }

  void _persist() {
    _persistTimer?.cancel();
    _persistTimer = Timer(
      const Duration(milliseconds: 200),
      () => unawaited(flush()),
    );
  }

  Future<void> flush() {
    _persistTimer?.cancel();
    if (snapshot == null) return _writes;
    final saved = SavedLayoutDraft(
      LayoutSnapshot.fromBuffer(snapshot!.writeToBuffer()),
      layout
          .map((row) => MatrixLayout.fromBuffer(row.writeToBuffer()))
          .toList(),
      centerIndex,
    );
    _writes = _writes.then((_) => store.save(saved)).catchError((Object _) {
      notice = 'Local draft could not be saved. Keep this screen open.';
      _changed();
    });
    return _writes;
  }

  @override
  void dispose() {
    _poll?.cancel();
    _persistTimer?.cancel();
    unawaited(flush());
    _disposed = true;
    super.dispose();
  }
}
