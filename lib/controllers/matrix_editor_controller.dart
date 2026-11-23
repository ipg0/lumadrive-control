import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:lumadrive_control/generated/mesh.pb.dart';
import 'package:lumadrive_control/repositories/matrix_editor_repository.dart';
import 'package:lumadrive_control/utils/gradient_palette.dart';

const neverConditionValue = -4294967296;
const simpleEffectKinds = [
  MatrixEffect_Kind.STATIC_COLOR,
  MatrixEffect_Kind.DIMMING,
  MatrixEffect_Kind.BLINK,
  MatrixEffect_Kind.BREATHE,
  MatrixEffect_Kind.FLOWING_GRADIENT,
  MatrixEffect_Kind.RAINBOW,
  MatrixEffect_Kind.FILL,
  MatrixEffect_Kind.KEYFRAMES,
];
String effectKindLabel(MatrixEffect_Kind kind) => switch (kind) {
  MatrixEffect_Kind.STATIC_COLOR => 'Static color',
  MatrixEffect_Kind.DIMMING => 'Dimming',
  MatrixEffect_Kind.BLINK => 'Blink',
  MatrixEffect_Kind.BREATHE => 'Breathe',
  MatrixEffect_Kind.FLOWING_GRADIENT => 'Flowing gradient',
  MatrixEffect_Kind.RAINBOW => 'Rainbow',
  MatrixEffect_Kind.FILL => 'Fill',
  MatrixEffect_Kind.KEYFRAMES => 'Keyframes',
  _ => 'Unsupported animation',
};
String animationTitle(MatrixEffect effect) => effect.name.isEmpty
    ? '${effectKindLabel(effect.kind)} ${effect.id}'
    : effect.name;
MatrixEffect newSimpleAnimation() => MatrixEffect(
  kind: MatrixEffect_Kind.STATIC_COLOR,
  red: 255,
  alpha: 255,
  periodMs: 1000,
);
String entryTitle(MatrixEntry entry) =>
    entry.name.isEmpty ? 'Entry ${entry.id}' : entry.name;
String uniqueSuggestedName(String base, Iterable<String> existing) {
  final used = existing.map((name) => name.trim().toLowerCase()).toSet();
  String candidate(int index) {
    final suffix = index == 1 ? '' : ' $index';
    return '${String.fromCharCodes(base.runes.take(32 - suffix.length)).trimRight()}$suffix';
  }

  var index = 1;
  while (used.contains(candidate(index).toLowerCase())) {
    index++;
  }
  return candidate(index);
}

MatrixUpdate matrixPatch(MatrixConfig config) => MatrixUpdate(
  effects: config.effects,
  sources: config.sources,
  conditions: config.conditions,
  entries: config.entries,
  modes: config.modes,
  activeModeId: config.activeModeId,
);
bool sameMatrix(MatrixConfig a, MatrixConfig b) =>
    listEquals(matrixPatch(a).writeToBuffer(), matrixPatch(b).writeToBuffer());
bool sameMatrixEntries(MatrixConfig a, MatrixConfig b) {
  MatrixUpdate entries(MatrixConfig config) => matrixPatch(config)
    ..modes.clear()
    ..activeModeId = 0;
  return listEquals(entries(a).writeToBuffer(), entries(b).writeToBuffer());
}

class MatrixEditorController extends ChangeNotifier {
  final MatrixEditorRepository repository;
  final MatrixDraftStore store;
  final Duration pollInterval;
  MatrixDocument? document;
  MatrixDocument? currentDocument;
  bool readingCurrent = false;
  MatrixConfig config = MatrixConfig(schemaVersion: 0);
  MatrixStatus? deployment;
  bool loading = true,
      connected = false,
      refreshing = false,
      applying = false,
      conflict = false,
      editing = false;
  String? error, notice;
  double? progress;
  bool _disposed = false;
  Timer? _poll, _persistTimer;
  Completer<void>? _refreshDone;
  Future<void> _writes = Future.value();
  MatrixEditorController({
    required this.repository,
    required this.store,
    this.pollInterval = const Duration(seconds: 3),
  });
  MatrixConfig get saved => document == null
      ? MatrixConfig(schemaVersion: 0)
      : MatrixConfig.fromBuffer(document!.config);
  bool get dirty => document != null && !sameMatrix(config, saved);
  bool get canApply =>
      connected &&
      dirty &&
      !refreshing &&
      !readingCurrent &&
      !applying &&
      !editing &&
      !conflict &&
      validationError == null;
  int get canvasSize => config.layout.fold(
    0,
    (value, row) => math.max(value, math.max(row.from, row.to)),
  );
  MatrixEffect? effect(int id) =>
      config.effects.where((item) => item.id == id).firstOrNull;
  MatrixSource? source(int id) =>
      config.sources.where((item) => item.id == id).firstOrNull;
  String? get validationError => _validationError(config);
  String? _validationError(MatrixConfig config) {
    if (config.schemaVersion != 0) return 'Unsupported configuration format.';
    if ([
      config.effects.length,
      config.sources.length,
      config.conditions.length,
      config.entries.length,
      config.modes.length,
    ].any((n) => n > 32)) {
      return 'Up to 32 entries and 32 definitions per type are supported.';
    }
    for (final ids in [
      config.effects.map((e) => e.id),
      config.sources.map((e) => e.id),
      config.conditions.map((e) => e.id),
      config.entries.map((e) => e.id),
      config.modes.map((e) => e.id),
    ]) {
      if (ids.any((id) => id <= 0 || id > 0xffffffff) ||
          ids.toSet().length != ids.length) {
        return 'Definition IDs must be unique and nonzero.';
      }
    }
    if (config.entries.isNotEmpty && config.layout.isEmpty) {
      return 'Configure the car layout before adding playback entries.';
    }
    for (final e in config.effects) {
      if (utf8.encode(e.name).length > 128) {
        return 'Animation name is too long.';
      }
      if (!simpleEffectKinds.contains(e.kind) &&
          e.kind != MatrixEffect_Kind.KEYFRAMES) {
        return 'Unsupported animation type.';
      }
      if ([e.red, e.green, e.blue, e.alpha].any((v) => v < 0 || v > 255)) {
        return 'Colors must be between 0 and 255.';
      }
      if (e.kind == MatrixEffect_Kind.DIMMING &&
          (e.red != 0 || e.green != 0 || e.blue != 0)) {
        return 'Dimming color must be black.';
      }
      if ([
        e.durationMs,
        e.periodMs,
        e.wavelengthPixels,
      ].any((v) => v < 0 || v > 0xffffffff)) {
        return 'Animation timing and wavelength are out of range.';
      }
      if (e.hasSecondaryColor() &&
          [
            e.secondaryColor.red,
            e.secondaryColor.green,
            e.secondaryColor.blue,
            e.secondaryColor.alpha,
          ].any((v) => v < 0 || v > 255)) {
        return 'Colors must be between 0 and 255.';
      }
      if (e.gradientColors.length > maxGradientColors ||
          e.gradientColors.any(
            (color) => [
              color.red,
              color.green,
              color.blue,
              color.alpha,
            ].any((value) => value < 0 || value > 255),
          )) {
        return 'Gradients support up to $maxGradientColors RGBA colors, with channels between 0 and 255.';
      }
      if (e.gradientColors.isNotEmpty &&
          e.kind != MatrixEffect_Kind.FLOWING_GRADIENT) {
        return 'Gradient colors require a flowing gradient.';
      }
      if (e.periodMs == 1) return 'Animation periods must be at least 2 ms.';
      if (e.kind == MatrixEffect_Kind.FILL && !e.loop && e.durationMs < 2) {
        return 'A one-shot fill needs a duration of at least 2 ms.';
      }
      if (e.kind == MatrixEffect_Kind.BLINK &&
          (e.dutyPercent < 0 || e.dutyPercent > 100)) {
        return 'Blink duty must be between 1 and 100%.';
      }
      if (e.kind == MatrixEffect_Kind.FLOWING_GRADIENT &&
          (e.gradientColors.length == 1 ||
              (e.gradientColors.isEmpty && !e.hasSecondaryColor()))) {
        return 'A gradient needs 2–$maxGradientColors colors.';
      }
    }
    for (final entry in config.entries) {
      if (!config.effects.any((effect) => effect.id == entry.effectId) ||
          !config.sources.any((source) => source.id == entry.sourceId) ||
          !config.conditions.any((c) => c.id == entry.conditionId)) {
        return 'An entry has an invalid animation, trigger or condition.';
      }
      if (entry.priority < 0 || entry.priority > 255) {
        return 'Priorities must be between 0 and 255.';
      }
      if (utf8.encode(entry.name).length > 128) {
        return 'Entry name is too long.';
      }
      if (entry.opaqueBackground &&
          config.sources.any(
            (source) =>
                source.id == entry.sourceId &&
                source.kind == MatrixSource_Kind.DEFAULT_STATE,
          )) {
        return 'Default-state entries require a transparent background.';
      }
    }
    for (final s in config.sources) {
      if (s.kind == MatrixSource_Kind.DEFAULT_STATE ||
          s.kind == MatrixSource_Kind.ON_BOOT ||
          s.kind == MatrixSource_Kind.ON_MODE_SWITCHED) {
        continue;
      }
      if (s.kind != MatrixSource_Kind.GPIO_EDGE ||
          s.nodeMac.length != 6 ||
          s.nodeMac.every((v) => v == 0) ||
          (s.nodeMac.first & 1) != 0 ||
          s.gpio < 0 ||
          s.gpio > 39) {
        return 'Invalid GPIO trigger.';
      }
      final node = document?.nodes
          .where((n) => listEquals(n.nodeMac, s.nodeMac))
          .firstOrNull;
      if (node?.known == true && !node!.gpios.contains(s.gpio)) {
        return 'GPIO ${s.gpio} is not provisioned on its node.';
      }
    }
    if (config.activeModeId != 0 &&
        !config.modes.any((m) => m.id == config.activeModeId)) {
      return 'Invalid active mode.';
    }
    if (config.modes.any(
      (m) => m.name.trim().isEmpty || utf8.encode(m.name).length > 128,
    )) {
      return 'Mode names must be 1–128 bytes.';
    }
    final conditions = {for (final c in config.conditions) c.id: c};
    final visiting = <int>{}, visited = <int>{};
    bool validGpioCondition(MatrixCondition c) {
      if (c.nodeMac.length != 6 ||
          c.nodeMac.every((b) => b == 0) ||
          (c.nodeMac.first & 1) != 0 ||
          c.gpio > 39) {
        return false;
      }
      final node = document?.nodes
          .where((n) => listEquals(n.nodeMac, c.nodeMac))
          .firstOrNull;
      return node == null || !node.known || node.gpios.contains(c.gpio);
    }

    bool validCondition(int id) {
      final c = conditions[id];
      if (c == null || visiting.contains(id)) return false;
      if (visited.contains(id)) return true;
      visiting.add(id);
      final valid =
          c.kind == MatrixCondition_Kind.ALWAYS ||
          c.kind == MatrixCondition_Kind.NEVER ||
          (c.kind == MatrixCondition_Kind.GPIO_STATE &&
              validGpioCondition(c)) ||
          (c.kind == MatrixCondition_Kind.MODE &&
              config.modes.any((m) => m.id == c.modeId)) ||
          ((c.kind == MatrixCondition_Kind.AND ||
                  c.kind == MatrixCondition_Kind.OR) &&
              validCondition(c.leftId) &&
              validCondition(c.rightId));
      visiting.remove(id);
      if (valid) visited.add(id);
      return valid;
    }

    if (conditions.length != config.conditions.length ||
        conditions.keys.any((id) => !validCondition(id))) {
      return 'Invalid or cyclic condition.';
    }
    if (config.writeToBuffer().length > 16384 ||
        matrixPatch(config).writeToBuffer().length + 24 > 16384) {
      return 'Configuration exceeds 16 KiB.';
    }
    return null;
  }

  Future<void> initialize() async {
    try {
      final draft = await store.read();
      if (_disposed) return;
      if (draft != null) {
        document = draft.document;
        config = draft.config;
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

  void connectionChanged(bool available) {
    if (_disposed) return;
    connected = available;
    if (available) {
      unawaited(refresh());
    } else {
      if (document != null) {
        final offline = document!.deepCopy();
        for (final node in offline.nodes) {
          node.online = false;
        }
        document = offline..freeze();
      }
      _changed();
    }
  }

  Future<void> refresh({bool discardDraft = false}) async {
    if (_disposed || refreshing || applying || editing || readingCurrent) {
      return;
    }
    refreshing = true;
    final done = _refreshDone = Completer<void>();
    _changed();
    try {
      var fresh = await repository.read();
      final status = await repository.status();
      if (_disposed) return;
      if (fresh.config.isEmpty ||
          MatrixConfig.fromBuffer(fresh.config).schemaVersion != 0) {
        throw StateError('Unsupported configuration format');
      }
      final previous = document,
          incoming = MatrixConfig.fromBuffer(fresh.config);
      if (previous != null) {
        final cached = fresh.deepCopy();
        for (var i = 0; i < cached.nodes.length; i++) {
          final node = cached.nodes[i];
          final old = previous.nodes
              .where((n) => listEquals(n.nodeMac, node.nodeMac) && n.known)
              .firstOrNull;
          if (!node.known && !node.online && old != null) {
            cached.nodes[i] = old.deepCopy()..online = false;
          }
        }
        fresh = cached..freeze();
      }
      if (previous == null ||
          discardDraft ||
          !dirty ||
          sameMatrix(config, incoming)) {
        document = fresh;
        config = incoming;
        conflict = false;
      } else if (listEquals(previous.masterMac, fresh.masterMac) &&
          sameMatrixEntries(saved, incoming)) {
        document = fresh;
        config.layout
          ..clear()
          ..addAll(incoming.layout);
        if (incoming.hasCenterIndex()) {
          config.centerIndex = incoming.centerIndex;
        } else {
          config.clearCenterIndex();
        }
        config.modes
          ..clear()
          ..addAll(incoming.modes.map((mode) => mode.deepCopy()));
        config.activeModeId = incoming.activeModeId;
        conflict = false;
      } else {
        conflict = true;
        document = previous.deepCopy()
          ..nodes.clear()
          ..nodes.addAll(fresh.nodes)
          ..freeze();
      }
      deployment = status;
      if (currentDocument?.revision != fresh.activeRevision) {
        currentDocument = null;
      }
      connected = true;
      error = null;
      _persist();
    } catch (e) {
      if (!_disposed) {
        connectionChanged(false);
        error = _message(e);
      }
    } finally {
      refreshing = false;
      _refreshDone = null;
      done.complete();
      loading = false;
      _changed();
    }
  }

  int _id(Iterable<int> used) {
    final ids = used.toSet();
    var id = 1;
    while (ids.contains(id)) {
      id++;
    }
    return id;
  }

  bool saveEffect(MatrixEffect value) {
    if (_disposed || applying) return false;
    final existing = effect(value.id);
    if (existing == null && config.effects.length >= 32) {
      error = 'The animation library is full.';
      _changed();
      return false;
    }
    final next = value.deepCopy();
    if (next.id == 0) next.id = nextEffectId;
    final index = config.effects.indexWhere((e) => e.id == next.id);
    if (index < 0) {
      config.effects.add(next);
    } else {
      config.effects[index] = next;
    }
    editing = false;
    _edited();
    return true;
  }

  int get nextEffectId => _id([
    ...config.effects.map((effect) => effect.id),
    ...saved.effects.map((effect) => effect.id),
  ]);

  Future<int?> previewEffect(MatrixEffect value) async {
    final id = value.id == 0 ? nextEffectId : value.id;
    final next = value.deepCopy()..id = id;
    if (!await applyEffect(next)) return null;
    value.id = id;
    try {
      await repository.preview(id);
      return id;
    } catch (exception) {
      error = _message(exception);
      _changed();
      return null;
    }
  }

  Future<bool> applyEffect(MatrixEffect value) async {
    if (_disposed || applying || readingCurrent) return false;
    applying = true;
    error = notice = null;
    progress = 0;
    _changed();
    try {
      await _refreshDone?.future;
      if (_disposed) return false;
      if (!connected || document == null) {
        throw StateError('Connect to the controller to apply this animation.');
      }
      if (conflict) {
        throw StateError(
          'Configuration changed on controller; reload before applying',
        );
      }
      final next = value.deepCopy();
      if (next.id == 0) next.id = nextEffectId;
      if (effect(next.id) == null && config.effects.length >= 32) {
        throw StateError('The animation library is full.');
      }
      final submitted = saved;
      final index = submitted.effects.indexWhere(
        (effect) => effect.id == next.id,
      );
      if (index < 0) {
        submitted.effects.add(next);
      } else {
        submitted.effects[index] = next;
      }
      final invalid = _validationError(submitted);
      if (invalid != null) throw StateError(invalid);
      final draft = config.deepCopy();
      final update = matrixPatch(submitted)
        ..expectedRevision = document!.revision
        ..masterSession = document!.masterSession;
      await for (final value in repository.apply(update)) {
        if (_disposed) return false;
        deployment = value.status;
        progress = value.transferredBytes / math.max(1, value.totalBytes);
        _changed();
      }
      final fresh = await repository.read();
      if (_disposed) return false;
      final incoming = MatrixConfig.fromBuffer(fresh.config);
      final applied = incoming.effects
          .where((effect) => effect.id == next.id)
          .firstOrNull;
      if (applied == null) {
        throw StateError(
          'The controller did not return the applied animation.',
        );
      }
      // Keep unrelated table/library drafts local; only this animation was sent.
      final draftIndex = draft.effects.indexWhere(
        (effect) => effect.id == next.id,
      );
      if (draftIndex < 0) {
        draft.effects.add(applied.deepCopy());
      } else {
        draft.effects[draftIndex] = applied.deepCopy();
      }
      draft.layout
        ..clear()
        ..addAll(incoming.layout);
      draft.factoryDefault = incoming.factoryDefault;
      document = fresh;
      config = draft;
      currentDocument = null;
      conflict = false;
      notice = 'Animation applied to controller.';
      _persist();
      return true;
    } catch (exception) {
      error = _message(exception);
      if (error!.contains('changed on controller')) conflict = true;
      return false;
    } finally {
      applying = false;
      progress = null;
      _changed();
    }
  }

  void deleteEffect(int id) {
    if (applying || _disposed) return;
    if (config.entries.any((entry) => entry.effectId == id)) {
      error = 'This animation is used by the table. Change or remove its entries first.';
      _changed();
      return;
    }
    config.effects.removeWhere((e) => e.id == id);
    _edited();
  }

  void duplicateEffect(int id) {
    final original = effect(id);
    if (original == null) return;
    final title = String.fromCharCodes(animationTitle(original).runes.take(26));
    final copy = original.deepCopy()
      ..id = 0
      ..name = '$title copy';
    saveEffect(copy);
  }

  bool saveEntry(
    MatrixEntry value,
    MatrixSource trigger, {
    List<MatrixEffect> newEffects = const [],
    int modeId = 0,
    int secondModeId = 0,
    int conditionOperator = 0,
    List<int>? conditionValues,
    List<MatrixCondition>? conditionSelections,
  }) {
    if (_disposed || applying) return false;
    if (value.id == 0 && config.entries.length >= 32) {
      error = 'The table is full.';
      _changed();
      return false;
    }
    final next = value.deepCopy(), input = trigger.deepCopy();
    if (next.id == 0) next.id = _id(config.entries.map((e) => e.id));
    final original = config.entries
        .where((entry) => entry.id == next.id)
        .firstOrNull;
    final oldSource = original?.sourceId;
    final shared = config.entries.any(
      (entry) => entry.id != next.id && entry.sourceId == input.id,
    );
    if (input.id == 0 || shared) {
      input.id = _id(config.sources.map((s) => s.id));
    }
    final sourceIndex = config.sources.indexWhere((s) => s.id == input.id);
    if (sourceIndex < 0 && config.sources.length >= 32) {
      error = 'Too many trigger definitions.';
      _changed();
      return false;
    }
    final stagedConditions = config.conditions
        .map((c) => c.deepCopy())
        .toList();
    MatrixCondition fromValue(int id) => MatrixCondition(
      kind: id == neverConditionValue
          ? MatrixCondition_Kind.NEVER
          : id == 0
          ? MatrixCondition_Kind.ALWAYS
          : MatrixCondition_Kind.MODE,
      modeId: id == neverConditionValue ? 0 : id.abs(),
      inverted: id != neverConditionValue && id < 0,
    );
    final values =
        conditionSelections ??
        (conditionValues ?? [modeId, if (conditionOperator != 0) secondModeId])
            .map(fromValue)
            .toList();
    if (values.isEmpty || (conditionOperator != 0 && values.length < 2)) {
      error = 'A combined condition needs at least two conditions.';
      _changed();
      return false;
    }
    MatrixCondition? leaf(MatrixCondition value) => stagedConditions
        .where(
          (c) =>
              c.kind == value.kind &&
              (value.kind == MatrixCondition_Kind.MODE
                  ? c.modeId == value.modeId && c.inverted == value.inverted
                  : value.kind == MatrixCondition_Kind.GPIO_STATE
                  ? listEquals(c.nodeMac, value.nodeMac) &&
                        c.gpio == value.gpio &&
                        c.high == value.high
                  : true),
        )
        .firstOrNull;
    final groupKind = conditionOperator == 1
        ? MatrixCondition_Kind.AND
        : MatrixCondition_Kind.OR;
    MatrixCondition ensureLeaf(MatrixCondition value) {
      final existing = leaf(value);
      if (existing != null) return existing;
      final created = value.deepCopy()
        ..id = _id(stagedConditions.map((c) => c.id));
      stagedConditions.add(created);
      return created;
    }

    var condition = ensureLeaf(values.first);
    if (conditionOperator != 0) {
      for (final value in values.skip(1)) {
        final right = ensureLeaf(value);
        final leftId = condition.id;
        condition =
            stagedConditions
                .where(
                  (c) =>
                      c.kind == groupKind &&
                      c.leftId == leftId &&
                      c.rightId == right.id,
                )
                .firstOrNull ??
            MatrixCondition(
              id: _id(stagedConditions.map((c) => c.id)),
              kind: groupKind,
              leftId: leftId,
              rightId: right.id,
            );
        if (!stagedConditions.any((c) => c.id == condition.id)) {
          stagedConditions.add(condition);
        }
      }
    }
    if (stagedConditions.length > 32) {
      error = 'Too many condition definitions.';
      _changed();
      return false;
    }
    if (config.effects.length + newEffects.length > 32 ||
        newEffects.any(
          (effect) =>
              effect.id == 0 ||
              config.effects.any((existing) => existing.id == effect.id),
        ) ||
        newEffects.map((effect) => effect.id).toSet().length !=
            newEffects.length) {
      error = 'The animation library is full or the animation ID is already in use.';
      _changed();
      return false;
    }
    config.effects.addAll(newEffects.map((effect) => effect.deepCopy()));
    if (sourceIndex < 0) {
      config.sources.add(input);
    } else {
      config.sources[sourceIndex] = input;
    }
    config.conditions
      ..clear()
      ..addAll(stagedConditions);
    next
      ..sourceId = input.id
      ..conditionId = condition.id;
    final index = config.entries.indexWhere((e) => e.id == next.id);
    if (index < 0) {
      config.entries.add(next);
    } else {
      config.entries[index] = next;
    }
    if (oldSource != null &&
        !config.entries.any((e) => e.sourceId == oldSource)) {
      config.sources.removeWhere((s) => s.id == oldSource);
    }
    editing = false;
    _edited();
    return true;
  }

  void removeEntry(int id) {
    if (applying || _disposed) return;
    final previous = config.entries
        .where((entry) => entry.id == id)
        .firstOrNull;
    config.entries.removeWhere((entry) => entry.id == id);
    if (previous != null &&
        !config.entries.any((e) => e.sourceId == previous.sourceId)) {
      config.sources.removeWhere((s) => s.id == previous.sourceId);
    }
    _edited();
  }

  void moveEntry(int index, int delta) {
    if (applying ||
        _disposed ||
        index + delta < 0 ||
        index + delta >= config.entries.length) {
      return;
    }
    final entry = config.entries.removeAt(index);
    config.entries.insert(index + delta, entry);
    _edited();
  }

  Future<void> apply() async {
    if (!canApply || document == null) return;
    applying = true;
    error = null;
    notice = null;
    progress = 0;
    _changed();
    try {
      final update = matrixPatch(config)
        ..expectedRevision = document!.revision
        ..masterSession = document!.masterSession;
      await for (final value in repository.apply(update)) {
        if (_disposed) return;
        deployment = value.status;
        progress = value.transferredBytes / math.max(1, value.totalBytes);
        _changed();
      }
      final fresh = await repository.read();
      if (_disposed) return;
      document = fresh;
      config = MatrixConfig.fromBuffer(fresh.config);
      conflict = false;
      notice = 'Matrix saved to controller.';
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

  Future<void> readCurrent() async {
    if (_disposed ||
        !connected ||
        readingCurrent ||
        refreshing ||
        applying ||
        editing) {
      return;
    }
    readingCurrent = true;
    error = null;
    _changed();
    try {
      final current = await repository.current();
      if (_disposed) return;
      currentDocument = current;
    } catch (e) {
      if (!_disposed) error = _message(e);
    } finally {
      readingCurrent = false;
      _changed();
    }
  }

  void _edited() {
    error = null;
    notice = null;
    _persist();
    _changed();
  }

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  static String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Bad state: |MatrixUploadException: )'),
    '',
  );
  void _persist() {
    _persistTimer?.cancel();
    _persistTimer = Timer(
      const Duration(milliseconds: 200),
      () => unawaited(flush()),
    );
  }

  Future<void> flush() {
    _persistTimer?.cancel();
    if (document == null) return _writes;
    final draft = MatrixDraft(document!.deepCopy(), config.deepCopy());
    _writes = _writes.then((_) => store.save(draft)).catchError((Object _) {
      notice = 'Local draft could not be saved.';
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
