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

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

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

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
