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

/// Physical driver slots. The historical names for slots 1/2 are retained;
/// hardware type is reported independently in LayoutOutput.driver_kind.
class MatrixDriver extends $pb.ProtobufEnum {
  static const MatrixDriver DRIVER_UNSPECIFIED =
      MatrixDriver._(0, _omitEnumNames ? '' : 'DRIVER_UNSPECIFIED');
  static const MatrixDriver DRIVER_1 =
      MatrixDriver._(1, _omitEnumNames ? '' : 'DRIVER_1');
  static const MatrixDriver DRIVER_2 =
      MatrixDriver._(2, _omitEnumNames ? '' : 'DRIVER_2');
  static const MatrixDriver DRIVER_3 =
      MatrixDriver._(3, _omitEnumNames ? '' : 'DRIVER_3');
  static const MatrixDriver DRIVER_4 =
      MatrixDriver._(4, _omitEnumNames ? '' : 'DRIVER_4');
  static const MatrixDriver DRIVER_5 =
      MatrixDriver._(5, _omitEnumNames ? '' : 'DRIVER_5');
  static const MatrixDriver DRIVER_6 =
      MatrixDriver._(6, _omitEnumNames ? '' : 'DRIVER_6');

  static const $core.List<MatrixDriver> values = <MatrixDriver>[
    DRIVER_UNSPECIFIED,
    DRIVER_1,
    DRIVER_2,
    DRIVER_3,
    DRIVER_4,
    DRIVER_5,
    DRIVER_6,
  ];

  static final $core.List<MatrixDriver?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static MatrixDriver? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MatrixDriver._(super.value, super.name);
}

class MatrixDriverKind extends $pb.ProtobufEnum {
  static const MatrixDriverKind KIND_UNSPECIFIED =
      MatrixDriverKind._(0, _omitEnumNames ? '' : 'KIND_UNSPECIFIED');
  static const MatrixDriverKind LED_STRIP =
      MatrixDriverKind._(1, _omitEnumNames ? '' : 'LED_STRIP');
  static const MatrixDriverKind RGB_LED_MODULE =
      MatrixDriverKind._(2, _omitEnumNames ? '' : 'RGB_LED_MODULE');

  static const $core.List<MatrixDriverKind> values = <MatrixDriverKind>[
    KIND_UNSPECIFIED,
    LED_STRIP,
    RGB_LED_MODULE,
  ];

  static final $core.List<MatrixDriverKind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static MatrixDriverKind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MatrixDriverKind._(super.value, super.name);
}

/// Physical locations, ordered continuously from rear left around to rear right.
class CarPosition extends $pb.ProtobufEnum {
  static const CarPosition POSITION_UNSPECIFIED =
      CarPosition._(0, _omitEnumNames ? '' : 'POSITION_UNSPECIFIED');
  static const CarPosition REAR_LEFT_DOOR =
      CarPosition._(1, _omitEnumNames ? '' : 'REAR_LEFT_DOOR');
  static const CarPosition REAR_LEFT_POCKET =
      CarPosition._(2, _omitEnumNames ? '' : 'REAR_LEFT_POCKET');
  static const CarPosition REAR_LEFT_HANDLE =
      CarPosition._(3, _omitEnumNames ? '' : 'REAR_LEFT_HANDLE');
  static const CarPosition REAR_LEFT_FOOTWELL =
      CarPosition._(4, _omitEnumNames ? '' : 'REAR_LEFT_FOOTWELL');
  static const CarPosition FRONT_LEFT_DOOR =
      CarPosition._(5, _omitEnumNames ? '' : 'FRONT_LEFT_DOOR');
  static const CarPosition FRONT_LEFT_POCKET =
      CarPosition._(6, _omitEnumNames ? '' : 'FRONT_LEFT_POCKET');
  static const CarPosition FRONT_LEFT_HANDLE =
      CarPosition._(7, _omitEnumNames ? '' : 'FRONT_LEFT_HANDLE');
  static const CarPosition FRONT_LEFT_FOOTWELL =
      CarPosition._(8, _omitEnumNames ? '' : 'FRONT_LEFT_FOOTWELL');
  static const CarPosition CONSOLE_LEFT =
      CarPosition._(9, _omitEnumNames ? '' : 'CONSOLE_LEFT');
  static const CarPosition DASH_LEFT =
      CarPosition._(10, _omitEnumNames ? '' : 'DASH_LEFT');
  static const CarPosition DASH_RIGHT =
      CarPosition._(11, _omitEnumNames ? '' : 'DASH_RIGHT');
  static const CarPosition CONSOLE_RIGHT =
      CarPosition._(12, _omitEnumNames ? '' : 'CONSOLE_RIGHT');
  static const CarPosition FRONT_RIGHT_FOOTWELL =
      CarPosition._(13, _omitEnumNames ? '' : 'FRONT_RIGHT_FOOTWELL');
  static const CarPosition FRONT_RIGHT_HANDLE =
      CarPosition._(14, _omitEnumNames ? '' : 'FRONT_RIGHT_HANDLE');
  static const CarPosition FRONT_RIGHT_POCKET =
      CarPosition._(15, _omitEnumNames ? '' : 'FRONT_RIGHT_POCKET');
  static const CarPosition FRONT_RIGHT_DOOR =
      CarPosition._(16, _omitEnumNames ? '' : 'FRONT_RIGHT_DOOR');
  static const CarPosition REAR_RIGHT_FOOTWELL =
      CarPosition._(17, _omitEnumNames ? '' : 'REAR_RIGHT_FOOTWELL');
  static const CarPosition REAR_RIGHT_HANDLE =
      CarPosition._(18, _omitEnumNames ? '' : 'REAR_RIGHT_HANDLE');
  static const CarPosition REAR_RIGHT_POCKET =
      CarPosition._(19, _omitEnumNames ? '' : 'REAR_RIGHT_POCKET');
  static const CarPosition REAR_RIGHT_DOOR =
      CarPosition._(20, _omitEnumNames ? '' : 'REAR_RIGHT_DOOR');

  static const $core.List<CarPosition> values = <CarPosition>[
    POSITION_UNSPECIFIED,
    REAR_LEFT_DOOR,
    REAR_LEFT_POCKET,
    REAR_LEFT_HANDLE,
    REAR_LEFT_FOOTWELL,
    FRONT_LEFT_DOOR,
    FRONT_LEFT_POCKET,
    FRONT_LEFT_HANDLE,
    FRONT_LEFT_FOOTWELL,
    CONSOLE_LEFT,
    DASH_LEFT,
    DASH_RIGHT,
    CONSOLE_RIGHT,
    FRONT_RIGHT_FOOTWELL,
    FRONT_RIGHT_HANDLE,
    FRONT_RIGHT_POCKET,
    FRONT_RIGHT_DOOR,
    REAR_RIGHT_FOOTWELL,
    REAR_RIGHT_HANDLE,
    REAR_RIGHT_POCKET,
    REAR_RIGHT_DOOR,
  ];

  static final $core.List<CarPosition?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 20);
  static CarPosition? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CarPosition._(super.value, super.name);
}

class MatrixInterpolation extends $pb.ProtobufEnum {
  static const MatrixInterpolation LINEAR =
      MatrixInterpolation._(0, _omitEnumNames ? '' : 'LINEAR');
  static const MatrixInterpolation STEP =
      MatrixInterpolation._(1, _omitEnumNames ? '' : 'STEP');
  static const MatrixInterpolation SMOOTH =
      MatrixInterpolation._(2, _omitEnumNames ? '' : 'SMOOTH');

  static const $core.List<MatrixInterpolation> values = <MatrixInterpolation>[
    LINEAR,
    STEP,
    SMOOTH,
  ];

  static final $core.List<MatrixInterpolation?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static MatrixInterpolation? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MatrixInterpolation._(super.value, super.name);
}

class SignalGenerator_Kind extends $pb.ProtobufEnum {
  static const SignalGenerator_Kind SIGNAL_UNSPECIFIED =
      SignalGenerator_Kind._(0, _omitEnumNames ? '' : 'SIGNAL_UNSPECIFIED');
  static const SignalGenerator_Kind SINE =
      SignalGenerator_Kind._(1, _omitEnumNames ? '' : 'SINE');
  static const SignalGenerator_Kind TRIANGLE =
      SignalGenerator_Kind._(2, _omitEnumNames ? '' : 'TRIANGLE');
  static const SignalGenerator_Kind SQUARE =
      SignalGenerator_Kind._(3, _omitEnumNames ? '' : 'SQUARE');
  static const SignalGenerator_Kind SAWTOOTH =
      SignalGenerator_Kind._(4, _omitEnumNames ? '' : 'SAWTOOTH');
  static const SignalGenerator_Kind REVERSE_SAWTOOTH =
      SignalGenerator_Kind._(5, _omitEnumNames ? '' : 'REVERSE_SAWTOOTH');
  static const SignalGenerator_Kind SENSOR =
      SignalGenerator_Kind._(6, _omitEnumNames ? '' : 'SENSOR');

  static const $core.List<SignalGenerator_Kind> values = <SignalGenerator_Kind>[
    SIGNAL_UNSPECIFIED,
    SINE,
    TRIANGLE,
    SQUARE,
    SAWTOOTH,
    REVERSE_SAWTOOTH,
    SENSOR,
  ];

  static final $core.List<SignalGenerator_Kind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static SignalGenerator_Kind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SignalGenerator_Kind._(super.value, super.name);
}

class AnimationModulation_Curve extends $pb.ProtobufEnum {
  static const AnimationModulation_Curve LINEAR =
      AnimationModulation_Curve._(0, _omitEnumNames ? '' : 'LINEAR');
  static const AnimationModulation_Curve EASE_IN =
      AnimationModulation_Curve._(1, _omitEnumNames ? '' : 'EASE_IN');
  static const AnimationModulation_Curve EASE_OUT =
      AnimationModulation_Curve._(2, _omitEnumNames ? '' : 'EASE_OUT');
  static const AnimationModulation_Curve SMOOTH =
      AnimationModulation_Curve._(3, _omitEnumNames ? '' : 'SMOOTH');

  static const $core.List<AnimationModulation_Curve> values =
      <AnimationModulation_Curve>[
    LINEAR,
    EASE_IN,
    EASE_OUT,
    SMOOTH,
  ];

  static final $core.List<AnimationModulation_Curve?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static AnimationModulation_Curve? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AnimationModulation_Curve._(super.value, super.name);
}

class MatrixEffect_Kind extends $pb.ProtobufEnum {
  static const MatrixEffect_Kind EFFECT_UNSPECIFIED =
      MatrixEffect_Kind._(0, _omitEnumNames ? '' : 'EFFECT_UNSPECIFIED');
  static const MatrixEffect_Kind STATIC_COLOR =
      MatrixEffect_Kind._(1, _omitEnumNames ? '' : 'STATIC_COLOR');
  static const MatrixEffect_Kind KEYFRAMES =
      MatrixEffect_Kind._(2, _omitEnumNames ? '' : 'KEYFRAMES');
  static const MatrixEffect_Kind BLINK =
      MatrixEffect_Kind._(3, _omitEnumNames ? '' : 'BLINK');
  static const MatrixEffect_Kind BREATHE =
      MatrixEffect_Kind._(4, _omitEnumNames ? '' : 'BREATHE');
  static const MatrixEffect_Kind FLOWING_GRADIENT =
      MatrixEffect_Kind._(5, _omitEnumNames ? '' : 'FLOWING_GRADIENT');
  static const MatrixEffect_Kind RAINBOW =
      MatrixEffect_Kind._(6, _omitEnumNames ? '' : 'RAINBOW');
  static const MatrixEffect_Kind FILL =
      MatrixEffect_Kind._(7, _omitEnumNames ? '' : 'FILL');
  static const MatrixEffect_Kind DIMMING =
      MatrixEffect_Kind._(8, _omitEnumNames ? '' : 'DIMMING');

  static const $core.List<MatrixEffect_Kind> values = <MatrixEffect_Kind>[
    EFFECT_UNSPECIFIED,
    STATIC_COLOR,
    KEYFRAMES,
    BLINK,
    BREATHE,
    FLOWING_GRADIENT,
    RAINBOW,
    FILL,
    DIMMING,
  ];

  static final $core.List<MatrixEffect_Kind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 8);
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
  static const MatrixSource_Kind ON_BOOT =
      MatrixSource_Kind._(3, _omitEnumNames ? '' : 'ON_BOOT');
  static const MatrixSource_Kind ON_MODE_SWITCHED =
      MatrixSource_Kind._(4, _omitEnumNames ? '' : 'ON_MODE_SWITCHED');

  static const $core.List<MatrixSource_Kind> values = <MatrixSource_Kind>[
    SOURCE_UNSPECIFIED,
    DEFAULT_STATE,
    GPIO_EDGE,
    ON_BOOT,
    ON_MODE_SWITCHED,
  ];

  static final $core.List<MatrixSource_Kind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static MatrixSource_Kind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MatrixSource_Kind._(super.value, super.name);
}

class MatrixCondition_Kind extends $pb.ProtobufEnum {
  static const MatrixCondition_Kind CONDITION_UNSPECIFIED =
      MatrixCondition_Kind._(0, _omitEnumNames ? '' : 'CONDITION_UNSPECIFIED');
  static const MatrixCondition_Kind ALWAYS =
      MatrixCondition_Kind._(1, _omitEnumNames ? '' : 'ALWAYS');
  static const MatrixCondition_Kind MODE =
      MatrixCondition_Kind._(2, _omitEnumNames ? '' : 'MODE');
  static const MatrixCondition_Kind AND =
      MatrixCondition_Kind._(3, _omitEnumNames ? '' : 'AND');
  static const MatrixCondition_Kind OR =
      MatrixCondition_Kind._(4, _omitEnumNames ? '' : 'OR');
  static const MatrixCondition_Kind NEVER =
      MatrixCondition_Kind._(5, _omitEnumNames ? '' : 'NEVER');
  static const MatrixCondition_Kind GPIO_STATE =
      MatrixCondition_Kind._(6, _omitEnumNames ? '' : 'GPIO_STATE');

  static const $core.List<MatrixCondition_Kind> values = <MatrixCondition_Kind>[
    CONDITION_UNSPECIFIED,
    ALWAYS,
    MODE,
    AND,
    OR,
    NEVER,
    GPIO_STATE,
  ];

  static final $core.List<MatrixCondition_Kind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static MatrixCondition_Kind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MatrixCondition_Kind._(super.value, super.name);
}

class LayoutRequest_Operation extends $pb.ProtobufEnum {
  static const LayoutRequest_Operation READ =
      LayoutRequest_Operation._(0, _omitEnumNames ? '' : 'READ');
  static const LayoutRequest_Operation IDENTIFY =
      LayoutRequest_Operation._(1, _omitEnumNames ? '' : 'IDENTIFY');
  static const LayoutRequest_Operation READ_MATRIX =
      LayoutRequest_Operation._(2, _omitEnumNames ? '' : 'READ_MATRIX');
  static const LayoutRequest_Operation READ_ACTIVE_MATRIX =
      LayoutRequest_Operation._(3, _omitEnumNames ? '' : 'READ_ACTIVE_MATRIX');
  static const LayoutRequest_Operation PREVIEW =
      LayoutRequest_Operation._(4, _omitEnumNames ? '' : 'PREVIEW');

  static const $core.List<LayoutRequest_Operation> values =
      <LayoutRequest_Operation>[
    READ,
    IDENTIFY,
    READ_MATRIX,
    READ_ACTIVE_MATRIX,
    PREVIEW,
  ];

  static final $core.List<LayoutRequest_Operation?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static LayoutRequest_Operation? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const LayoutRequest_Operation._(super.value, super.name);
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
