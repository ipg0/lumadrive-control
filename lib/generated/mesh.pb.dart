// This is a generated file - do not edit.
//
// Generated from mesh.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'mesh.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'mesh.pbenum.dart';

class MeshInteropNode extends $pb.GeneratedMessage {
  factory MeshInteropNode({
    $fixnum.Int64? lastSyncedAt,
    $core.List<$core.int>? mac,
  }) {
    final result = create();
    if (lastSyncedAt != null) result.lastSyncedAt = lastSyncedAt;
    if (mac != null) result.mac = mac;
    return result;
  }

  MeshInteropNode._();

  factory MeshInteropNode.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MeshInteropNode.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MeshInteropNode',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'lastSyncedAt')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'mac', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeshInteropNode clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeshInteropNode copyWith(void Function(MeshInteropNode) updates) =>
      super.copyWith((message) => updates(message as MeshInteropNode))
          as MeshInteropNode;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MeshInteropNode create() => MeshInteropNode._();
  @$core.override
  MeshInteropNode createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MeshInteropNode getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MeshInteropNode>(create);
  static MeshInteropNode? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get lastSyncedAt => $_getI64(0);
  @$pb.TagNumber(1)
  set lastSyncedAt($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLastSyncedAt() => $_has(0);
  @$pb.TagNumber(1)
  void clearLastSyncedAt() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get mac => $_getN(1);
  @$pb.TagNumber(2)
  set mac($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMac() => $_has(1);
  @$pb.TagNumber(2)
  void clearMac() => $_clearField(2);
}

class MeshInteropState extends $pb.GeneratedMessage {
  factory MeshInteropState({
    $core.bool? isDiscoveryMode,
    $core.Iterable<MeshInteropNode>? nodes,
  }) {
    final result = create();
    if (isDiscoveryMode != null) result.isDiscoveryMode = isDiscoveryMode;
    if (nodes != null) result.nodes.addAll(nodes);
    return result;
  }

  MeshInteropState._();

  factory MeshInteropState.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MeshInteropState.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MeshInteropState',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'isDiscoveryMode')
    ..pPM<MeshInteropNode>(3, _omitFieldNames ? '' : 'nodes',
        subBuilder: MeshInteropNode.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeshInteropState clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MeshInteropState copyWith(void Function(MeshInteropState) updates) =>
      super.copyWith((message) => updates(message as MeshInteropState))
          as MeshInteropState;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MeshInteropState create() => MeshInteropState._();
  @$core.override
  MeshInteropState createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MeshInteropState getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MeshInteropState>(create);
  static MeshInteropState? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get isDiscoveryMode => $_getBF(0);
  @$pb.TagNumber(1)
  set isDiscoveryMode($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIsDiscoveryMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearIsDiscoveryMode() => $_clearField(1);

  @$pb.TagNumber(3)
  $pb.PbList<MeshInteropNode> get nodes => $_getList(1);
}

class MatrixColor extends $pb.GeneratedMessage {
  factory MatrixColor({
    $core.int? red,
    $core.int? green,
    $core.int? blue,
    $core.int? alpha,
  }) {
    final result = create();
    if (red != null) result.red = red;
    if (green != null) result.green = green;
    if (blue != null) result.blue = blue;
    if (alpha != null) result.alpha = alpha;
    return result;
  }

  MatrixColor._();

  factory MatrixColor.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MatrixColor.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MatrixColor',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'red', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'green', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'blue', fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'alpha', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixColor clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixColor copyWith(void Function(MatrixColor) updates) =>
      super.copyWith((message) => updates(message as MatrixColor))
          as MatrixColor;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatrixColor create() => MatrixColor._();
  @$core.override
  MatrixColor createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MatrixColor getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MatrixColor>(create);
  static MatrixColor? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get red => $_getIZ(0);
  @$pb.TagNumber(1)
  set red($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRed() => $_has(0);
  @$pb.TagNumber(1)
  void clearRed() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get green => $_getIZ(1);
  @$pb.TagNumber(2)
  set green($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGreen() => $_has(1);
  @$pb.TagNumber(2)
  void clearGreen() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get blue => $_getIZ(2);
  @$pb.TagNumber(3)
  set blue($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBlue() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlue() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get alpha => $_getIZ(3);
  @$pb.TagNumber(4)
  set alpha($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAlpha() => $_has(3);
  @$pb.TagNumber(4)
  void clearAlpha() => $_clearField(4);
}

class MatrixKeyframe extends $pb.GeneratedMessage {
  factory MatrixKeyframe({
    $core.int? timeMs,
    $core.int? red,
    $core.int? green,
    $core.int? blue,
    $core.int? alpha,
    MatrixInterpolation? interpolation,
    $core.double? position,
    $core.double? width,
    $core.bool? allPixels,
    $core.int? trackId,
    $core.bool? wrap,
  }) {
    final result = create();
    if (timeMs != null) result.timeMs = timeMs;
    if (red != null) result.red = red;
    if (green != null) result.green = green;
    if (blue != null) result.blue = blue;
    if (alpha != null) result.alpha = alpha;
    if (interpolation != null) result.interpolation = interpolation;
    if (position != null) result.position = position;
    if (width != null) result.width = width;
    if (allPixels != null) result.allPixels = allPixels;
    if (trackId != null) result.trackId = trackId;
    if (wrap != null) result.wrap = wrap;
    return result;
  }

  MatrixKeyframe._();

  factory MatrixKeyframe.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MatrixKeyframe.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MatrixKeyframe',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'timeMs', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'red', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'green', fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'blue', fieldType: $pb.PbFieldType.OU3)
    ..aI(5, _omitFieldNames ? '' : 'alpha', fieldType: $pb.PbFieldType.OU3)
    ..aE<MatrixInterpolation>(6, _omitFieldNames ? '' : 'interpolation',
        enumValues: MatrixInterpolation.values)
    ..aD(7, _omitFieldNames ? '' : 'position', fieldType: $pb.PbFieldType.OF)
    ..aD(8, _omitFieldNames ? '' : 'width', fieldType: $pb.PbFieldType.OF)
    ..aOB(9, _omitFieldNames ? '' : 'allPixels')
    ..aI(10, _omitFieldNames ? '' : 'trackId', fieldType: $pb.PbFieldType.OU3)
    ..aOB(11, _omitFieldNames ? '' : 'wrap')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixKeyframe clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixKeyframe copyWith(void Function(MatrixKeyframe) updates) =>
      super.copyWith((message) => updates(message as MatrixKeyframe))
          as MatrixKeyframe;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatrixKeyframe create() => MatrixKeyframe._();
  @$core.override
  MatrixKeyframe createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MatrixKeyframe getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MatrixKeyframe>(create);
  static MatrixKeyframe? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get timeMs => $_getIZ(0);
  @$pb.TagNumber(1)
  set timeMs($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTimeMs() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimeMs() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get red => $_getIZ(1);
  @$pb.TagNumber(2)
  set red($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRed() => $_has(1);
  @$pb.TagNumber(2)
  void clearRed() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get green => $_getIZ(2);
  @$pb.TagNumber(3)
  set green($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGreen() => $_has(2);
  @$pb.TagNumber(3)
  void clearGreen() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get blue => $_getIZ(3);
  @$pb.TagNumber(4)
  set blue($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBlue() => $_has(3);
  @$pb.TagNumber(4)
  void clearBlue() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get alpha => $_getIZ(4);
  @$pb.TagNumber(5)
  set alpha($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAlpha() => $_has(4);
  @$pb.TagNumber(5)
  void clearAlpha() => $_clearField(5);

  @$pb.TagNumber(6)
  MatrixInterpolation get interpolation => $_getN(5);
  @$pb.TagNumber(6)
  set interpolation(MatrixInterpolation value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasInterpolation() => $_has(5);
  @$pb.TagNumber(6)
  void clearInterpolation() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get position => $_getN(6);
  @$pb.TagNumber(7)
  set position($core.double value) => $_setFloat(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPosition() => $_has(6);
  @$pb.TagNumber(7)
  void clearPosition() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get width => $_getN(7);
  @$pb.TagNumber(8)
  set width($core.double value) => $_setFloat(7, value);
  @$pb.TagNumber(8)
  $core.bool hasWidth() => $_has(7);
  @$pb.TagNumber(8)
  void clearWidth() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get allPixels => $_getBF(8);
  @$pb.TagNumber(9)
  set allPixels($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasAllPixels() => $_has(8);
  @$pb.TagNumber(9)
  void clearAllPixels() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get trackId => $_getIZ(9);
  @$pb.TagNumber(10)
  set trackId($core.int value) => $_setUnsignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasTrackId() => $_has(9);
  @$pb.TagNumber(10)
  void clearTrackId() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get wrap => $_getBF(10);
  @$pb.TagNumber(11)
  set wrap($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasWrap() => $_has(10);
  @$pb.TagNumber(11)
  void clearWrap() => $_clearField(11);
}

class MatrixEffect extends $pb.GeneratedMessage {
  factory MatrixEffect({
    $core.int? id,
    MatrixEffect_Kind? kind,
    $core.int? red,
    $core.int? green,
    $core.int? blue,
    $core.int? alpha,
    $core.int? durationMs,
    $core.int? periodMs,
    $core.int? dutyPercent,
    MatrixColor? secondaryColor,
    $core.Iterable<MatrixKeyframe>? keyframes,
    $core.bool? loop,
    $core.int? wavelengthPixels,
    $core.bool? reverse,
    $core.String? name,
    $core.Iterable<MatrixColor>? gradientColors,
    $core.bool? fillFromCenter,
    $core.int? regionStart,
    $core.int? regionEnd,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (kind != null) result.kind = kind;
    if (red != null) result.red = red;
    if (green != null) result.green = green;
    if (blue != null) result.blue = blue;
    if (alpha != null) result.alpha = alpha;
    if (durationMs != null) result.durationMs = durationMs;
    if (periodMs != null) result.periodMs = periodMs;
    if (dutyPercent != null) result.dutyPercent = dutyPercent;
    if (secondaryColor != null) result.secondaryColor = secondaryColor;
    if (keyframes != null) result.keyframes.addAll(keyframes);
    if (loop != null) result.loop = loop;
    if (wavelengthPixels != null) result.wavelengthPixels = wavelengthPixels;
    if (reverse != null) result.reverse = reverse;
    if (name != null) result.name = name;
    if (gradientColors != null) result.gradientColors.addAll(gradientColors);
    if (fillFromCenter != null) result.fillFromCenter = fillFromCenter;
    if (regionStart != null) result.regionStart = regionStart;
    if (regionEnd != null) result.regionEnd = regionEnd;
    return result;
  }

  MatrixEffect._();

  factory MatrixEffect.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MatrixEffect.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MatrixEffect',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aE<MatrixEffect_Kind>(2, _omitFieldNames ? '' : 'kind',
        enumValues: MatrixEffect_Kind.values)
    ..aI(3, _omitFieldNames ? '' : 'red', fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'green', fieldType: $pb.PbFieldType.OU3)
    ..aI(5, _omitFieldNames ? '' : 'blue', fieldType: $pb.PbFieldType.OU3)
    ..aI(6, _omitFieldNames ? '' : 'alpha', fieldType: $pb.PbFieldType.OU3)
    ..aI(7, _omitFieldNames ? '' : 'durationMs', fieldType: $pb.PbFieldType.OU3)
    ..aI(8, _omitFieldNames ? '' : 'periodMs', fieldType: $pb.PbFieldType.OU3)
    ..aI(9, _omitFieldNames ? '' : 'dutyPercent',
        fieldType: $pb.PbFieldType.OU3)
    ..aOM<MatrixColor>(10, _omitFieldNames ? '' : 'secondaryColor',
        subBuilder: MatrixColor.create)
    ..pPM<MatrixKeyframe>(11, _omitFieldNames ? '' : 'keyframes',
        subBuilder: MatrixKeyframe.create)
    ..aOB(12, _omitFieldNames ? '' : 'loop')
    ..aI(13, _omitFieldNames ? '' : 'wavelengthPixels',
        fieldType: $pb.PbFieldType.OU3)
    ..aOB(14, _omitFieldNames ? '' : 'reverse')
    ..aOS(15, _omitFieldNames ? '' : 'name')
    ..pPM<MatrixColor>(16, _omitFieldNames ? '' : 'gradientColors',
        subBuilder: MatrixColor.create)
    ..aOB(17, _omitFieldNames ? '' : 'fillFromCenter')
    ..aI(18, _omitFieldNames ? '' : 'regionStart',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(19, _omitFieldNames ? '' : 'regionEnd', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixEffect clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixEffect copyWith(void Function(MatrixEffect) updates) =>
      super.copyWith((message) => updates(message as MatrixEffect))
          as MatrixEffect;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatrixEffect create() => MatrixEffect._();
  @$core.override
  MatrixEffect createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MatrixEffect getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MatrixEffect>(create);
  static MatrixEffect? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  MatrixEffect_Kind get kind => $_getN(1);
  @$pb.TagNumber(2)
  set kind(MatrixEffect_Kind value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get red => $_getIZ(2);
  @$pb.TagNumber(3)
  set red($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRed() => $_has(2);
  @$pb.TagNumber(3)
  void clearRed() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get green => $_getIZ(3);
  @$pb.TagNumber(4)
  set green($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGreen() => $_has(3);
  @$pb.TagNumber(4)
  void clearGreen() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get blue => $_getIZ(4);
  @$pb.TagNumber(5)
  set blue($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBlue() => $_has(4);
  @$pb.TagNumber(5)
  void clearBlue() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get alpha => $_getIZ(5);
  @$pb.TagNumber(6)
  set alpha($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAlpha() => $_has(5);
  @$pb.TagNumber(6)
  void clearAlpha() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get durationMs => $_getIZ(6);
  @$pb.TagNumber(7)
  set durationMs($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDurationMs() => $_has(6);
  @$pb.TagNumber(7)
  void clearDurationMs() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get periodMs => $_getIZ(7);
  @$pb.TagNumber(8)
  set periodMs($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPeriodMs() => $_has(7);
  @$pb.TagNumber(8)
  void clearPeriodMs() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get dutyPercent => $_getIZ(8);
  @$pb.TagNumber(9)
  set dutyPercent($core.int value) => $_setUnsignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDutyPercent() => $_has(8);
  @$pb.TagNumber(9)
  void clearDutyPercent() => $_clearField(9);

  @$pb.TagNumber(10)
  MatrixColor get secondaryColor => $_getN(9);
  @$pb.TagNumber(10)
  set secondaryColor(MatrixColor value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasSecondaryColor() => $_has(9);
  @$pb.TagNumber(10)
  void clearSecondaryColor() => $_clearField(10);
  @$pb.TagNumber(10)
  MatrixColor ensureSecondaryColor() => $_ensure(9);

  @$pb.TagNumber(11)
  $pb.PbList<MatrixKeyframe> get keyframes => $_getList(10);

  @$pb.TagNumber(12)
  $core.bool get loop => $_getBF(11);
  @$pb.TagNumber(12)
  set loop($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasLoop() => $_has(11);
  @$pb.TagNumber(12)
  void clearLoop() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get wavelengthPixels => $_getIZ(12);
  @$pb.TagNumber(13)
  set wavelengthPixels($core.int value) => $_setUnsignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasWavelengthPixels() => $_has(12);
  @$pb.TagNumber(13)
  void clearWavelengthPixels() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get reverse => $_getBF(13);
  @$pb.TagNumber(14)
  set reverse($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasReverse() => $_has(13);
  @$pb.TagNumber(14)
  void clearReverse() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get name => $_getSZ(14);
  @$pb.TagNumber(15)
  set name($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasName() => $_has(14);
  @$pb.TagNumber(15)
  void clearName() => $_clearField(15);

  @$pb.TagNumber(16)
  $pb.PbList<MatrixColor> get gradientColors => $_getList(15);

  @$pb.TagNumber(17)
  $core.bool get fillFromCenter => $_getBF(16);
  @$pb.TagNumber(17)
  set fillFromCenter($core.bool value) => $_setBool(16, value);
  @$pb.TagNumber(17)
  $core.bool hasFillFromCenter() => $_has(16);
  @$pb.TagNumber(17)
  void clearFillFromCenter() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.int get regionStart => $_getIZ(17);
  @$pb.TagNumber(18)
  set regionStart($core.int value) => $_setUnsignedInt32(17, value);
  @$pb.TagNumber(18)
  $core.bool hasRegionStart() => $_has(17);
  @$pb.TagNumber(18)
  void clearRegionStart() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.int get regionEnd => $_getIZ(18);
  @$pb.TagNumber(19)
  set regionEnd($core.int value) => $_setUnsignedInt32(18, value);
  @$pb.TagNumber(19)
  $core.bool hasRegionEnd() => $_has(18);
  @$pb.TagNumber(19)
  void clearRegionEnd() => $_clearField(19);
}

class MatrixSource extends $pb.GeneratedMessage {
  factory MatrixSource({
    $core.int? id,
    MatrixSource_Kind? kind,
    $core.List<$core.int>? nodeMac,
    $core.int? gpio,
    $core.bool? rising,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (kind != null) result.kind = kind;
    if (nodeMac != null) result.nodeMac = nodeMac;
    if (gpio != null) result.gpio = gpio;
    if (rising != null) result.rising = rising;
    return result;
  }

  MatrixSource._();

  factory MatrixSource.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MatrixSource.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MatrixSource',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aE<MatrixSource_Kind>(2, _omitFieldNames ? '' : 'kind',
        enumValues: MatrixSource_Kind.values)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'nodeMac', $pb.PbFieldType.OY)
    ..aI(4, _omitFieldNames ? '' : 'gpio', fieldType: $pb.PbFieldType.OU3)
    ..aOB(5, _omitFieldNames ? '' : 'rising')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixSource clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixSource copyWith(void Function(MatrixSource) updates) =>
      super.copyWith((message) => updates(message as MatrixSource))
          as MatrixSource;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatrixSource create() => MatrixSource._();
  @$core.override
  MatrixSource createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MatrixSource getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MatrixSource>(create);
  static MatrixSource? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  MatrixSource_Kind get kind => $_getN(1);
  @$pb.TagNumber(2)
  set kind(MatrixSource_Kind value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get nodeMac => $_getN(2);
  @$pb.TagNumber(3)
  set nodeMac($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNodeMac() => $_has(2);
  @$pb.TagNumber(3)
  void clearNodeMac() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get gpio => $_getIZ(3);
  @$pb.TagNumber(4)
  set gpio($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGpio() => $_has(3);
  @$pb.TagNumber(4)
  void clearGpio() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get rising => $_getBF(4);
  @$pb.TagNumber(5)
  set rising($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRising() => $_has(4);
  @$pb.TagNumber(5)
  void clearRising() => $_clearField(5);
}

class MatrixCondition extends $pb.GeneratedMessage {
  factory MatrixCondition({
    $core.int? id,
    MatrixCondition_Kind? kind,
    $core.int? modeId,
    $core.bool? inverted,
    $core.int? leftId,
    $core.int? rightId,
    $core.List<$core.int>? nodeMac,
    $core.int? gpio,
    $core.bool? high,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (kind != null) result.kind = kind;
    if (modeId != null) result.modeId = modeId;
    if (inverted != null) result.inverted = inverted;
    if (leftId != null) result.leftId = leftId;
    if (rightId != null) result.rightId = rightId;
    if (nodeMac != null) result.nodeMac = nodeMac;
    if (gpio != null) result.gpio = gpio;
    if (high != null) result.high = high;
    return result;
  }

  MatrixCondition._();

  factory MatrixCondition.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MatrixCondition.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MatrixCondition',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aE<MatrixCondition_Kind>(2, _omitFieldNames ? '' : 'kind',
        enumValues: MatrixCondition_Kind.values)
    ..aI(3, _omitFieldNames ? '' : 'modeId', fieldType: $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'inverted')
    ..aI(5, _omitFieldNames ? '' : 'leftId', fieldType: $pb.PbFieldType.OU3)
    ..aI(6, _omitFieldNames ? '' : 'rightId', fieldType: $pb.PbFieldType.OU3)
    ..a<$core.List<$core.int>>(
        7, _omitFieldNames ? '' : 'nodeMac', $pb.PbFieldType.OY)
    ..aI(8, _omitFieldNames ? '' : 'gpio', fieldType: $pb.PbFieldType.OU3)
    ..aOB(9, _omitFieldNames ? '' : 'high')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixCondition clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixCondition copyWith(void Function(MatrixCondition) updates) =>
      super.copyWith((message) => updates(message as MatrixCondition))
          as MatrixCondition;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatrixCondition create() => MatrixCondition._();
  @$core.override
  MatrixCondition createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MatrixCondition getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MatrixCondition>(create);
  static MatrixCondition? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  MatrixCondition_Kind get kind => $_getN(1);
  @$pb.TagNumber(2)
  set kind(MatrixCondition_Kind value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get modeId => $_getIZ(2);
  @$pb.TagNumber(3)
  set modeId($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasModeId() => $_has(2);
  @$pb.TagNumber(3)
  void clearModeId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get inverted => $_getBF(3);
  @$pb.TagNumber(4)
  set inverted($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasInverted() => $_has(3);
  @$pb.TagNumber(4)
  void clearInverted() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get leftId => $_getIZ(4);
  @$pb.TagNumber(5)
  set leftId($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLeftId() => $_has(4);
  @$pb.TagNumber(5)
  void clearLeftId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get rightId => $_getIZ(5);
  @$pb.TagNumber(6)
  set rightId($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRightId() => $_has(5);
  @$pb.TagNumber(6)
  void clearRightId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.List<$core.int> get nodeMac => $_getN(6);
  @$pb.TagNumber(7)
  set nodeMac($core.List<$core.int> value) => $_setBytes(6, value);
  @$pb.TagNumber(7)
  $core.bool hasNodeMac() => $_has(6);
  @$pb.TagNumber(7)
  void clearNodeMac() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get gpio => $_getIZ(7);
  @$pb.TagNumber(8)
  set gpio($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasGpio() => $_has(7);
  @$pb.TagNumber(8)
  void clearGpio() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get high => $_getBF(8);
  @$pb.TagNumber(9)
  set high($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasHigh() => $_has(8);
  @$pb.TagNumber(9)
  void clearHigh() => $_clearField(9);
}

class MatrixMode extends $pb.GeneratedMessage {
  factory MatrixMode({
    $core.int? id,
    $core.String? name,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    return result;
  }

  MatrixMode._();

  factory MatrixMode.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MatrixMode.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MatrixMode',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixMode clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixMode copyWith(void Function(MatrixMode) updates) =>
      super.copyWith((message) => updates(message as MatrixMode)) as MatrixMode;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatrixMode create() => MatrixMode._();
  @$core.override
  MatrixMode createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MatrixMode getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MatrixMode>(create);
  static MatrixMode? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);
}

/// Boundary indices: 0 -> 60 covers pixels 0..59; 12 -> 10 covers 11,10.
class MatrixLayout extends $pb.GeneratedMessage {
  factory MatrixLayout({
    $core.List<$core.int>? nodeMac,
    MatrixDriver? driver,
    $core.int? from,
    $core.int? to,
    $core.String? name,
    $core.int? sourceIndex,
    CarPosition? carPosition,
  }) {
    final result = create();
    if (nodeMac != null) result.nodeMac = nodeMac;
    if (driver != null) result.driver = driver;
    if (from != null) result.from = from;
    if (to != null) result.to = to;
    if (name != null) result.name = name;
    if (sourceIndex != null) result.sourceIndex = sourceIndex;
    if (carPosition != null) result.carPosition = carPosition;
    return result;
  }

  MatrixLayout._();

  factory MatrixLayout.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MatrixLayout.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MatrixLayout',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'nodeMac', $pb.PbFieldType.OY)
    ..aE<MatrixDriver>(2, _omitFieldNames ? '' : 'driver',
        enumValues: MatrixDriver.values)
    ..aI(3, _omitFieldNames ? '' : 'from', fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'to', fieldType: $pb.PbFieldType.OU3)
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aI(6, _omitFieldNames ? '' : 'sourceIndex',
        fieldType: $pb.PbFieldType.OU3)
    ..aE<CarPosition>(7, _omitFieldNames ? '' : 'carPosition',
        enumValues: CarPosition.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixLayout clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixLayout copyWith(void Function(MatrixLayout) updates) =>
      super.copyWith((message) => updates(message as MatrixLayout))
          as MatrixLayout;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatrixLayout create() => MatrixLayout._();
  @$core.override
  MatrixLayout createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MatrixLayout getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MatrixLayout>(create);
  static MatrixLayout? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get nodeMac => $_getN(0);
  @$pb.TagNumber(1)
  set nodeMac($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeMac() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeMac() => $_clearField(1);

  @$pb.TagNumber(2)
  MatrixDriver get driver => $_getN(1);
  @$pb.TagNumber(2)
  set driver(MatrixDriver value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDriver() => $_has(1);
  @$pb.TagNumber(2)
  void clearDriver() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get from => $_getIZ(2);
  @$pb.TagNumber(3)
  set from($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFrom() => $_has(2);
  @$pb.TagNumber(3)
  void clearFrom() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get to => $_getIZ(3);
  @$pb.TagNumber(4)
  set to($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTo() => $_has(3);
  @$pb.TagNumber(4)
  void clearTo() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get name => $_getSZ(4);
  @$pb.TagNumber(5)
  set name($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasName() => $_has(4);
  @$pb.TagNumber(5)
  void clearName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get sourceIndex => $_getIZ(5);
  @$pb.TagNumber(6)
  set sourceIndex($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSourceIndex() => $_has(5);
  @$pb.TagNumber(6)
  void clearSourceIndex() => $_clearField(6);

  @$pb.TagNumber(7)
  CarPosition get carPosition => $_getN(6);
  @$pb.TagNumber(7)
  set carPosition(CarPosition value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasCarPosition() => $_has(6);
  @$pb.TagNumber(7)
  void clearCarPosition() => $_clearField(7);
}

class MatrixEntry extends $pb.GeneratedMessage {
  factory MatrixEntry({
    $core.int? id,
    $core.int? effectId,
    $core.int? sourceId,
    $core.int? conditionId,
    $core.int? priority,
    $core.String? name,
    $core.bool? opaqueBackground,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (effectId != null) result.effectId = effectId;
    if (sourceId != null) result.sourceId = sourceId;
    if (conditionId != null) result.conditionId = conditionId;
    if (priority != null) result.priority = priority;
    if (name != null) result.name = name;
    if (opaqueBackground != null) result.opaqueBackground = opaqueBackground;
    return result;
  }

  MatrixEntry._();

  factory MatrixEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MatrixEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MatrixEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'effectId', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'sourceId', fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'conditionId',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(5, _omitFieldNames ? '' : 'priority', fieldType: $pb.PbFieldType.OU3)
    ..aOS(7, _omitFieldNames ? '' : 'name')
    ..aOB(8, _omitFieldNames ? '' : 'opaqueBackground')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixEntry copyWith(void Function(MatrixEntry) updates) =>
      super.copyWith((message) => updates(message as MatrixEntry))
          as MatrixEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatrixEntry create() => MatrixEntry._();
  @$core.override
  MatrixEntry createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MatrixEntry getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MatrixEntry>(create);
  static MatrixEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get effectId => $_getIZ(1);
  @$pb.TagNumber(2)
  set effectId($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEffectId() => $_has(1);
  @$pb.TagNumber(2)
  void clearEffectId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get sourceId => $_getIZ(2);
  @$pb.TagNumber(3)
  set sourceId($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSourceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSourceId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get conditionId => $_getIZ(3);
  @$pb.TagNumber(4)
  set conditionId($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConditionId() => $_has(3);
  @$pb.TagNumber(4)
  void clearConditionId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get priority => $_getIZ(4);
  @$pb.TagNumber(5)
  set priority($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPriority() => $_has(4);
  @$pb.TagNumber(5)
  void clearPriority() => $_clearField(5);

  @$pb.TagNumber(7)
  $core.String get name => $_getSZ(5);
  @$pb.TagNumber(7)
  set name($core.String value) => $_setString(5, value);
  @$pb.TagNumber(7)
  $core.bool hasName() => $_has(5);
  @$pb.TagNumber(7)
  void clearName() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get opaqueBackground => $_getBF(6);
  @$pb.TagNumber(8)
  set opaqueBackground($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(8)
  $core.bool hasOpaqueBackground() => $_has(6);
  @$pb.TagNumber(8)
  void clearOpaqueBackground() => $_clearField(8);
}

class MatrixConfig extends $pb.GeneratedMessage {
  factory MatrixConfig({
    $core.int? schemaVersion,
    $core.Iterable<MatrixEffect>? effects,
    $core.Iterable<MatrixSource>? sources,
    $core.Iterable<MatrixCondition>? conditions,
    $core.Iterable<MatrixEntry>? entries,
    $core.Iterable<MatrixLayout>? layout,
    $core.bool? factoryDefault,
    $core.Iterable<MatrixMode>? modes,
    $core.int? activeModeId,
    $core.int? centerIndex,
  }) {
    final result = create();
    if (schemaVersion != null) result.schemaVersion = schemaVersion;
    if (effects != null) result.effects.addAll(effects);
    if (sources != null) result.sources.addAll(sources);
    if (conditions != null) result.conditions.addAll(conditions);
    if (entries != null) result.entries.addAll(entries);
    if (layout != null) result.layout.addAll(layout);
    if (factoryDefault != null) result.factoryDefault = factoryDefault;
    if (modes != null) result.modes.addAll(modes);
    if (activeModeId != null) result.activeModeId = activeModeId;
    if (centerIndex != null) result.centerIndex = centerIndex;
    return result;
  }

  MatrixConfig._();

  factory MatrixConfig.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MatrixConfig.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MatrixConfig',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'schemaVersion',
        fieldType: $pb.PbFieldType.OU3)
    ..pPM<MatrixEffect>(2, _omitFieldNames ? '' : 'effects',
        subBuilder: MatrixEffect.create)
    ..pPM<MatrixSource>(3, _omitFieldNames ? '' : 'sources',
        subBuilder: MatrixSource.create)
    ..pPM<MatrixCondition>(4, _omitFieldNames ? '' : 'conditions',
        subBuilder: MatrixCondition.create)
    ..pPM<MatrixEntry>(5, _omitFieldNames ? '' : 'entries',
        subBuilder: MatrixEntry.create)
    ..pPM<MatrixLayout>(6, _omitFieldNames ? '' : 'layout',
        subBuilder: MatrixLayout.create)
    ..aOB(7, _omitFieldNames ? '' : 'factoryDefault')
    ..pPM<MatrixMode>(8, _omitFieldNames ? '' : 'modes',
        subBuilder: MatrixMode.create)
    ..aI(9, _omitFieldNames ? '' : 'activeModeId',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(10, _omitFieldNames ? '' : 'centerIndex',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixConfig clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixConfig copyWith(void Function(MatrixConfig) updates) =>
      super.copyWith((message) => updates(message as MatrixConfig))
          as MatrixConfig;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatrixConfig create() => MatrixConfig._();
  @$core.override
  MatrixConfig createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MatrixConfig getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MatrixConfig>(create);
  static MatrixConfig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get schemaVersion => $_getIZ(0);
  @$pb.TagNumber(1)
  set schemaVersion($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSchemaVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearSchemaVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<MatrixEffect> get effects => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<MatrixSource> get sources => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<MatrixCondition> get conditions => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<MatrixEntry> get entries => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<MatrixLayout> get layout => $_getList(5);

  @$pb.TagNumber(7)
  $core.bool get factoryDefault => $_getBF(6);
  @$pb.TagNumber(7)
  set factoryDefault($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFactoryDefault() => $_has(6);
  @$pb.TagNumber(7)
  void clearFactoryDefault() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<MatrixMode> get modes => $_getList(7);

  @$pb.TagNumber(9)
  $core.int get activeModeId => $_getIZ(8);
  @$pb.TagNumber(9)
  set activeModeId($core.int value) => $_setUnsignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasActiveModeId() => $_has(8);
  @$pb.TagNumber(9)
  void clearActiveModeId() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get centerIndex => $_getIZ(9);
  @$pb.TagNumber(10)
  set centerIndex($core.int value) => $_setUnsignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCenterIndex() => $_has(9);
  @$pb.TagNumber(10)
  void clearCenterIndex() => $_clearField(10);
}

class TransferBegin extends $pb.GeneratedMessage {
  factory TransferBegin({
    $core.int? transferId,
    $core.int? totalSize,
    $core.int? crc32,
  }) {
    final result = create();
    if (transferId != null) result.transferId = transferId;
    if (totalSize != null) result.totalSize = totalSize;
    if (crc32 != null) result.crc32 = crc32;
    return result;
  }

  TransferBegin._();

  factory TransferBegin.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TransferBegin.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransferBegin',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'transferId', fieldType: $pb.PbFieldType.OF3)
    ..aI(2, _omitFieldNames ? '' : 'totalSize', fieldType: $pb.PbFieldType.OF3)
    ..aI(3, _omitFieldNames ? '' : 'crc32', fieldType: $pb.PbFieldType.OF3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferBegin clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferBegin copyWith(void Function(TransferBegin) updates) =>
      super.copyWith((message) => updates(message as TransferBegin))
          as TransferBegin;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferBegin create() => TransferBegin._();
  @$core.override
  TransferBegin createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TransferBegin getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferBegin>(create);
  static TransferBegin? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get transferId => $_getIZ(0);
  @$pb.TagNumber(1)
  set transferId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTransferId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransferId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get totalSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalSize($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalSize() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get crc32 => $_getIZ(2);
  @$pb.TagNumber(3)
  set crc32($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCrc32() => $_has(2);
  @$pb.TagNumber(3)
  void clearCrc32() => $_clearField(3);
}

class TransferChunk extends $pb.GeneratedMessage {
  factory TransferChunk({
    $core.int? transferId,
    $core.int? offset,
    $core.List<$core.int>? data,
  }) {
    final result = create();
    if (transferId != null) result.transferId = transferId;
    if (offset != null) result.offset = offset;
    if (data != null) result.data = data;
    return result;
  }

  TransferChunk._();

  factory TransferChunk.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TransferChunk.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransferChunk',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'transferId', fieldType: $pb.PbFieldType.OF3)
    ..aI(2, _omitFieldNames ? '' : 'offset', fieldType: $pb.PbFieldType.OU3)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferChunk clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferChunk copyWith(void Function(TransferChunk) updates) =>
      super.copyWith((message) => updates(message as TransferChunk))
          as TransferChunk;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferChunk create() => TransferChunk._();
  @$core.override
  TransferChunk createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TransferChunk getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferChunk>(create);
  static TransferChunk? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get transferId => $_getIZ(0);
  @$pb.TagNumber(1)
  set transferId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTransferId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransferId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get offset => $_getIZ(1);
  @$pb.TagNumber(2)
  set offset($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOffset() => $_has(1);
  @$pb.TagNumber(2)
  void clearOffset() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get data => $_getN(2);
  @$pb.TagNumber(3)
  set data($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasData() => $_has(2);
  @$pb.TagNumber(3)
  void clearData() => $_clearField(3);
}

enum MatrixUpload_Operation {
  begin,
  chunk,
  commit,
  abort,
  layoutRequest,
  layoutBegin,
  matrixBegin,
  notSet
}

class MatrixUpload extends $pb.GeneratedMessage {
  factory MatrixUpload({
    TransferBegin? begin,
    TransferChunk? chunk,
    $core.int? commit,
    $core.int? abort,
    LayoutRequest? layoutRequest,
    TransferBegin? layoutBegin,
    TransferBegin? matrixBegin,
  }) {
    final result = create();
    if (begin != null) result.begin = begin;
    if (chunk != null) result.chunk = chunk;
    if (commit != null) result.commit = commit;
    if (abort != null) result.abort = abort;
    if (layoutRequest != null) result.layoutRequest = layoutRequest;
    if (layoutBegin != null) result.layoutBegin = layoutBegin;
    if (matrixBegin != null) result.matrixBegin = matrixBegin;
    return result;
  }

  MatrixUpload._();

  factory MatrixUpload.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MatrixUpload.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, MatrixUpload_Operation>
      _MatrixUpload_OperationByTag = {
    1: MatrixUpload_Operation.begin,
    2: MatrixUpload_Operation.chunk,
    3: MatrixUpload_Operation.commit,
    4: MatrixUpload_Operation.abort,
    5: MatrixUpload_Operation.layoutRequest,
    6: MatrixUpload_Operation.layoutBegin,
    7: MatrixUpload_Operation.matrixBegin,
    0: MatrixUpload_Operation.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MatrixUpload',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4, 5, 6, 7])
    ..aOM<TransferBegin>(1, _omitFieldNames ? '' : 'begin',
        subBuilder: TransferBegin.create)
    ..aOM<TransferChunk>(2, _omitFieldNames ? '' : 'chunk',
        subBuilder: TransferChunk.create)
    ..aI(3, _omitFieldNames ? '' : 'commit', fieldType: $pb.PbFieldType.OF3)
    ..aI(4, _omitFieldNames ? '' : 'abort', fieldType: $pb.PbFieldType.OF3)
    ..aOM<LayoutRequest>(5, _omitFieldNames ? '' : 'layoutRequest',
        subBuilder: LayoutRequest.create)
    ..aOM<TransferBegin>(6, _omitFieldNames ? '' : 'layoutBegin',
        subBuilder: TransferBegin.create)
    ..aOM<TransferBegin>(7, _omitFieldNames ? '' : 'matrixBegin',
        subBuilder: TransferBegin.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixUpload clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixUpload copyWith(void Function(MatrixUpload) updates) =>
      super.copyWith((message) => updates(message as MatrixUpload))
          as MatrixUpload;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatrixUpload create() => MatrixUpload._();
  @$core.override
  MatrixUpload createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MatrixUpload getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MatrixUpload>(create);
  static MatrixUpload? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  MatrixUpload_Operation whichOperation() =>
      _MatrixUpload_OperationByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  @$pb.TagNumber(6)
  @$pb.TagNumber(7)
  void clearOperation() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  TransferBegin get begin => $_getN(0);
  @$pb.TagNumber(1)
  set begin(TransferBegin value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBegin() => $_has(0);
  @$pb.TagNumber(1)
  void clearBegin() => $_clearField(1);
  @$pb.TagNumber(1)
  TransferBegin ensureBegin() => $_ensure(0);

  @$pb.TagNumber(2)
  TransferChunk get chunk => $_getN(1);
  @$pb.TagNumber(2)
  set chunk(TransferChunk value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasChunk() => $_has(1);
  @$pb.TagNumber(2)
  void clearChunk() => $_clearField(2);
  @$pb.TagNumber(2)
  TransferChunk ensureChunk() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.int get commit => $_getIZ(2);
  @$pb.TagNumber(3)
  set commit($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCommit() => $_has(2);
  @$pb.TagNumber(3)
  void clearCommit() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get abort => $_getIZ(3);
  @$pb.TagNumber(4)
  set abort($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAbort() => $_has(3);
  @$pb.TagNumber(4)
  void clearAbort() => $_clearField(4);

  @$pb.TagNumber(5)
  LayoutRequest get layoutRequest => $_getN(4);
  @$pb.TagNumber(5)
  set layoutRequest(LayoutRequest value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasLayoutRequest() => $_has(4);
  @$pb.TagNumber(5)
  void clearLayoutRequest() => $_clearField(5);
  @$pb.TagNumber(5)
  LayoutRequest ensureLayoutRequest() => $_ensure(4);

  @$pb.TagNumber(6)
  TransferBegin get layoutBegin => $_getN(5);
  @$pb.TagNumber(6)
  set layoutBegin(TransferBegin value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasLayoutBegin() => $_has(5);
  @$pb.TagNumber(6)
  void clearLayoutBegin() => $_clearField(6);
  @$pb.TagNumber(6)
  TransferBegin ensureLayoutBegin() => $_ensure(5);

  @$pb.TagNumber(7)
  TransferBegin get matrixBegin => $_getN(6);
  @$pb.TagNumber(7)
  set matrixBegin(TransferBegin value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasMatrixBegin() => $_has(6);
  @$pb.TagNumber(7)
  void clearMatrixBegin() => $_clearField(7);
  @$pb.TagNumber(7)
  TransferBegin ensureMatrixBegin() => $_ensure(6);
}

/// Layout-only uploads use the same begin/chunk/commit transport as matrices.
class LayoutUpdate extends $pb.GeneratedMessage {
  factory LayoutUpdate({
    $fixnum.Int64? expectedRevision,
    $fixnum.Int64? masterSession,
    $core.Iterable<MatrixLayout>? layout,
    $core.int? centerIndex,
  }) {
    final result = create();
    if (expectedRevision != null) result.expectedRevision = expectedRevision;
    if (masterSession != null) result.masterSession = masterSession;
    if (layout != null) result.layout.addAll(layout);
    if (centerIndex != null) result.centerIndex = centerIndex;
    return result;
  }

  LayoutUpdate._();

  factory LayoutUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LayoutUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LayoutUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'expectedRevision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'masterSession', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..pPM<MatrixLayout>(3, _omitFieldNames ? '' : 'layout',
        subBuilder: MatrixLayout.create)
    ..aI(4, _omitFieldNames ? '' : 'centerIndex',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LayoutUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LayoutUpdate copyWith(void Function(LayoutUpdate) updates) =>
      super.copyWith((message) => updates(message as LayoutUpdate))
          as LayoutUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LayoutUpdate create() => LayoutUpdate._();
  @$core.override
  LayoutUpdate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LayoutUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LayoutUpdate>(create);
  static LayoutUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get expectedRevision => $_getI64(0);
  @$pb.TagNumber(1)
  set expectedRevision($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasExpectedRevision() => $_has(0);
  @$pb.TagNumber(1)
  void clearExpectedRevision() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get masterSession => $_getI64(1);
  @$pb.TagNumber(2)
  set masterSession($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMasterSession() => $_has(1);
  @$pb.TagNumber(2)
  void clearMasterSession() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<MatrixLayout> get layout => $_getList(2);

  @$pb.TagNumber(4)
  $core.int get centerIndex => $_getIZ(3);
  @$pb.TagNumber(4)
  set centerIndex($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCenterIndex() => $_has(3);
  @$pb.TagNumber(4)
  void clearCenterIndex() => $_clearField(4);
}

/// Edits the matrix and animation library, preserving the current physical layout.
class MatrixUpdate extends $pb.GeneratedMessage {
  factory MatrixUpdate({
    $fixnum.Int64? expectedRevision,
    $fixnum.Int64? masterSession,
    $core.Iterable<MatrixEffect>? effects,
    $core.Iterable<MatrixSource>? sources,
    $core.Iterable<MatrixCondition>? conditions,
    $core.Iterable<MatrixEntry>? entries,
    $core.Iterable<MatrixMode>? modes,
    $core.int? activeModeId,
  }) {
    final result = create();
    if (expectedRevision != null) result.expectedRevision = expectedRevision;
    if (masterSession != null) result.masterSession = masterSession;
    if (effects != null) result.effects.addAll(effects);
    if (sources != null) result.sources.addAll(sources);
    if (conditions != null) result.conditions.addAll(conditions);
    if (entries != null) result.entries.addAll(entries);
    if (modes != null) result.modes.addAll(modes);
    if (activeModeId != null) result.activeModeId = activeModeId;
    return result;
  }

  MatrixUpdate._();

  factory MatrixUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MatrixUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MatrixUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'expectedRevision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'masterSession', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..pPM<MatrixEffect>(3, _omitFieldNames ? '' : 'effects',
        subBuilder: MatrixEffect.create)
    ..pPM<MatrixSource>(4, _omitFieldNames ? '' : 'sources',
        subBuilder: MatrixSource.create)
    ..pPM<MatrixCondition>(5, _omitFieldNames ? '' : 'conditions',
        subBuilder: MatrixCondition.create)
    ..pPM<MatrixEntry>(6, _omitFieldNames ? '' : 'entries',
        subBuilder: MatrixEntry.create)
    ..pPM<MatrixMode>(7, _omitFieldNames ? '' : 'modes',
        subBuilder: MatrixMode.create)
    ..aI(8, _omitFieldNames ? '' : 'activeModeId',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixUpdate copyWith(void Function(MatrixUpdate) updates) =>
      super.copyWith((message) => updates(message as MatrixUpdate))
          as MatrixUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatrixUpdate create() => MatrixUpdate._();
  @$core.override
  MatrixUpdate createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MatrixUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MatrixUpdate>(create);
  static MatrixUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get expectedRevision => $_getI64(0);
  @$pb.TagNumber(1)
  set expectedRevision($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasExpectedRevision() => $_has(0);
  @$pb.TagNumber(1)
  void clearExpectedRevision() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get masterSession => $_getI64(1);
  @$pb.TagNumber(2)
  set masterSession($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMasterSession() => $_has(1);
  @$pb.TagNumber(2)
  void clearMasterSession() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<MatrixEffect> get effects => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<MatrixSource> get sources => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<MatrixCondition> get conditions => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<MatrixEntry> get entries => $_getList(5);

  @$pb.TagNumber(7)
  $pb.PbList<MatrixMode> get modes => $_getList(6);

  @$pb.TagNumber(8)
  $core.int get activeModeId => $_getIZ(7);
  @$pb.TagNumber(8)
  set activeModeId($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasActiveModeId() => $_has(7);
  @$pb.TagNumber(8)
  void clearActiveModeId() => $_clearField(8);
}

class MatrixInputNode extends $pb.GeneratedMessage {
  factory MatrixInputNode({
    $core.List<$core.int>? nodeMac,
    $core.Iterable<$core.int>? gpios,
    $core.bool? known,
    $core.bool? online,
    $core.String? firmwareVersion,
  }) {
    final result = create();
    if (nodeMac != null) result.nodeMac = nodeMac;
    if (gpios != null) result.gpios.addAll(gpios);
    if (known != null) result.known = known;
    if (online != null) result.online = online;
    if (firmwareVersion != null) result.firmwareVersion = firmwareVersion;
    return result;
  }

  MatrixInputNode._();

  factory MatrixInputNode.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MatrixInputNode.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MatrixInputNode',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'nodeMac', $pb.PbFieldType.OY)
    ..p<$core.int>(2, _omitFieldNames ? '' : 'gpios', $pb.PbFieldType.KU3)
    ..aOB(3, _omitFieldNames ? '' : 'known')
    ..aOB(4, _omitFieldNames ? '' : 'online')
    ..aOS(5, _omitFieldNames ? '' : 'firmwareVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixInputNode clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixInputNode copyWith(void Function(MatrixInputNode) updates) =>
      super.copyWith((message) => updates(message as MatrixInputNode))
          as MatrixInputNode;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatrixInputNode create() => MatrixInputNode._();
  @$core.override
  MatrixInputNode createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MatrixInputNode getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MatrixInputNode>(create);
  static MatrixInputNode? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get nodeMac => $_getN(0);
  @$pb.TagNumber(1)
  set nodeMac($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeMac() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeMac() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.int> get gpios => $_getList(1);

  @$pb.TagNumber(3)
  $core.bool get known => $_getBF(2);
  @$pb.TagNumber(3)
  set known($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKnown() => $_has(2);
  @$pb.TagNumber(3)
  void clearKnown() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get online => $_getBF(3);
  @$pb.TagNumber(4)
  set online($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOnline() => $_has(3);
  @$pb.TagNumber(4)
  void clearOnline() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get firmwareVersion => $_getSZ(4);
  @$pb.TagNumber(5)
  set firmwareVersion($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFirmwareVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearFirmwareVersion() => $_clearField(5);
}

class MatrixDocument extends $pb.GeneratedMessage {
  factory MatrixDocument({
    $core.List<$core.int>? config,
    $fixnum.Int64? revision,
    $fixnum.Int64? masterSession,
    $core.List<$core.int>? masterMac,
    $core.Iterable<MatrixInputNode>? nodes,
    $fixnum.Int64? activeRevision,
    $core.bool? activationPending,
    $core.bool? persisted,
    $core.String? masterFirmwareVersion,
  }) {
    final result = create();
    if (config != null) result.config = config;
    if (revision != null) result.revision = revision;
    if (masterSession != null) result.masterSession = masterSession;
    if (masterMac != null) result.masterMac = masterMac;
    if (nodes != null) result.nodes.addAll(nodes);
    if (activeRevision != null) result.activeRevision = activeRevision;
    if (activationPending != null) result.activationPending = activationPending;
    if (persisted != null) result.persisted = persisted;
    if (masterFirmwareVersion != null)
      result.masterFirmwareVersion = masterFirmwareVersion;
    return result;
  }

  MatrixDocument._();

  factory MatrixDocument.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MatrixDocument.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MatrixDocument',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'config', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'revision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'masterSession', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'masterMac', $pb.PbFieldType.OY)
    ..pPM<MatrixInputNode>(5, _omitFieldNames ? '' : 'nodes',
        subBuilder: MatrixInputNode.create)
    ..a<$fixnum.Int64>(
        6, _omitFieldNames ? '' : 'activeRevision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(7, _omitFieldNames ? '' : 'activationPending')
    ..aOB(8, _omitFieldNames ? '' : 'persisted')
    ..aOS(9, _omitFieldNames ? '' : 'masterFirmwareVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixDocument clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixDocument copyWith(void Function(MatrixDocument) updates) =>
      super.copyWith((message) => updates(message as MatrixDocument))
          as MatrixDocument;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatrixDocument create() => MatrixDocument._();
  @$core.override
  MatrixDocument createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MatrixDocument getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MatrixDocument>(create);
  static MatrixDocument? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get config => $_getN(0);
  @$pb.TagNumber(1)
  set config($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConfig() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfig() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get revision => $_getI64(1);
  @$pb.TagNumber(2)
  set revision($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRevision() => $_has(1);
  @$pb.TagNumber(2)
  void clearRevision() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get masterSession => $_getI64(2);
  @$pb.TagNumber(3)
  set masterSession($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMasterSession() => $_has(2);
  @$pb.TagNumber(3)
  void clearMasterSession() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get masterMac => $_getN(3);
  @$pb.TagNumber(4)
  set masterMac($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMasterMac() => $_has(3);
  @$pb.TagNumber(4)
  void clearMasterMac() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<MatrixInputNode> get nodes => $_getList(4);

  @$pb.TagNumber(6)
  $fixnum.Int64 get activeRevision => $_getI64(5);
  @$pb.TagNumber(6)
  set activeRevision($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasActiveRevision() => $_has(5);
  @$pb.TagNumber(6)
  void clearActiveRevision() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get activationPending => $_getBF(6);
  @$pb.TagNumber(7)
  set activationPending($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasActivationPending() => $_has(6);
  @$pb.TagNumber(7)
  void clearActivationPending() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get persisted => $_getBF(7);
  @$pb.TagNumber(8)
  set persisted($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPersisted() => $_has(7);
  @$pb.TagNumber(8)
  void clearPersisted() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get masterFirmwareVersion => $_getSZ(8);
  @$pb.TagNumber(9)
  set masterFirmwareVersion($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMasterFirmwareVersion() => $_has(8);
  @$pb.TagNumber(9)
  void clearMasterFirmwareVersion() => $_clearField(9);
}

class LayoutOutput extends $pb.GeneratedMessage {
  factory LayoutOutput({
    $core.List<$core.int>? nodeMac,
    MatrixDriver? driver,
    $core.int? pixelCount,
    $core.bool? online,
    $core.bool? ready,
    $core.bool? known,
    MatrixDriverKind? driverKind,
    $core.int? sourceIndex,
    $core.int? maxPixelCount,
  }) {
    final result = create();
    if (nodeMac != null) result.nodeMac = nodeMac;
    if (driver != null) result.driver = driver;
    if (pixelCount != null) result.pixelCount = pixelCount;
    if (online != null) result.online = online;
    if (ready != null) result.ready = ready;
    if (known != null) result.known = known;
    if (driverKind != null) result.driverKind = driverKind;
    if (sourceIndex != null) result.sourceIndex = sourceIndex;
    if (maxPixelCount != null) result.maxPixelCount = maxPixelCount;
    return result;
  }

  LayoutOutput._();

  factory LayoutOutput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LayoutOutput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LayoutOutput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'nodeMac', $pb.PbFieldType.OY)
    ..aE<MatrixDriver>(2, _omitFieldNames ? '' : 'driver',
        enumValues: MatrixDriver.values)
    ..aI(3, _omitFieldNames ? '' : 'pixelCount', fieldType: $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'online')
    ..aOB(5, _omitFieldNames ? '' : 'ready')
    ..aOB(6, _omitFieldNames ? '' : 'known')
    ..aE<MatrixDriverKind>(7, _omitFieldNames ? '' : 'driverKind',
        enumValues: MatrixDriverKind.values)
    ..aI(8, _omitFieldNames ? '' : 'sourceIndex',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(9, _omitFieldNames ? '' : 'maxPixelCount',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LayoutOutput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LayoutOutput copyWith(void Function(LayoutOutput) updates) =>
      super.copyWith((message) => updates(message as LayoutOutput))
          as LayoutOutput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LayoutOutput create() => LayoutOutput._();
  @$core.override
  LayoutOutput createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LayoutOutput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LayoutOutput>(create);
  static LayoutOutput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get nodeMac => $_getN(0);
  @$pb.TagNumber(1)
  set nodeMac($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeMac() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeMac() => $_clearField(1);

  @$pb.TagNumber(2)
  MatrixDriver get driver => $_getN(1);
  @$pb.TagNumber(2)
  set driver(MatrixDriver value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDriver() => $_has(1);
  @$pb.TagNumber(2)
  void clearDriver() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get pixelCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set pixelCount($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPixelCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearPixelCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get online => $_getBF(3);
  @$pb.TagNumber(4)
  set online($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOnline() => $_has(3);
  @$pb.TagNumber(4)
  void clearOnline() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get ready => $_getBF(4);
  @$pb.TagNumber(5)
  set ready($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReady() => $_has(4);
  @$pb.TagNumber(5)
  void clearReady() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get known => $_getBF(5);
  @$pb.TagNumber(6)
  set known($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasKnown() => $_has(5);
  @$pb.TagNumber(6)
  void clearKnown() => $_clearField(6);

  @$pb.TagNumber(7)
  MatrixDriverKind get driverKind => $_getN(6);
  @$pb.TagNumber(7)
  set driverKind(MatrixDriverKind value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasDriverKind() => $_has(6);
  @$pb.TagNumber(7)
  void clearDriverKind() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get sourceIndex => $_getIZ(7);
  @$pb.TagNumber(8)
  set sourceIndex($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSourceIndex() => $_has(7);
  @$pb.TagNumber(8)
  void clearSourceIndex() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get maxPixelCount => $_getIZ(8);
  @$pb.TagNumber(9)
  set maxPixelCount($core.int value) => $_setUnsignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMaxPixelCount() => $_has(8);
  @$pb.TagNumber(9)
  void clearMaxPixelCount() => $_clearField(9);
}

class LayoutSnapshot extends $pb.GeneratedMessage {
  factory LayoutSnapshot({
    $fixnum.Int64? masterSession,
    $fixnum.Int64? revision,
    $core.Iterable<MatrixLayout>? layout,
    $core.Iterable<LayoutOutput>? outputs,
    $core.int? pendingNodes,
    $core.List<$core.int>? masterMac,
    $core.int? centerIndex,
  }) {
    final result = create();
    if (masterSession != null) result.masterSession = masterSession;
    if (revision != null) result.revision = revision;
    if (layout != null) result.layout.addAll(layout);
    if (outputs != null) result.outputs.addAll(outputs);
    if (pendingNodes != null) result.pendingNodes = pendingNodes;
    if (masterMac != null) result.masterMac = masterMac;
    if (centerIndex != null) result.centerIndex = centerIndex;
    return result;
  }

  LayoutSnapshot._();

  factory LayoutSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LayoutSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LayoutSnapshot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'masterSession', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'revision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..pPM<MatrixLayout>(3, _omitFieldNames ? '' : 'layout',
        subBuilder: MatrixLayout.create)
    ..pPM<LayoutOutput>(4, _omitFieldNames ? '' : 'outputs',
        subBuilder: LayoutOutput.create)
    ..aI(5, _omitFieldNames ? '' : 'pendingNodes',
        fieldType: $pb.PbFieldType.OU3)
    ..a<$core.List<$core.int>>(
        6, _omitFieldNames ? '' : 'masterMac', $pb.PbFieldType.OY)
    ..aI(7, _omitFieldNames ? '' : 'centerIndex',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LayoutSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LayoutSnapshot copyWith(void Function(LayoutSnapshot) updates) =>
      super.copyWith((message) => updates(message as LayoutSnapshot))
          as LayoutSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LayoutSnapshot create() => LayoutSnapshot._();
  @$core.override
  LayoutSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LayoutSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LayoutSnapshot>(create);
  static LayoutSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get masterSession => $_getI64(0);
  @$pb.TagNumber(1)
  set masterSession($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMasterSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearMasterSession() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get revision => $_getI64(1);
  @$pb.TagNumber(2)
  set revision($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRevision() => $_has(1);
  @$pb.TagNumber(2)
  void clearRevision() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<MatrixLayout> get layout => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<LayoutOutput> get outputs => $_getList(3);

  @$pb.TagNumber(5)
  $core.int get pendingNodes => $_getIZ(4);
  @$pb.TagNumber(5)
  set pendingNodes($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPendingNodes() => $_has(4);
  @$pb.TagNumber(5)
  void clearPendingNodes() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get masterMac => $_getN(5);
  @$pb.TagNumber(6)
  set masterMac($core.List<$core.int> value) => $_setBytes(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMasterMac() => $_has(5);
  @$pb.TagNumber(6)
  void clearMasterMac() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get centerIndex => $_getIZ(6);
  @$pb.TagNumber(7)
  set centerIndex($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCenterIndex() => $_has(6);
  @$pb.TagNumber(7)
  void clearCenterIndex() => $_clearField(7);
}

class LayoutRequest extends $pb.GeneratedMessage {
  factory LayoutRequest({
    $core.int? requestId,
    LayoutRequest_Operation? operation,
    $core.int? snapshotId,
    $core.int? offset,
    $core.int? outputIndex,
    $core.int? identifyOptions,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (operation != null) result.operation = operation;
    if (snapshotId != null) result.snapshotId = snapshotId;
    if (offset != null) result.offset = offset;
    if (outputIndex != null) result.outputIndex = outputIndex;
    if (identifyOptions != null) result.identifyOptions = identifyOptions;
    return result;
  }

  LayoutRequest._();

  factory LayoutRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LayoutRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LayoutRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'requestId', fieldType: $pb.PbFieldType.OU3)
    ..aE<LayoutRequest_Operation>(2, _omitFieldNames ? '' : 'operation',
        enumValues: LayoutRequest_Operation.values)
    ..aI(3, _omitFieldNames ? '' : 'snapshotId', fieldType: $pb.PbFieldType.OF3)
    ..aI(4, _omitFieldNames ? '' : 'offset', fieldType: $pb.PbFieldType.OU3)
    ..aI(5, _omitFieldNames ? '' : 'outputIndex',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(6, _omitFieldNames ? '' : 'identifyOptions',
        fieldType: $pb.PbFieldType.OF3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LayoutRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LayoutRequest copyWith(void Function(LayoutRequest) updates) =>
      super.copyWith((message) => updates(message as LayoutRequest))
          as LayoutRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LayoutRequest create() => LayoutRequest._();
  @$core.override
  LayoutRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LayoutRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LayoutRequest>(create);
  static LayoutRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get requestId => $_getIZ(0);
  @$pb.TagNumber(1)
  set requestId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  LayoutRequest_Operation get operation => $_getN(1);
  @$pb.TagNumber(2)
  set operation(LayoutRequest_Operation value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasOperation() => $_has(1);
  @$pb.TagNumber(2)
  void clearOperation() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get snapshotId => $_getIZ(2);
  @$pb.TagNumber(3)
  set snapshotId($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSnapshotId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSnapshotId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get offset => $_getIZ(3);
  @$pb.TagNumber(4)
  set offset($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOffset() => $_has(3);
  @$pb.TagNumber(4)
  void clearOffset() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get outputIndex => $_getIZ(4);
  @$pb.TagNumber(5)
  set outputIndex($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOutputIndex() => $_has(4);
  @$pb.TagNumber(5)
  void clearOutputIndex() => $_clearField(5);

  /// MTU-23 identify preview: inventory output index in bits 0..7, LED count in 8..19
  /// (zero uses current capacity), reversed in bit 20, whole node in bit 21;
  /// remaining bits reserved. Whole-node identification uses zero length/direction.
  @$pb.TagNumber(6)
  $core.int get identifyOptions => $_getIZ(5);
  @$pb.TagNumber(6)
  set identifyOptions($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIdentifyOptions() => $_has(5);
  @$pb.TagNumber(6)
  void clearIdentifyOptions() => $_clearField(6);
}

class LayoutResponse extends $pb.GeneratedMessage {
  factory LayoutResponse({
    $core.int? requestId,
    $core.String? error,
    $core.int? snapshotId,
    $core.int? totalSize,
    $core.int? offset,
    $core.List<$core.int>? data,
    $core.bool? complete,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (error != null) result.error = error;
    if (snapshotId != null) result.snapshotId = snapshotId;
    if (totalSize != null) result.totalSize = totalSize;
    if (offset != null) result.offset = offset;
    if (data != null) result.data = data;
    if (complete != null) result.complete = complete;
    return result;
  }

  LayoutResponse._();

  factory LayoutResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LayoutResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LayoutResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'requestId', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'error')
    ..aI(3, _omitFieldNames ? '' : 'snapshotId', fieldType: $pb.PbFieldType.OF3)
    ..aI(4, _omitFieldNames ? '' : 'totalSize', fieldType: $pb.PbFieldType.OU3)
    ..aI(5, _omitFieldNames ? '' : 'offset', fieldType: $pb.PbFieldType.OU3)
    ..a<$core.List<$core.int>>(
        6, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..aOB(7, _omitFieldNames ? '' : 'complete')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LayoutResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LayoutResponse copyWith(void Function(LayoutResponse) updates) =>
      super.copyWith((message) => updates(message as LayoutResponse))
          as LayoutResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LayoutResponse create() => LayoutResponse._();
  @$core.override
  LayoutResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LayoutResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LayoutResponse>(create);
  static LayoutResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get requestId => $_getIZ(0);
  @$pb.TagNumber(1)
  set requestId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get error => $_getSZ(1);
  @$pb.TagNumber(2)
  set error($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get snapshotId => $_getIZ(2);
  @$pb.TagNumber(3)
  set snapshotId($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSnapshotId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSnapshotId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get totalSize => $_getIZ(3);
  @$pb.TagNumber(4)
  set totalSize($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTotalSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalSize() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get offset => $_getIZ(4);
  @$pb.TagNumber(5)
  set offset($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOffset() => $_has(4);
  @$pb.TagNumber(5)
  void clearOffset() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get data => $_getN(5);
  @$pb.TagNumber(6)
  set data($core.List<$core.int> value) => $_setBytes(5, value);
  @$pb.TagNumber(6)
  $core.bool hasData() => $_has(5);
  @$pb.TagNumber(6)
  void clearData() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get complete => $_getBF(6);
  @$pb.TagNumber(7)
  set complete($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasComplete() => $_has(6);
  @$pb.TagNumber(7)
  void clearComplete() => $_clearField(7);
}

class MatrixNodeStatus extends $pb.GeneratedMessage {
  factory MatrixNodeStatus({
    $core.List<$core.int>? nodeMac,
    MatrixNodeStatus_State? state,
  }) {
    final result = create();
    if (nodeMac != null) result.nodeMac = nodeMac;
    if (state != null) result.state = state;
    return result;
  }

  MatrixNodeStatus._();

  factory MatrixNodeStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MatrixNodeStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MatrixNodeStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'nodeMac', $pb.PbFieldType.OY)
    ..aE<MatrixNodeStatus_State>(2, _omitFieldNames ? '' : 'state',
        enumValues: MatrixNodeStatus_State.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixNodeStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixNodeStatus copyWith(void Function(MatrixNodeStatus) updates) =>
      super.copyWith((message) => updates(message as MatrixNodeStatus))
          as MatrixNodeStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatrixNodeStatus create() => MatrixNodeStatus._();
  @$core.override
  MatrixNodeStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MatrixNodeStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MatrixNodeStatus>(create);
  static MatrixNodeStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get nodeMac => $_getN(0);
  @$pb.TagNumber(1)
  set nodeMac($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNodeMac() => $_has(0);
  @$pb.TagNumber(1)
  void clearNodeMac() => $_clearField(1);

  @$pb.TagNumber(2)
  MatrixNodeStatus_State get state => $_getN(1);
  @$pb.TagNumber(2)
  set state(MatrixNodeStatus_State value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasState() => $_has(1);
  @$pb.TagNumber(2)
  void clearState() => $_clearField(2);
}

class MatrixStatus extends $pb.GeneratedMessage {
  factory MatrixStatus({
    $core.int? transferId,
    MatrixStatus_Stage? stage,
    $core.int? receivedBytes,
    $fixnum.Int64? revision,
    $fixnum.Int64? masterSession,
    $core.String? error,
    $core.Iterable<MatrixNodeStatus>? nodes,
    $core.List<$core.int>? masterMac,
  }) {
    final result = create();
    if (transferId != null) result.transferId = transferId;
    if (stage != null) result.stage = stage;
    if (receivedBytes != null) result.receivedBytes = receivedBytes;
    if (revision != null) result.revision = revision;
    if (masterSession != null) result.masterSession = masterSession;
    if (error != null) result.error = error;
    if (nodes != null) result.nodes.addAll(nodes);
    if (masterMac != null) result.masterMac = masterMac;
    return result;
  }

  MatrixStatus._();

  factory MatrixStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MatrixStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MatrixStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'transferId', fieldType: $pb.PbFieldType.OF3)
    ..aE<MatrixStatus_Stage>(2, _omitFieldNames ? '' : 'stage',
        enumValues: MatrixStatus_Stage.values)
    ..aI(3, _omitFieldNames ? '' : 'receivedBytes',
        fieldType: $pb.PbFieldType.OU3)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'revision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'masterSession', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(6, _omitFieldNames ? '' : 'error')
    ..pPM<MatrixNodeStatus>(7, _omitFieldNames ? '' : 'nodes',
        subBuilder: MatrixNodeStatus.create)
    ..a<$core.List<$core.int>>(
        8, _omitFieldNames ? '' : 'masterMac', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MatrixStatus copyWith(void Function(MatrixStatus) updates) =>
      super.copyWith((message) => updates(message as MatrixStatus))
          as MatrixStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatrixStatus create() => MatrixStatus._();
  @$core.override
  MatrixStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MatrixStatus getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MatrixStatus>(create);
  static MatrixStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get transferId => $_getIZ(0);
  @$pb.TagNumber(1)
  set transferId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTransferId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransferId() => $_clearField(1);

  @$pb.TagNumber(2)
  MatrixStatus_Stage get stage => $_getN(1);
  @$pb.TagNumber(2)
  set stage(MatrixStatus_Stage value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStage() => $_has(1);
  @$pb.TagNumber(2)
  void clearStage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get receivedBytes => $_getIZ(2);
  @$pb.TagNumber(3)
  set receivedBytes($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReceivedBytes() => $_has(2);
  @$pb.TagNumber(3)
  void clearReceivedBytes() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get revision => $_getI64(3);
  @$pb.TagNumber(4)
  set revision($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRevision() => $_has(3);
  @$pb.TagNumber(4)
  void clearRevision() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get masterSession => $_getI64(4);
  @$pb.TagNumber(5)
  set masterSession($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMasterSession() => $_has(4);
  @$pb.TagNumber(5)
  void clearMasterSession() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get error => $_getSZ(5);
  @$pb.TagNumber(6)
  set error($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasError() => $_has(5);
  @$pb.TagNumber(6)
  void clearError() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<MatrixNodeStatus> get nodes => $_getList(6);

  @$pb.TagNumber(8)
  $core.List<$core.int> get masterMac => $_getN(7);
  @$pb.TagNumber(8)
  set masterMac($core.List<$core.int> value) => $_setBytes(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMasterMac() => $_has(7);
  @$pb.TagNumber(8)
  void clearMasterMac() => $_clearField(8);
}

/// Slaves receive renderable layers and input pins, never trigger/condition rules.
class AnimationLayer extends $pb.GeneratedMessage {
  factory AnimationLayer({
    $core.int? entryId,
    MatrixEffect? effect,
    $core.int? priority,
    $core.int? order,
    $core.bool? opaqueBackground,
  }) {
    final result = create();
    if (entryId != null) result.entryId = entryId;
    if (effect != null) result.effect = effect;
    if (priority != null) result.priority = priority;
    if (order != null) result.order = order;
    if (opaqueBackground != null) result.opaqueBackground = opaqueBackground;
    return result;
  }

  AnimationLayer._();

  factory AnimationLayer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AnimationLayer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AnimationLayer',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'entryId', fieldType: $pb.PbFieldType.OU3)
    ..aOM<MatrixEffect>(2, _omitFieldNames ? '' : 'effect',
        subBuilder: MatrixEffect.create)
    ..aI(4, _omitFieldNames ? '' : 'priority', fieldType: $pb.PbFieldType.OU3)
    ..aI(5, _omitFieldNames ? '' : 'order', fieldType: $pb.PbFieldType.OU3)
    ..aOB(6, _omitFieldNames ? '' : 'opaqueBackground')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnimationLayer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnimationLayer copyWith(void Function(AnimationLayer) updates) =>
      super.copyWith((message) => updates(message as AnimationLayer))
          as AnimationLayer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnimationLayer create() => AnimationLayer._();
  @$core.override
  AnimationLayer createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AnimationLayer getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AnimationLayer>(create);
  static AnimationLayer? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get entryId => $_getIZ(0);
  @$pb.TagNumber(1)
  set entryId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEntryId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntryId() => $_clearField(1);

  @$pb.TagNumber(2)
  MatrixEffect get effect => $_getN(1);
  @$pb.TagNumber(2)
  set effect(MatrixEffect value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasEffect() => $_has(1);
  @$pb.TagNumber(2)
  void clearEffect() => $_clearField(2);
  @$pb.TagNumber(2)
  MatrixEffect ensureEffect() => $_ensure(1);

  @$pb.TagNumber(4)
  $core.int get priority => $_getIZ(2);
  @$pb.TagNumber(4)
  set priority($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(4)
  $core.bool hasPriority() => $_has(2);
  @$pb.TagNumber(4)
  void clearPriority() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get order => $_getIZ(3);
  @$pb.TagNumber(5)
  set order($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(5)
  $core.bool hasOrder() => $_has(3);
  @$pb.TagNumber(5)
  void clearOrder() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get opaqueBackground => $_getBF(4);
  @$pb.TagNumber(6)
  set opaqueBackground($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(6)
  $core.bool hasOpaqueBackground() => $_has(4);
  @$pb.TagNumber(6)
  void clearOpaqueBackground() => $_clearField(6);
}

class AnimationPreview extends $pb.GeneratedMessage {
  factory AnimationPreview({
    $fixnum.Int64? masterSession,
    $fixnum.Int64? revision,
    $fixnum.Int64? startAtUs,
    $fixnum.Int64? endAtUs,
    MatrixEffect? effect,
  }) {
    final result = create();
    if (masterSession != null) result.masterSession = masterSession;
    if (revision != null) result.revision = revision;
    if (startAtUs != null) result.startAtUs = startAtUs;
    if (endAtUs != null) result.endAtUs = endAtUs;
    if (effect != null) result.effect = effect;
    return result;
  }

  AnimationPreview._();

  factory AnimationPreview.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AnimationPreview.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AnimationPreview',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'masterSession', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'revision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'startAtUs', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'endAtUs', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<MatrixEffect>(5, _omitFieldNames ? '' : 'effect',
        subBuilder: MatrixEffect.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnimationPreview clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnimationPreview copyWith(void Function(AnimationPreview) updates) =>
      super.copyWith((message) => updates(message as AnimationPreview))
          as AnimationPreview;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnimationPreview create() => AnimationPreview._();
  @$core.override
  AnimationPreview createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AnimationPreview getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AnimationPreview>(create);
  static AnimationPreview? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get masterSession => $_getI64(0);
  @$pb.TagNumber(1)
  set masterSession($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMasterSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearMasterSession() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get revision => $_getI64(1);
  @$pb.TagNumber(2)
  set revision($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRevision() => $_has(1);
  @$pb.TagNumber(2)
  void clearRevision() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get startAtUs => $_getI64(2);
  @$pb.TagNumber(3)
  set startAtUs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStartAtUs() => $_has(2);
  @$pb.TagNumber(3)
  void clearStartAtUs() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get endAtUs => $_getI64(3);
  @$pb.TagNumber(4)
  set endAtUs($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEndAtUs() => $_has(3);
  @$pb.TagNumber(4)
  void clearEndAtUs() => $_clearField(4);

  @$pb.TagNumber(5)
  MatrixEffect get effect => $_getN(4);
  @$pb.TagNumber(5)
  set effect(MatrixEffect value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasEffect() => $_has(4);
  @$pb.TagNumber(5)
  void clearEffect() => $_clearField(5);
  @$pb.TagNumber(5)
  MatrixEffect ensureEffect() => $_ensure(4);
}

class AnimationOutputMapping extends $pb.GeneratedMessage {
  factory AnimationOutputMapping({
    MatrixDriver? driver,
    $core.int? from,
    $core.int? to,
    $core.int? sourceIndex,
  }) {
    final result = create();
    if (driver != null) result.driver = driver;
    if (from != null) result.from = from;
    if (to != null) result.to = to;
    if (sourceIndex != null) result.sourceIndex = sourceIndex;
    return result;
  }

  AnimationOutputMapping._();

  factory AnimationOutputMapping.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AnimationOutputMapping.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AnimationOutputMapping',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..aE<MatrixDriver>(1, _omitFieldNames ? '' : 'driver',
        enumValues: MatrixDriver.values)
    ..aI(2, _omitFieldNames ? '' : 'from', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'to', fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'sourceIndex',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnimationOutputMapping clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnimationOutputMapping copyWith(
          void Function(AnimationOutputMapping) updates) =>
      super.copyWith((message) => updates(message as AnimationOutputMapping))
          as AnimationOutputMapping;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnimationOutputMapping create() => AnimationOutputMapping._();
  @$core.override
  AnimationOutputMapping createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AnimationOutputMapping getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AnimationOutputMapping>(create);
  static AnimationOutputMapping? _defaultInstance;

  @$pb.TagNumber(1)
  MatrixDriver get driver => $_getN(0);
  @$pb.TagNumber(1)
  set driver(MatrixDriver value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDriver() => $_has(0);
  @$pb.TagNumber(1)
  void clearDriver() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get from => $_getIZ(1);
  @$pb.TagNumber(2)
  set from($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFrom() => $_has(1);
  @$pb.TagNumber(2)
  void clearFrom() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get to => $_getIZ(2);
  @$pb.TagNumber(3)
  set to($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTo() => $_has(2);
  @$pb.TagNumber(3)
  void clearTo() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get sourceIndex => $_getIZ(3);
  @$pb.TagNumber(4)
  set sourceIndex($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSourceIndex() => $_has(3);
  @$pb.TagNumber(4)
  void clearSourceIndex() => $_clearField(4);
}

class AnimationDefinitions extends $pb.GeneratedMessage {
  factory AnimationDefinitions({
    $core.int? schemaVersion,
    $fixnum.Int64? masterSession,
    $fixnum.Int64? revision,
    $core.Iterable<AnimationLayer>? layers,
    $core.Iterable<$core.int>? gpioInputs,
    $core.int? canvasSize,
    $core.Iterable<AnimationOutputMapping>? outputMappings,
    $core.int? centerIndex,
  }) {
    final result = create();
    if (schemaVersion != null) result.schemaVersion = schemaVersion;
    if (masterSession != null) result.masterSession = masterSession;
    if (revision != null) result.revision = revision;
    if (layers != null) result.layers.addAll(layers);
    if (gpioInputs != null) result.gpioInputs.addAll(gpioInputs);
    if (canvasSize != null) result.canvasSize = canvasSize;
    if (outputMappings != null) result.outputMappings.addAll(outputMappings);
    if (centerIndex != null) result.centerIndex = centerIndex;
    return result;
  }

  AnimationDefinitions._();

  factory AnimationDefinitions.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AnimationDefinitions.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AnimationDefinitions',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'schemaVersion',
        fieldType: $pb.PbFieldType.OU3)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'masterSession', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'revision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..pPM<AnimationLayer>(4, _omitFieldNames ? '' : 'layers',
        subBuilder: AnimationLayer.create)
    ..p<$core.int>(5, _omitFieldNames ? '' : 'gpioInputs', $pb.PbFieldType.KU3)
    ..aI(6, _omitFieldNames ? '' : 'canvasSize', fieldType: $pb.PbFieldType.OU3)
    ..pPM<AnimationOutputMapping>(7, _omitFieldNames ? '' : 'outputMappings',
        subBuilder: AnimationOutputMapping.create)
    ..aI(8, _omitFieldNames ? '' : 'centerIndex',
        fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnimationDefinitions clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnimationDefinitions copyWith(void Function(AnimationDefinitions) updates) =>
      super.copyWith((message) => updates(message as AnimationDefinitions))
          as AnimationDefinitions;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnimationDefinitions create() => AnimationDefinitions._();
  @$core.override
  AnimationDefinitions createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AnimationDefinitions getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AnimationDefinitions>(create);
  static AnimationDefinitions? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get schemaVersion => $_getIZ(0);
  @$pb.TagNumber(1)
  set schemaVersion($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSchemaVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearSchemaVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get masterSession => $_getI64(1);
  @$pb.TagNumber(2)
  set masterSession($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMasterSession() => $_has(1);
  @$pb.TagNumber(2)
  void clearMasterSession() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get revision => $_getI64(2);
  @$pb.TagNumber(3)
  set revision($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRevision() => $_has(2);
  @$pb.TagNumber(3)
  void clearRevision() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<AnimationLayer> get layers => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$core.int> get gpioInputs => $_getList(4);

  @$pb.TagNumber(6)
  $core.int get canvasSize => $_getIZ(5);
  @$pb.TagNumber(6)
  set canvasSize($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCanvasSize() => $_has(5);
  @$pb.TagNumber(6)
  void clearCanvasSize() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<AnimationOutputMapping> get outputMappings => $_getList(6);

  @$pb.TagNumber(8)
  $core.int get centerIndex => $_getIZ(7);
  @$pb.TagNumber(8)
  set centerIndex($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCenterIndex() => $_has(7);
  @$pb.TagNumber(8)
  void clearCenterIndex() => $_clearField(8);
}

class AnimationCommand extends $pb.GeneratedMessage {
  factory AnimationCommand({
    $fixnum.Int64? masterSession,
    $fixnum.Int64? revision,
    $core.int? sequence,
    $core.int? entryId,
    $fixnum.Int64? effectiveAtUs,
    $core.bool? stop,
  }) {
    final result = create();
    if (masterSession != null) result.masterSession = masterSession;
    if (revision != null) result.revision = revision;
    if (sequence != null) result.sequence = sequence;
    if (entryId != null) result.entryId = entryId;
    if (effectiveAtUs != null) result.effectiveAtUs = effectiveAtUs;
    if (stop != null) result.stop = stop;
    return result;
  }

  AnimationCommand._();

  factory AnimationCommand.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AnimationCommand.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AnimationCommand',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'masterSession', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'revision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(3, _omitFieldNames ? '' : 'sequence', fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'entryId', fieldType: $pb.PbFieldType.OU3)
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'effectiveAtUs', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(6, _omitFieldNames ? '' : 'stop')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnimationCommand clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnimationCommand copyWith(void Function(AnimationCommand) updates) =>
      super.copyWith((message) => updates(message as AnimationCommand))
          as AnimationCommand;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnimationCommand create() => AnimationCommand._();
  @$core.override
  AnimationCommand createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AnimationCommand getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AnimationCommand>(create);
  static AnimationCommand? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get masterSession => $_getI64(0);
  @$pb.TagNumber(1)
  set masterSession($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMasterSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearMasterSession() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get revision => $_getI64(1);
  @$pb.TagNumber(2)
  set revision($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRevision() => $_has(1);
  @$pb.TagNumber(2)
  void clearRevision() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get sequence => $_getIZ(2);
  @$pb.TagNumber(3)
  set sequence($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSequence() => $_has(2);
  @$pb.TagNumber(3)
  void clearSequence() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get entryId => $_getIZ(3);
  @$pb.TagNumber(4)
  set entryId($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEntryId() => $_has(3);
  @$pb.TagNumber(4)
  void clearEntryId() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get effectiveAtUs => $_getI64(4);
  @$pb.TagNumber(5)
  set effectiveAtUs($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEffectiveAtUs() => $_has(4);
  @$pb.TagNumber(5)
  void clearEffectiveAtUs() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get stop => $_getBF(5);
  @$pb.TagNumber(6)
  set stop($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStop() => $_has(5);
  @$pb.TagNumber(6)
  void clearStop() => $_clearField(6);
}

class AnimationState extends $pb.GeneratedMessage {
  factory AnimationState({
    $core.int? entryId,
    $fixnum.Int64? startedAtUs,
    $core.bool? active,
  }) {
    final result = create();
    if (entryId != null) result.entryId = entryId;
    if (startedAtUs != null) result.startedAtUs = startedAtUs;
    if (active != null) result.active = active;
    return result;
  }

  AnimationState._();

  factory AnimationState.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AnimationState.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AnimationState',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'entryId', fieldType: $pb.PbFieldType.OU3)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'startedAtUs', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOB(3, _omitFieldNames ? '' : 'active')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnimationState clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnimationState copyWith(void Function(AnimationState) updates) =>
      super.copyWith((message) => updates(message as AnimationState))
          as AnimationState;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnimationState create() => AnimationState._();
  @$core.override
  AnimationState createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AnimationState getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AnimationState>(create);
  static AnimationState? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get entryId => $_getIZ(0);
  @$pb.TagNumber(1)
  set entryId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEntryId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntryId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get startedAtUs => $_getI64(1);
  @$pb.TagNumber(2)
  set startedAtUs($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartedAtUs() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartedAtUs() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get active => $_getBF(2);
  @$pb.TagNumber(3)
  set active($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasActive() => $_has(2);
  @$pb.TagNumber(3)
  void clearActive() => $_clearField(3);
}

class AnimationSnapshot extends $pb.GeneratedMessage {
  factory AnimationSnapshot({
    $fixnum.Int64? masterSession,
    $fixnum.Int64? revision,
    $core.int? sequence,
    $fixnum.Int64? activateAtUs,
    $core.Iterable<AnimationState>? states,
    $core.Iterable<AnimationCommand>? pending,
  }) {
    final result = create();
    if (masterSession != null) result.masterSession = masterSession;
    if (revision != null) result.revision = revision;
    if (sequence != null) result.sequence = sequence;
    if (activateAtUs != null) result.activateAtUs = activateAtUs;
    if (states != null) result.states.addAll(states);
    if (pending != null) result.pending.addAll(pending);
    return result;
  }

  AnimationSnapshot._();

  factory AnimationSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AnimationSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AnimationSnapshot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mesh_interop'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'masterSession', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'revision', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(3, _omitFieldNames ? '' : 'sequence', fieldType: $pb.PbFieldType.OU3)
    ..a<$fixnum.Int64>(
        4, _omitFieldNames ? '' : 'activateAtUs', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..pPM<AnimationState>(5, _omitFieldNames ? '' : 'states',
        subBuilder: AnimationState.create)
    ..pPM<AnimationCommand>(6, _omitFieldNames ? '' : 'pending',
        subBuilder: AnimationCommand.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnimationSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnimationSnapshot copyWith(void Function(AnimationSnapshot) updates) =>
      super.copyWith((message) => updates(message as AnimationSnapshot))
          as AnimationSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnimationSnapshot create() => AnimationSnapshot._();
  @$core.override
  AnimationSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AnimationSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AnimationSnapshot>(create);
  static AnimationSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get masterSession => $_getI64(0);
  @$pb.TagNumber(1)
  set masterSession($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMasterSession() => $_has(0);
  @$pb.TagNumber(1)
  void clearMasterSession() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get revision => $_getI64(1);
  @$pb.TagNumber(2)
  set revision($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRevision() => $_has(1);
  @$pb.TagNumber(2)
  void clearRevision() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get sequence => $_getIZ(2);
  @$pb.TagNumber(3)
  set sequence($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSequence() => $_has(2);
  @$pb.TagNumber(3)
  void clearSequence() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get activateAtUs => $_getI64(3);
  @$pb.TagNumber(4)
  set activateAtUs($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasActivateAtUs() => $_has(3);
  @$pb.TagNumber(4)
  void clearActivateAtUs() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<AnimationState> get states => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<AnimationCommand> get pending => $_getList(5);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
