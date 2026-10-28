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

import 'package:protobuf/protobuf.dart' as $pb;

/// Driver wiring is firmware-owned. IDs are stable across matrix revisions.
class MatrixDriver extends $pb.ProtobufEnum {
  static const MatrixDriver DRIVER_UNSPECIFIED =
      MatrixDriver._(0, _omitEnumNames ? '' : 'DRIVER_UNSPECIFIED');
  static const MatrixDriver WS2812 =
      MatrixDriver._(1, _omitEnumNames ? '' : 'WS2812');
  static const MatrixDriver HC595 =
      MatrixDriver._(2, _omitEnumNames ? '' : 'HC595');

  static const $core.List<MatrixDriver> values = <MatrixDriver>[
    DRIVER_UNSPECIFIED,
    WS2812,
    HC595,
  ];

  static final $core.List<MatrixDriver?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static MatrixDriver? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MatrixDriver._(super.value, super.name);
}

class MatrixEffect_Kind extends $pb.ProtobufEnum {
  static const MatrixEffect_Kind EFFECT_UNSPECIFIED =
      MatrixEffect_Kind._(0, _omitEnumNames ? '' : 'EFFECT_UNSPECIFIED');
  static const MatrixEffect_Kind STATIC_COLOR =
      MatrixEffect_Kind._(1, _omitEnumNames ? '' : 'STATIC_COLOR');

  static const $core.List<MatrixEffect_Kind> values = <MatrixEffect_Kind>[
    EFFECT_UNSPECIFIED,
    STATIC_COLOR,
  ];

  static final $core.List<MatrixEffect_Kind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static MatrixEffect_Kind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MatrixEffect_Kind._(super.value, super.name);
}

class MatrixSource_Kind extends $pb.ProtobufEnum {
  static const MatrixSource_Kind SOURCE_UNSPECIFIED =
      MatrixSource_Kind._(0, _omitEnumNames ? '' : 'SOURCE_UNSPECIFIED');
  static const MatrixSource_Kind DEFAULT_STATE =
      MatrixSource_Kind._(1, _omitEnumNames ? '' : 'DEFAULT_STATE');
  static const MatrixSource_Kind GPIO_EDGE =
      MatrixSource_Kind._(2, _omitEnumNames ? '' : 'GPIO_EDGE');

  static const $core.List<MatrixSource_Kind> values = <MatrixSource_Kind>[
    SOURCE_UNSPECIFIED,
    DEFAULT_STATE,
    GPIO_EDGE,
  ];

  static final $core.List<MatrixSource_Kind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static MatrixSource_Kind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MatrixSource_Kind._(super.value, super.name);
}

class MatrixCondition_Kind extends $pb.ProtobufEnum {
  static const MatrixCondition_Kind CONDITION_UNSPECIFIED =
      MatrixCondition_Kind._(0, _omitEnumNames ? '' : 'CONDITION_UNSPECIFIED');
  static const MatrixCondition_Kind ALWAYS =
      MatrixCondition_Kind._(1, _omitEnumNames ? '' : 'ALWAYS');

  static const $core.List<MatrixCondition_Kind> values = <MatrixCondition_Kind>[
    CONDITION_UNSPECIFIED,
    ALWAYS,
  ];

  static final $core.List<MatrixCondition_Kind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 1);
  static MatrixCondition_Kind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MatrixCondition_Kind._(super.value, super.name);
}

class MatrixNodeStatus_State extends $pb.ProtobufEnum {
  static const MatrixNodeStatus_State UNAVAILABLE =
      MatrixNodeStatus_State._(0, _omitEnumNames ? '' : 'UNAVAILABLE');
  static const MatrixNodeStatus_State PREPARING =
      MatrixNodeStatus_State._(1, _omitEnumNames ? '' : 'PREPARING');
  static const MatrixNodeStatus_State READY =
      MatrixNodeStatus_State._(2, _omitEnumNames ? '' : 'READY');
  static const MatrixNodeStatus_State DEGRADED =
      MatrixNodeStatus_State._(3, _omitEnumNames ? '' : 'DEGRADED');

  static const $core.List<MatrixNodeStatus_State> values =
      <MatrixNodeStatus_State>[
    UNAVAILABLE,
    PREPARING,
    READY,
    DEGRADED,
  ];

  static final $core.List<MatrixNodeStatus_State?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static MatrixNodeStatus_State? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MatrixNodeStatus_State._(super.value, super.name);
}

class MatrixStatus_Stage extends $pb.ProtobufEnum {
  static const MatrixStatus_Stage IDLE =
      MatrixStatus_Stage._(0, _omitEnumNames ? '' : 'IDLE');
  static const MatrixStatus_Stage RECEIVING =
      MatrixStatus_Stage._(1, _omitEnumNames ? '' : 'RECEIVING');
  static const MatrixStatus_Stage VALIDATING =
      MatrixStatus_Stage._(2, _omitEnumNames ? '' : 'VALIDATING');
  static const MatrixStatus_Stage DISTRIBUTING =
      MatrixStatus_Stage._(3, _omitEnumNames ? '' : 'DISTRIBUTING');
  static const MatrixStatus_Stage ACTIVE =
      MatrixStatus_Stage._(4, _omitEnumNames ? '' : 'ACTIVE');
  static const MatrixStatus_Stage FAILED =
      MatrixStatus_Stage._(5, _omitEnumNames ? '' : 'FAILED');

  static const $core.List<MatrixStatus_Stage> values = <MatrixStatus_Stage>[
    IDLE,
    RECEIVING,
    VALIDATING,
    DISTRIBUTING,
    ACTIVE,
    FAILED,
  ];

  static final $core.List<MatrixStatus_Stage?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static MatrixStatus_Stage? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MatrixStatus_Stage._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
