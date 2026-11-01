// This is a generated file - do not edit.
//
// Generated from mesh.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use matrixDriverDescriptor instead')
const MatrixDriver$json = {
  '1': 'MatrixDriver',
  '2': [
    {'1': 'DRIVER_UNSPECIFIED', '2': 0},
    {'1': 'WS2812', '2': 1},
    {'1': 'HC595', '2': 2},
    {'1': 'DRIVER_3', '2': 3},
    {'1': 'DRIVER_4', '2': 4},
    {'1': 'DRIVER_5', '2': 5},
    {'1': 'DRIVER_6', '2': 6},
  ],
};

/// Descriptor for `MatrixDriver`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List matrixDriverDescriptor = $convert.base64Decode(
    'CgxNYXRyaXhEcml2ZXISFgoSRFJJVkVSX1VOU1BFQ0lGSUVEEAASCgoGV1MyODEyEAESCQoFSE'
    'M1OTUQAhIMCghEUklWRVJfMxADEgwKCERSSVZFUl80EAQSDAoIRFJJVkVSXzUQBRIMCghEUklW'
    'RVJfNhAG');

@$core.Deprecated('Use matrixDriverKindDescriptor instead')
const MatrixDriverKind$json = {
  '1': 'MatrixDriverKind',
  '2': [
    {'1': 'KIND_UNSPECIFIED', '2': 0},
    {'1': 'LED_STRIP', '2': 1},
    {'1': 'RGB_LED_MODULE', '2': 2},
  ],
};

/// Descriptor for `MatrixDriverKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List matrixDriverKindDescriptor = $convert.base64Decode(
    'ChBNYXRyaXhEcml2ZXJLaW5kEhQKEEtJTkRfVU5TUEVDSUZJRUQQABINCglMRURfU1RSSVAQAR'
    'ISCg5SR0JfTEVEX01PRFVMRRAC');

@$core.Deprecated('Use carPositionDescriptor instead')
const CarPosition$json = {
  '1': 'CarPosition',
  '2': [
    {'1': 'POSITION_UNSPECIFIED', '2': 0},
    {'1': 'REAR_LEFT_DOOR', '2': 1},
    {'1': 'REAR_LEFT_POCKET', '2': 2},
    {'1': 'REAR_LEFT_HANDLE', '2': 3},
    {'1': 'REAR_LEFT_FOOTWELL', '2': 4},
    {'1': 'FRONT_LEFT_DOOR', '2': 5},
    {'1': 'FRONT_LEFT_POCKET', '2': 6},
    {'1': 'FRONT_LEFT_HANDLE', '2': 7},
    {'1': 'FRONT_LEFT_FOOTWELL', '2': 8},
    {'1': 'CONSOLE_LEFT', '2': 9},
    {'1': 'DASH_LEFT', '2': 10},
    {'1': 'DASH_RIGHT', '2': 11},
    {'1': 'CONSOLE_RIGHT', '2': 12},
    {'1': 'FRONT_RIGHT_FOOTWELL', '2': 13},
    {'1': 'FRONT_RIGHT_HANDLE', '2': 14},
    {'1': 'FRONT_RIGHT_POCKET', '2': 15},
    {'1': 'FRONT_RIGHT_DOOR', '2': 16},
    {'1': 'REAR_RIGHT_FOOTWELL', '2': 17},
    {'1': 'REAR_RIGHT_HANDLE', '2': 18},
    {'1': 'REAR_RIGHT_POCKET', '2': 19},
    {'1': 'REAR_RIGHT_DOOR', '2': 20},
  ],
};

/// Descriptor for `CarPosition`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List carPositionDescriptor = $convert.base64Decode(
    'CgtDYXJQb3NpdGlvbhIYChRQT1NJVElPTl9VTlNQRUNJRklFRBAAEhIKDlJFQVJfTEVGVF9ET0'
    '9SEAESFAoQUkVBUl9MRUZUX1BPQ0tFVBACEhQKEFJFQVJfTEVGVF9IQU5ETEUQAxIWChJSRUFS'
    'X0xFRlRfRk9PVFdFTEwQBBITCg9GUk9OVF9MRUZUX0RPT1IQBRIVChFGUk9OVF9MRUZUX1BPQ0'
    'tFVBAGEhUKEUZST05UX0xFRlRfSEFORExFEAcSFwoTRlJPTlRfTEVGVF9GT09UV0VMTBAIEhAK'
    'DENPTlNPTEVfTEVGVBAJEg0KCURBU0hfTEVGVBAKEg4KCkRBU0hfUklHSFQQCxIRCg1DT05TT0'
    'xFX1JJR0hUEAwSGAoURlJPTlRfUklHSFRfRk9PVFdFTEwQDRIWChJGUk9OVF9SSUdIVF9IQU5E'
    'TEUQDhIWChJGUk9OVF9SSUdIVF9QT0NLRVQQDxIUChBGUk9OVF9SSUdIVF9ET09SEBASFwoTUk'
    'VBUl9SSUdIVF9GT09UV0VMTBAREhUKEVJFQVJfUklHSFRfSEFORExFEBISFQoRUkVBUl9SSUdI'
    'VF9QT0NLRVQQExITCg9SRUFSX1JJR0hUX0RPT1IQFA==');

@$core.Deprecated('Use matrixInterpolationDescriptor instead')
const MatrixInterpolation$json = {
  '1': 'MatrixInterpolation',
  '2': [
    {'1': 'LINEAR', '2': 0},
    {'1': 'STEP', '2': 1},
    {'1': 'SMOOTH', '2': 2},
  ],
};

/// Descriptor for `MatrixInterpolation`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List matrixInterpolationDescriptor = $convert.base64Decode(
    'ChNNYXRyaXhJbnRlcnBvbGF0aW9uEgoKBkxJTkVBUhAAEggKBFNURVAQARIKCgZTTU9PVEgQAg'
    '==');

@$core.Deprecated('Use meshInteropNodeDescriptor instead')
const MeshInteropNode$json = {
  '1': 'MeshInteropNode',
  '2': [
    {'1': 'last_synced_at', '3': 1, '4': 1, '5': 3, '10': 'lastSyncedAt'},
    {'1': 'mac', '3': 2, '4': 1, '5': 12, '10': 'mac'},
  ],
};

/// Descriptor for `MeshInteropNode`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meshInteropNodeDescriptor = $convert.base64Decode(
    'Cg9NZXNoSW50ZXJvcE5vZGUSJAoObGFzdF9zeW5jZWRfYXQYASABKANSDGxhc3RTeW5jZWRBdB'
    'IQCgNtYWMYAiABKAxSA21hYw==');

@$core.Deprecated('Use meshInteropStateDescriptor instead')
const MeshInteropState$json = {
  '1': 'MeshInteropState',
  '2': [
    {'1': 'is_discovery_mode', '3': 1, '4': 1, '5': 8, '10': 'isDiscoveryMode'},
    {
      '1': 'nodes',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.MeshInteropNode',
      '10': 'nodes'
    },
  ],
};

/// Descriptor for `MeshInteropState`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List meshInteropStateDescriptor = $convert.base64Decode(
    'ChBNZXNoSW50ZXJvcFN0YXRlEioKEWlzX2Rpc2NvdmVyeV9tb2RlGAEgASgIUg9pc0Rpc2Nvdm'
    'VyeU1vZGUSMwoFbm9kZXMYAyADKAsyHS5tZXNoX2ludGVyb3AuTWVzaEludGVyb3BOb2RlUgVu'
    'b2Rlcw==');

@$core.Deprecated('Use matrixColorDescriptor instead')
const MatrixColor$json = {
  '1': 'MatrixColor',
  '2': [
    {'1': 'red', '3': 1, '4': 1, '5': 13, '10': 'red'},
    {'1': 'green', '3': 2, '4': 1, '5': 13, '10': 'green'},
    {'1': 'blue', '3': 3, '4': 1, '5': 13, '10': 'blue'},
    {'1': 'alpha', '3': 4, '4': 1, '5': 13, '10': 'alpha'},
  ],
};

/// Descriptor for `MatrixColor`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixColorDescriptor = $convert.base64Decode(
    'CgtNYXRyaXhDb2xvchIQCgNyZWQYASABKA1SA3JlZBIUCgVncmVlbhgCIAEoDVIFZ3JlZW4SEg'
    'oEYmx1ZRgDIAEoDVIEYmx1ZRIUCgVhbHBoYRgEIAEoDVIFYWxwaGE=');

@$core.Deprecated('Use matrixKeyframeDescriptor instead')
const MatrixKeyframe$json = {
  '1': 'MatrixKeyframe',
  '2': [
    {'1': 'time_ms', '3': 1, '4': 1, '5': 13, '10': 'timeMs'},
    {'1': 'red', '3': 2, '4': 1, '5': 13, '10': 'red'},
    {'1': 'green', '3': 3, '4': 1, '5': 13, '10': 'green'},
    {'1': 'blue', '3': 4, '4': 1, '5': 13, '10': 'blue'},
    {'1': 'alpha', '3': 5, '4': 1, '5': 13, '10': 'alpha'},
    {
      '1': 'interpolation',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.mesh_interop.MatrixInterpolation',
      '10': 'interpolation'
    },
    {'1': 'position', '3': 7, '4': 1, '5': 2, '10': 'position'},
    {'1': 'width', '3': 8, '4': 1, '5': 2, '9': 0, '10': 'width', '17': true},
    {'1': 'all_pixels', '3': 9, '4': 1, '5': 8, '10': 'allPixels'},
    {'1': 'track_id', '3': 10, '4': 1, '5': 13, '10': 'trackId'},
    {'1': 'wrap', '3': 11, '4': 1, '5': 8, '10': 'wrap'},
  ],
  '8': [
    {'1': '_width'},
  ],
};

/// Descriptor for `MatrixKeyframe`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixKeyframeDescriptor = $convert.base64Decode(
    'Cg5NYXRyaXhLZXlmcmFtZRIXCgd0aW1lX21zGAEgASgNUgZ0aW1lTXMSEAoDcmVkGAIgASgNUg'
    'NyZWQSFAoFZ3JlZW4YAyABKA1SBWdyZWVuEhIKBGJsdWUYBCABKA1SBGJsdWUSFAoFYWxwaGEY'
    'BSABKA1SBWFscGhhEkcKDWludGVycG9sYXRpb24YBiABKA4yIS5tZXNoX2ludGVyb3AuTWF0cm'
    'l4SW50ZXJwb2xhdGlvblINaW50ZXJwb2xhdGlvbhIaCghwb3NpdGlvbhgHIAEoAlIIcG9zaXRp'
    'b24SGQoFd2lkdGgYCCABKAJIAFIFd2lkdGiIAQESHQoKYWxsX3BpeGVscxgJIAEoCFIJYWxsUG'
    'l4ZWxzEhkKCHRyYWNrX2lkGAogASgNUgd0cmFja0lkEhIKBHdyYXAYCyABKAhSBHdyYXBCCAoG'
    'X3dpZHRo');

@$core.Deprecated('Use matrixEffectDescriptor instead')
const MatrixEffect$json = {
  '1': 'MatrixEffect',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {
      '1': 'kind',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.mesh_interop.MatrixEffect.Kind',
      '10': 'kind'
    },
    {'1': 'red', '3': 3, '4': 1, '5': 13, '10': 'red'},
    {'1': 'green', '3': 4, '4': 1, '5': 13, '10': 'green'},
    {'1': 'blue', '3': 5, '4': 1, '5': 13, '10': 'blue'},
    {'1': 'alpha', '3': 6, '4': 1, '5': 13, '10': 'alpha'},
    {'1': 'duration_ms', '3': 7, '4': 1, '5': 13, '10': 'durationMs'},
    {'1': 'period_ms', '3': 8, '4': 1, '5': 13, '10': 'periodMs'},
    {'1': 'duty_percent', '3': 9, '4': 1, '5': 13, '10': 'dutyPercent'},
    {
      '1': 'secondary_color',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.mesh_interop.MatrixColor',
      '10': 'secondaryColor'
    },
    {
      '1': 'keyframes',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.MatrixKeyframe',
      '10': 'keyframes'
    },
    {'1': 'loop', '3': 12, '4': 1, '5': 8, '10': 'loop'},
    {
      '1': 'wavelength_pixels',
      '3': 13,
      '4': 1,
      '5': 13,
      '10': 'wavelengthPixels'
    },
    {'1': 'reverse', '3': 14, '4': 1, '5': 8, '10': 'reverse'},
    {'1': 'name', '3': 15, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'gradient_colors',
      '3': 16,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.MatrixColor',
      '10': 'gradientColors'
    },
    {'1': 'fill_from_center', '3': 17, '4': 1, '5': 8, '10': 'fillFromCenter'},
  ],
  '4': [MatrixEffect_Kind$json],
};

@$core.Deprecated('Use matrixEffectDescriptor instead')
const MatrixEffect_Kind$json = {
  '1': 'Kind',
  '2': [
    {'1': 'EFFECT_UNSPECIFIED', '2': 0},
    {'1': 'STATIC_COLOR', '2': 1},
    {'1': 'KEYFRAMES', '2': 2},
    {'1': 'BLINK', '2': 3},
    {'1': 'BREATHE', '2': 4},
    {'1': 'FLOWING_GRADIENT', '2': 5},
    {'1': 'RAINBOW', '2': 6},
    {'1': 'FILL', '2': 7},
  ],
};

/// Descriptor for `MatrixEffect`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixEffectDescriptor = $convert.base64Decode(
    'CgxNYXRyaXhFZmZlY3QSDgoCaWQYASABKA1SAmlkEjMKBGtpbmQYAiABKA4yHy5tZXNoX2ludG'
    'Vyb3AuTWF0cml4RWZmZWN0LktpbmRSBGtpbmQSEAoDcmVkGAMgASgNUgNyZWQSFAoFZ3JlZW4Y'
    'BCABKA1SBWdyZWVuEhIKBGJsdWUYBSABKA1SBGJsdWUSFAoFYWxwaGEYBiABKA1SBWFscGhhEh'
    '8KC2R1cmF0aW9uX21zGAcgASgNUgpkdXJhdGlvbk1zEhsKCXBlcmlvZF9tcxgIIAEoDVIIcGVy'
    'aW9kTXMSIQoMZHV0eV9wZXJjZW50GAkgASgNUgtkdXR5UGVyY2VudBJCCg9zZWNvbmRhcnlfY2'
    '9sb3IYCiABKAsyGS5tZXNoX2ludGVyb3AuTWF0cml4Q29sb3JSDnNlY29uZGFyeUNvbG9yEjoK'
    'CWtleWZyYW1lcxgLIAMoCzIcLm1lc2hfaW50ZXJvcC5NYXRyaXhLZXlmcmFtZVIJa2V5ZnJhbW'
    'VzEhIKBGxvb3AYDCABKAhSBGxvb3ASKwoRd2F2ZWxlbmd0aF9waXhlbHMYDSABKA1SEHdhdmVs'
    'ZW5ndGhQaXhlbHMSGAoHcmV2ZXJzZRgOIAEoCFIHcmV2ZXJzZRISCgRuYW1lGA8gASgJUgRuYW'
    '1lEkIKD2dyYWRpZW50X2NvbG9ycxgQIAMoCzIZLm1lc2hfaW50ZXJvcC5NYXRyaXhDb2xvclIO'
    'Z3JhZGllbnRDb2xvcnMSKAoQZmlsbF9mcm9tX2NlbnRlchgRIAEoCFIOZmlsbEZyb21DZW50ZX'
    'IihAEKBEtpbmQSFgoSRUZGRUNUX1VOU1BFQ0lGSUVEEAASEAoMU1RBVElDX0NPTE9SEAESDQoJ'
    'S0VZRlJBTUVTEAISCQoFQkxJTksQAxILCgdCUkVBVEhFEAQSFAoQRkxPV0lOR19HUkFESUVOVB'
    'AFEgsKB1JBSU5CT1cQBhIICgRGSUxMEAc=');

@$core.Deprecated('Use matrixSourceDescriptor instead')
const MatrixSource$json = {
  '1': 'MatrixSource',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {
      '1': 'kind',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.mesh_interop.MatrixSource.Kind',
      '10': 'kind'
    },
    {'1': 'node_mac', '3': 3, '4': 1, '5': 12, '10': 'nodeMac'},
    {'1': 'gpio', '3': 4, '4': 1, '5': 13, '10': 'gpio'},
    {'1': 'rising', '3': 5, '4': 1, '5': 8, '10': 'rising'},
  ],
  '4': [MatrixSource_Kind$json],
};

@$core.Deprecated('Use matrixSourceDescriptor instead')
const MatrixSource_Kind$json = {
  '1': 'Kind',
  '2': [
    {'1': 'SOURCE_UNSPECIFIED', '2': 0},
    {'1': 'DEFAULT_STATE', '2': 1},
    {'1': 'GPIO_EDGE', '2': 2},
    {'1': 'ON_BOOT', '2': 3},
    {'1': 'ON_MODE_SWITCHED', '2': 4},
  ],
};

/// Descriptor for `MatrixSource`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixSourceDescriptor = $convert.base64Decode(
    'CgxNYXRyaXhTb3VyY2USDgoCaWQYASABKA1SAmlkEjMKBGtpbmQYAiABKA4yHy5tZXNoX2ludG'
    'Vyb3AuTWF0cml4U291cmNlLktpbmRSBGtpbmQSGQoIbm9kZV9tYWMYAyABKAxSB25vZGVNYWMS'
    'EgoEZ3BpbxgEIAEoDVIEZ3BpbxIWCgZyaXNpbmcYBSABKAhSBnJpc2luZyJjCgRLaW5kEhYKEl'
    'NPVVJDRV9VTlNQRUNJRklFRBAAEhEKDURFRkFVTFRfU1RBVEUQARINCglHUElPX0VER0UQAhIL'
    'CgdPTl9CT09UEAMSFAoQT05fTU9ERV9TV0lUQ0hFRBAE');

@$core.Deprecated('Use matrixConditionDescriptor instead')
const MatrixCondition$json = {
  '1': 'MatrixCondition',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {
      '1': 'kind',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.mesh_interop.MatrixCondition.Kind',
      '10': 'kind'
    },
    {'1': 'mode_id', '3': 3, '4': 1, '5': 13, '10': 'modeId'},
  ],
  '4': [MatrixCondition_Kind$json],
};

@$core.Deprecated('Use matrixConditionDescriptor instead')
const MatrixCondition_Kind$json = {
  '1': 'Kind',
  '2': [
    {'1': 'CONDITION_UNSPECIFIED', '2': 0},
    {'1': 'ALWAYS', '2': 1},
    {'1': 'MODE', '2': 2},
  ],
};

/// Descriptor for `MatrixCondition`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixConditionDescriptor = $convert.base64Decode(
    'Cg9NYXRyaXhDb25kaXRpb24SDgoCaWQYASABKA1SAmlkEjYKBGtpbmQYAiABKA4yIi5tZXNoX2'
    'ludGVyb3AuTWF0cml4Q29uZGl0aW9uLktpbmRSBGtpbmQSFwoHbW9kZV9pZBgDIAEoDVIGbW9k'
    'ZUlkIjcKBEtpbmQSGQoVQ09ORElUSU9OX1VOU1BFQ0lGSUVEEAASCgoGQUxXQVlTEAESCAoETU'
    '9ERRAC');

@$core.Deprecated('Use matrixModeDescriptor instead')
const MatrixMode$json = {
  '1': 'MatrixMode',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `MatrixMode`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixModeDescriptor = $convert.base64Decode(
    'CgpNYXRyaXhNb2RlEg4KAmlkGAEgASgNUgJpZBISCgRuYW1lGAIgASgJUgRuYW1l');

@$core.Deprecated('Use matrixLayoutDescriptor instead')
const MatrixLayout$json = {
  '1': 'MatrixLayout',
  '2': [
    {'1': 'node_mac', '3': 1, '4': 1, '5': 12, '10': 'nodeMac'},
    {
      '1': 'driver',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.mesh_interop.MatrixDriver',
      '10': 'driver'
    },
    {'1': 'from', '3': 3, '4': 1, '5': 13, '10': 'from'},
    {'1': 'to', '3': 4, '4': 1, '5': 13, '10': 'to'},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '10': 'name'},
    {'1': 'source_index', '3': 6, '4': 1, '5': 13, '10': 'sourceIndex'},
    {
      '1': 'car_position',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.mesh_interop.CarPosition',
      '10': 'carPosition'
    },
  ],
};

/// Descriptor for `MatrixLayout`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixLayoutDescriptor = $convert.base64Decode(
    'CgxNYXRyaXhMYXlvdXQSGQoIbm9kZV9tYWMYASABKAxSB25vZGVNYWMSMgoGZHJpdmVyGAIgAS'
    'gOMhoubWVzaF9pbnRlcm9wLk1hdHJpeERyaXZlclIGZHJpdmVyEhIKBGZyb20YAyABKA1SBGZy'
    'b20SDgoCdG8YBCABKA1SAnRvEhIKBG5hbWUYBSABKAlSBG5hbWUSIQoMc291cmNlX2luZGV4GA'
    'YgASgNUgtzb3VyY2VJbmRleBI8CgxjYXJfcG9zaXRpb24YByABKA4yGS5tZXNoX2ludGVyb3Au'
    'Q2FyUG9zaXRpb25SC2NhclBvc2l0aW9u');

@$core.Deprecated('Use matrixEntryDescriptor instead')
const MatrixEntry$json = {
  '1': 'MatrixEntry',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'effect_id', '3': 2, '4': 1, '5': 13, '10': 'effectId'},
    {'1': 'source_id', '3': 3, '4': 1, '5': 13, '10': 'sourceId'},
    {'1': 'condition_id', '3': 4, '4': 1, '5': 13, '10': 'conditionId'},
    {'1': 'priority', '3': 5, '4': 1, '5': 13, '10': 'priority'},
    {'1': 'name', '3': 7, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'opaque_background',
      '3': 8,
      '4': 1,
      '5': 8,
      '10': 'opaqueBackground'
    },
  ],
  '9': [
    {'1': 6, '2': 7},
  ],
  '10': ['targets'],
};

/// Descriptor for `MatrixEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixEntryDescriptor = $convert.base64Decode(
    'CgtNYXRyaXhFbnRyeRIOCgJpZBgBIAEoDVICaWQSGwoJZWZmZWN0X2lkGAIgASgNUghlZmZlY3'
    'RJZBIbCglzb3VyY2VfaWQYAyABKA1SCHNvdXJjZUlkEiEKDGNvbmRpdGlvbl9pZBgEIAEoDVIL'
    'Y29uZGl0aW9uSWQSGgoIcHJpb3JpdHkYBSABKA1SCHByaW9yaXR5EhIKBG5hbWUYByABKAlSBG'
    '5hbWUSKwoRb3BhcXVlX2JhY2tncm91bmQYCCABKAhSEG9wYXF1ZUJhY2tncm91bmRKBAgGEAdS'
    'B3RhcmdldHM=');

@$core.Deprecated('Use matrixConfigDescriptor instead')
const MatrixConfig$json = {
  '1': 'MatrixConfig',
  '2': [
    {'1': 'schema_version', '3': 1, '4': 1, '5': 13, '10': 'schemaVersion'},
    {
      '1': 'effects',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.MatrixEffect',
      '10': 'effects'
    },
    {
      '1': 'sources',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.MatrixSource',
      '10': 'sources'
    },
    {
      '1': 'conditions',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.MatrixCondition',
      '10': 'conditions'
    },
    {
      '1': 'entries',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.MatrixEntry',
      '10': 'entries'
    },
    {
      '1': 'layout',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.MatrixLayout',
      '10': 'layout'
    },
    {'1': 'factory_default', '3': 7, '4': 1, '5': 8, '10': 'factoryDefault'},
    {
      '1': 'modes',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.MatrixMode',
      '10': 'modes'
    },
    {'1': 'active_mode_id', '3': 9, '4': 1, '5': 13, '10': 'activeModeId'},
  ],
};

/// Descriptor for `MatrixConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixConfigDescriptor = $convert.base64Decode(
    'CgxNYXRyaXhDb25maWcSJQoOc2NoZW1hX3ZlcnNpb24YASABKA1SDXNjaGVtYVZlcnNpb24SNA'
    'oHZWZmZWN0cxgCIAMoCzIaLm1lc2hfaW50ZXJvcC5NYXRyaXhFZmZlY3RSB2VmZmVjdHMSNAoH'
    'c291cmNlcxgDIAMoCzIaLm1lc2hfaW50ZXJvcC5NYXRyaXhTb3VyY2VSB3NvdXJjZXMSPQoKY2'
    '9uZGl0aW9ucxgEIAMoCzIdLm1lc2hfaW50ZXJvcC5NYXRyaXhDb25kaXRpb25SCmNvbmRpdGlv'
    'bnMSMwoHZW50cmllcxgFIAMoCzIZLm1lc2hfaW50ZXJvcC5NYXRyaXhFbnRyeVIHZW50cmllcx'
    'IyCgZsYXlvdXQYBiADKAsyGi5tZXNoX2ludGVyb3AuTWF0cml4TGF5b3V0UgZsYXlvdXQSJwoP'
    'ZmFjdG9yeV9kZWZhdWx0GAcgASgIUg5mYWN0b3J5RGVmYXVsdBIuCgVtb2RlcxgIIAMoCzIYLm'
    '1lc2hfaW50ZXJvcC5NYXRyaXhNb2RlUgVtb2RlcxIkCg5hY3RpdmVfbW9kZV9pZBgJIAEoDVIM'
    'YWN0aXZlTW9kZUlk');

@$core.Deprecated('Use transferBeginDescriptor instead')
const TransferBegin$json = {
  '1': 'TransferBegin',
  '2': [
    {'1': 'transfer_id', '3': 1, '4': 1, '5': 7, '10': 'transferId'},
    {'1': 'total_size', '3': 2, '4': 1, '5': 7, '10': 'totalSize'},
    {'1': 'crc32', '3': 3, '4': 1, '5': 7, '10': 'crc32'},
  ],
};

/// Descriptor for `TransferBegin`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferBeginDescriptor = $convert.base64Decode(
    'Cg1UcmFuc2ZlckJlZ2luEh8KC3RyYW5zZmVyX2lkGAEgASgHUgp0cmFuc2ZlcklkEh0KCnRvdG'
    'FsX3NpemUYAiABKAdSCXRvdGFsU2l6ZRIUCgVjcmMzMhgDIAEoB1IFY3JjMzI=');

@$core.Deprecated('Use transferChunkDescriptor instead')
const TransferChunk$json = {
  '1': 'TransferChunk',
  '2': [
    {'1': 'transfer_id', '3': 1, '4': 1, '5': 7, '10': 'transferId'},
    {'1': 'offset', '3': 2, '4': 1, '5': 13, '10': 'offset'},
    {'1': 'data', '3': 3, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `TransferChunk`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferChunkDescriptor = $convert.base64Decode(
    'Cg1UcmFuc2ZlckNodW5rEh8KC3RyYW5zZmVyX2lkGAEgASgHUgp0cmFuc2ZlcklkEhYKBm9mZn'
    'NldBgCIAEoDVIGb2Zmc2V0EhIKBGRhdGEYAyABKAxSBGRhdGE=');

@$core.Deprecated('Use matrixUploadDescriptor instead')
const MatrixUpload$json = {
  '1': 'MatrixUpload',
  '2': [
    {
      '1': 'begin',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.mesh_interop.TransferBegin',
      '9': 0,
      '10': 'begin'
    },
    {
      '1': 'chunk',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.mesh_interop.TransferChunk',
      '9': 0,
      '10': 'chunk'
    },
    {'1': 'commit', '3': 3, '4': 1, '5': 7, '9': 0, '10': 'commit'},
    {'1': 'abort', '3': 4, '4': 1, '5': 7, '9': 0, '10': 'abort'},
    {
      '1': 'layout_request',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.mesh_interop.LayoutRequest',
      '9': 0,
      '10': 'layoutRequest'
    },
    {
      '1': 'layout_begin',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.mesh_interop.TransferBegin',
      '9': 0,
      '10': 'layoutBegin'
    },
    {
      '1': 'matrix_begin',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.mesh_interop.TransferBegin',
      '9': 0,
      '10': 'matrixBegin'
    },
  ],
  '8': [
    {'1': 'operation'},
  ],
};

/// Descriptor for `MatrixUpload`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixUploadDescriptor = $convert.base64Decode(
    'CgxNYXRyaXhVcGxvYWQSMwoFYmVnaW4YASABKAsyGy5tZXNoX2ludGVyb3AuVHJhbnNmZXJCZW'
    'dpbkgAUgViZWdpbhIzCgVjaHVuaxgCIAEoCzIbLm1lc2hfaW50ZXJvcC5UcmFuc2ZlckNodW5r'
    'SABSBWNodW5rEhgKBmNvbW1pdBgDIAEoB0gAUgZjb21taXQSFgoFYWJvcnQYBCABKAdIAFIFYW'
    'JvcnQSRAoObGF5b3V0X3JlcXVlc3QYBSABKAsyGy5tZXNoX2ludGVyb3AuTGF5b3V0UmVxdWVz'
    'dEgAUg1sYXlvdXRSZXF1ZXN0EkAKDGxheW91dF9iZWdpbhgGIAEoCzIbLm1lc2hfaW50ZXJvcC'
    '5UcmFuc2ZlckJlZ2luSABSC2xheW91dEJlZ2luEkAKDG1hdHJpeF9iZWdpbhgHIAEoCzIbLm1l'
    'c2hfaW50ZXJvcC5UcmFuc2ZlckJlZ2luSABSC21hdHJpeEJlZ2luQgsKCW9wZXJhdGlvbg==');

@$core.Deprecated('Use layoutUpdateDescriptor instead')
const LayoutUpdate$json = {
  '1': 'LayoutUpdate',
  '2': [
    {
      '1': 'expected_revision',
      '3': 1,
      '4': 1,
      '5': 4,
      '10': 'expectedRevision'
    },
    {'1': 'master_session', '3': 2, '4': 1, '5': 4, '10': 'masterSession'},
    {
      '1': 'layout',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.MatrixLayout',
      '10': 'layout'
    },
  ],
};

/// Descriptor for `LayoutUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List layoutUpdateDescriptor = $convert.base64Decode(
    'CgxMYXlvdXRVcGRhdGUSKwoRZXhwZWN0ZWRfcmV2aXNpb24YASABKARSEGV4cGVjdGVkUmV2aX'
    'Npb24SJQoObWFzdGVyX3Nlc3Npb24YAiABKARSDW1hc3RlclNlc3Npb24SMgoGbGF5b3V0GAMg'
    'AygLMhoubWVzaF9pbnRlcm9wLk1hdHJpeExheW91dFIGbGF5b3V0');

@$core.Deprecated('Use matrixUpdateDescriptor instead')
const MatrixUpdate$json = {
  '1': 'MatrixUpdate',
  '2': [
    {
      '1': 'expected_revision',
      '3': 1,
      '4': 1,
      '5': 4,
      '10': 'expectedRevision'
    },
    {'1': 'master_session', '3': 2, '4': 1, '5': 4, '10': 'masterSession'},
    {
      '1': 'effects',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.MatrixEffect',
      '10': 'effects'
    },
    {
      '1': 'sources',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.MatrixSource',
      '10': 'sources'
    },
    {
      '1': 'conditions',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.MatrixCondition',
      '10': 'conditions'
    },
    {
      '1': 'entries',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.MatrixEntry',
      '10': 'entries'
    },
    {
      '1': 'modes',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.MatrixMode',
      '10': 'modes'
    },
    {'1': 'active_mode_id', '3': 8, '4': 1, '5': 13, '10': 'activeModeId'},
  ],
};

/// Descriptor for `MatrixUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixUpdateDescriptor = $convert.base64Decode(
    'CgxNYXRyaXhVcGRhdGUSKwoRZXhwZWN0ZWRfcmV2aXNpb24YASABKARSEGV4cGVjdGVkUmV2aX'
    'Npb24SJQoObWFzdGVyX3Nlc3Npb24YAiABKARSDW1hc3RlclNlc3Npb24SNAoHZWZmZWN0cxgD'
    'IAMoCzIaLm1lc2hfaW50ZXJvcC5NYXRyaXhFZmZlY3RSB2VmZmVjdHMSNAoHc291cmNlcxgEIA'
    'MoCzIaLm1lc2hfaW50ZXJvcC5NYXRyaXhTb3VyY2VSB3NvdXJjZXMSPQoKY29uZGl0aW9ucxgF'
    'IAMoCzIdLm1lc2hfaW50ZXJvcC5NYXRyaXhDb25kaXRpb25SCmNvbmRpdGlvbnMSMwoHZW50cm'
    'llcxgGIAMoCzIZLm1lc2hfaW50ZXJvcC5NYXRyaXhFbnRyeVIHZW50cmllcxIuCgVtb2RlcxgH'
    'IAMoCzIYLm1lc2hfaW50ZXJvcC5NYXRyaXhNb2RlUgVtb2RlcxIkCg5hY3RpdmVfbW9kZV9pZB'
    'gIIAEoDVIMYWN0aXZlTW9kZUlk');

@$core.Deprecated('Use matrixInputNodeDescriptor instead')
const MatrixInputNode$json = {
  '1': 'MatrixInputNode',
  '2': [
    {'1': 'node_mac', '3': 1, '4': 1, '5': 12, '10': 'nodeMac'},
    {'1': 'gpios', '3': 2, '4': 3, '5': 13, '10': 'gpios'},
    {'1': 'known', '3': 3, '4': 1, '5': 8, '10': 'known'},
    {'1': 'online', '3': 4, '4': 1, '5': 8, '10': 'online'},
  ],
};

/// Descriptor for `MatrixInputNode`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixInputNodeDescriptor = $convert.base64Decode(
    'Cg9NYXRyaXhJbnB1dE5vZGUSGQoIbm9kZV9tYWMYASABKAxSB25vZGVNYWMSFAoFZ3Bpb3MYAi'
    'ADKA1SBWdwaW9zEhQKBWtub3duGAMgASgIUgVrbm93bhIWCgZvbmxpbmUYBCABKAhSBm9ubGlu'
    'ZQ==');

@$core.Deprecated('Use matrixDocumentDescriptor instead')
const MatrixDocument$json = {
  '1': 'MatrixDocument',
  '2': [
    {'1': 'config', '3': 1, '4': 1, '5': 12, '10': 'config'},
    {'1': 'revision', '3': 2, '4': 1, '5': 4, '10': 'revision'},
    {'1': 'master_session', '3': 3, '4': 1, '5': 4, '10': 'masterSession'},
    {'1': 'master_mac', '3': 4, '4': 1, '5': 12, '10': 'masterMac'},
    {
      '1': 'nodes',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.MatrixInputNode',
      '10': 'nodes'
    },
    {'1': 'active_revision', '3': 6, '4': 1, '5': 4, '10': 'activeRevision'},
    {
      '1': 'activation_pending',
      '3': 7,
      '4': 1,
      '5': 8,
      '10': 'activationPending'
    },
    {'1': 'persisted', '3': 8, '4': 1, '5': 8, '10': 'persisted'},
  ],
};

/// Descriptor for `MatrixDocument`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixDocumentDescriptor = $convert.base64Decode(
    'Cg5NYXRyaXhEb2N1bWVudBIWCgZjb25maWcYASABKAxSBmNvbmZpZxIaCghyZXZpc2lvbhgCIA'
    'EoBFIIcmV2aXNpb24SJQoObWFzdGVyX3Nlc3Npb24YAyABKARSDW1hc3RlclNlc3Npb24SHQoK'
    'bWFzdGVyX21hYxgEIAEoDFIJbWFzdGVyTWFjEjMKBW5vZGVzGAUgAygLMh0ubWVzaF9pbnRlcm'
    '9wLk1hdHJpeElucHV0Tm9kZVIFbm9kZXMSJwoPYWN0aXZlX3JldmlzaW9uGAYgASgEUg5hY3Rp'
    'dmVSZXZpc2lvbhItChJhY3RpdmF0aW9uX3BlbmRpbmcYByABKAhSEWFjdGl2YXRpb25QZW5kaW'
    '5nEhwKCXBlcnNpc3RlZBgIIAEoCFIJcGVyc2lzdGVk');

@$core.Deprecated('Use layoutOutputDescriptor instead')
const LayoutOutput$json = {
  '1': 'LayoutOutput',
  '2': [
    {'1': 'node_mac', '3': 1, '4': 1, '5': 12, '10': 'nodeMac'},
    {
      '1': 'driver',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.mesh_interop.MatrixDriver',
      '10': 'driver'
    },
    {'1': 'pixel_count', '3': 3, '4': 1, '5': 13, '10': 'pixelCount'},
    {'1': 'online', '3': 4, '4': 1, '5': 8, '10': 'online'},
    {'1': 'ready', '3': 5, '4': 1, '5': 8, '10': 'ready'},
    {'1': 'known', '3': 6, '4': 1, '5': 8, '10': 'known'},
    {
      '1': 'driver_kind',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.mesh_interop.MatrixDriverKind',
      '10': 'driverKind'
    },
    {'1': 'source_index', '3': 8, '4': 1, '5': 13, '10': 'sourceIndex'},
    {'1': 'max_pixel_count', '3': 9, '4': 1, '5': 13, '10': 'maxPixelCount'},
  ],
};

/// Descriptor for `LayoutOutput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List layoutOutputDescriptor = $convert.base64Decode(
    'CgxMYXlvdXRPdXRwdXQSGQoIbm9kZV9tYWMYASABKAxSB25vZGVNYWMSMgoGZHJpdmVyGAIgAS'
    'gOMhoubWVzaF9pbnRlcm9wLk1hdHJpeERyaXZlclIGZHJpdmVyEh8KC3BpeGVsX2NvdW50GAMg'
    'ASgNUgpwaXhlbENvdW50EhYKBm9ubGluZRgEIAEoCFIGb25saW5lEhQKBXJlYWR5GAUgASgIUg'
    'VyZWFkeRIUCgVrbm93bhgGIAEoCFIFa25vd24SPwoLZHJpdmVyX2tpbmQYByABKA4yHi5tZXNo'
    'X2ludGVyb3AuTWF0cml4RHJpdmVyS2luZFIKZHJpdmVyS2luZBIhCgxzb3VyY2VfaW5kZXgYCC'
    'ABKA1SC3NvdXJjZUluZGV4EiYKD21heF9waXhlbF9jb3VudBgJIAEoDVINbWF4UGl4ZWxDb3Vu'
    'dA==');

@$core.Deprecated('Use layoutSnapshotDescriptor instead')
const LayoutSnapshot$json = {
  '1': 'LayoutSnapshot',
  '2': [
    {'1': 'master_session', '3': 1, '4': 1, '5': 4, '10': 'masterSession'},
    {'1': 'revision', '3': 2, '4': 1, '5': 4, '10': 'revision'},
    {
      '1': 'layout',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.MatrixLayout',
      '10': 'layout'
    },
    {
      '1': 'outputs',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.LayoutOutput',
      '10': 'outputs'
    },
    {'1': 'pending_nodes', '3': 5, '4': 1, '5': 13, '10': 'pendingNodes'},
    {'1': 'master_mac', '3': 6, '4': 1, '5': 12, '10': 'masterMac'},
  ],
};

/// Descriptor for `LayoutSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List layoutSnapshotDescriptor = $convert.base64Decode(
    'Cg5MYXlvdXRTbmFwc2hvdBIlCg5tYXN0ZXJfc2Vzc2lvbhgBIAEoBFINbWFzdGVyU2Vzc2lvbh'
    'IaCghyZXZpc2lvbhgCIAEoBFIIcmV2aXNpb24SMgoGbGF5b3V0GAMgAygLMhoubWVzaF9pbnRl'
    'cm9wLk1hdHJpeExheW91dFIGbGF5b3V0EjQKB291dHB1dHMYBCADKAsyGi5tZXNoX2ludGVyb3'
    'AuTGF5b3V0T3V0cHV0UgdvdXRwdXRzEiMKDXBlbmRpbmdfbm9kZXMYBSABKA1SDHBlbmRpbmdO'
    'b2RlcxIdCgptYXN0ZXJfbWFjGAYgASgMUgltYXN0ZXJNYWM=');

@$core.Deprecated('Use layoutRequestDescriptor instead')
const LayoutRequest$json = {
  '1': 'LayoutRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 13, '10': 'requestId'},
    {
      '1': 'operation',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.mesh_interop.LayoutRequest.Operation',
      '10': 'operation'
    },
    {'1': 'snapshot_id', '3': 3, '4': 1, '5': 7, '10': 'snapshotId'},
    {'1': 'offset', '3': 4, '4': 1, '5': 13, '10': 'offset'},
    {'1': 'output_index', '3': 5, '4': 1, '5': 13, '10': 'outputIndex'},
    {
      '1': 'identify_options',
      '3': 6,
      '4': 1,
      '5': 7,
      '9': 0,
      '10': 'identifyOptions',
      '17': true
    },
  ],
  '4': [LayoutRequest_Operation$json],
  '8': [
    {'1': '_identify_options'},
  ],
};

@$core.Deprecated('Use layoutRequestDescriptor instead')
const LayoutRequest_Operation$json = {
  '1': 'Operation',
  '2': [
    {'1': 'READ', '2': 0},
    {'1': 'IDENTIFY', '2': 1},
    {'1': 'READ_MATRIX', '2': 2},
    {'1': 'READ_ACTIVE_MATRIX', '2': 3},
  ],
};

/// Descriptor for `LayoutRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List layoutRequestDescriptor = $convert.base64Decode(
    'Cg1MYXlvdXRSZXF1ZXN0Eh0KCnJlcXVlc3RfaWQYASABKA1SCXJlcXVlc3RJZBJDCglvcGVyYX'
    'Rpb24YAiABKA4yJS5tZXNoX2ludGVyb3AuTGF5b3V0UmVxdWVzdC5PcGVyYXRpb25SCW9wZXJh'
    'dGlvbhIfCgtzbmFwc2hvdF9pZBgDIAEoB1IKc25hcHNob3RJZBIWCgZvZmZzZXQYBCABKA1SBm'
    '9mZnNldBIhCgxvdXRwdXRfaW5kZXgYBSABKA1SC291dHB1dEluZGV4Ei4KEGlkZW50aWZ5X29w'
    'dGlvbnMYBiABKAdIAFIPaWRlbnRpZnlPcHRpb25ziAEBIkwKCU9wZXJhdGlvbhIICgRSRUFEEA'
    'ASDAoISURFTlRJRlkQARIPCgtSRUFEX01BVFJJWBACEhYKElJFQURfQUNUSVZFX01BVFJJWBAD'
    'QhMKEV9pZGVudGlmeV9vcHRpb25z');

@$core.Deprecated('Use layoutResponseDescriptor instead')
const LayoutResponse$json = {
  '1': 'LayoutResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 13, '10': 'requestId'},
    {'1': 'error', '3': 2, '4': 1, '5': 9, '10': 'error'},
    {'1': 'snapshot_id', '3': 3, '4': 1, '5': 7, '10': 'snapshotId'},
    {'1': 'total_size', '3': 4, '4': 1, '5': 13, '10': 'totalSize'},
    {'1': 'offset', '3': 5, '4': 1, '5': 13, '10': 'offset'},
    {'1': 'data', '3': 6, '4': 1, '5': 12, '10': 'data'},
    {'1': 'complete', '3': 7, '4': 1, '5': 8, '10': 'complete'},
  ],
};

/// Descriptor for `LayoutResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List layoutResponseDescriptor = $convert.base64Decode(
    'Cg5MYXlvdXRSZXNwb25zZRIdCgpyZXF1ZXN0X2lkGAEgASgNUglyZXF1ZXN0SWQSFAoFZXJyb3'
    'IYAiABKAlSBWVycm9yEh8KC3NuYXBzaG90X2lkGAMgASgHUgpzbmFwc2hvdElkEh0KCnRvdGFs'
    'X3NpemUYBCABKA1SCXRvdGFsU2l6ZRIWCgZvZmZzZXQYBSABKA1SBm9mZnNldBISCgRkYXRhGA'
    'YgASgMUgRkYXRhEhoKCGNvbXBsZXRlGAcgASgIUghjb21wbGV0ZQ==');

@$core.Deprecated('Use matrixNodeStatusDescriptor instead')
const MatrixNodeStatus$json = {
  '1': 'MatrixNodeStatus',
  '2': [
    {'1': 'node_mac', '3': 1, '4': 1, '5': 12, '10': 'nodeMac'},
    {
      '1': 'state',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.mesh_interop.MatrixNodeStatus.State',
      '10': 'state'
    },
  ],
  '4': [MatrixNodeStatus_State$json],
};

@$core.Deprecated('Use matrixNodeStatusDescriptor instead')
const MatrixNodeStatus_State$json = {
  '1': 'State',
  '2': [
    {'1': 'UNAVAILABLE', '2': 0},
    {'1': 'PREPARING', '2': 1},
    {'1': 'READY', '2': 2},
    {'1': 'DEGRADED', '2': 3},
  ],
};

/// Descriptor for `MatrixNodeStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixNodeStatusDescriptor = $convert.base64Decode(
    'ChBNYXRyaXhOb2RlU3RhdHVzEhkKCG5vZGVfbWFjGAEgASgMUgdub2RlTWFjEjoKBXN0YXRlGA'
    'IgASgOMiQubWVzaF9pbnRlcm9wLk1hdHJpeE5vZGVTdGF0dXMuU3RhdGVSBXN0YXRlIkAKBVN0'
    'YXRlEg8KC1VOQVZBSUxBQkxFEAASDQoJUFJFUEFSSU5HEAESCQoFUkVBRFkQAhIMCghERUdSQU'
    'RFRBAD');

@$core.Deprecated('Use matrixStatusDescriptor instead')
const MatrixStatus$json = {
  '1': 'MatrixStatus',
  '2': [
    {'1': 'transfer_id', '3': 1, '4': 1, '5': 7, '10': 'transferId'},
    {
      '1': 'stage',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.mesh_interop.MatrixStatus.Stage',
      '10': 'stage'
    },
    {'1': 'received_bytes', '3': 3, '4': 1, '5': 13, '10': 'receivedBytes'},
    {'1': 'revision', '3': 4, '4': 1, '5': 4, '10': 'revision'},
    {'1': 'master_session', '3': 5, '4': 1, '5': 4, '10': 'masterSession'},
    {'1': 'error', '3': 6, '4': 1, '5': 9, '10': 'error'},
    {
      '1': 'nodes',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.MatrixNodeStatus',
      '10': 'nodes'
    },
    {'1': 'master_mac', '3': 8, '4': 1, '5': 12, '10': 'masterMac'},
  ],
  '4': [MatrixStatus_Stage$json],
};

@$core.Deprecated('Use matrixStatusDescriptor instead')
const MatrixStatus_Stage$json = {
  '1': 'Stage',
  '2': [
    {'1': 'IDLE', '2': 0},
    {'1': 'RECEIVING', '2': 1},
    {'1': 'VALIDATING', '2': 2},
    {'1': 'DISTRIBUTING', '2': 3},
    {'1': 'ACTIVE', '2': 4},
    {'1': 'FAILED', '2': 5},
  ],
};

/// Descriptor for `MatrixStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixStatusDescriptor = $convert.base64Decode(
    'CgxNYXRyaXhTdGF0dXMSHwoLdHJhbnNmZXJfaWQYASABKAdSCnRyYW5zZmVySWQSNgoFc3RhZ2'
    'UYAiABKA4yIC5tZXNoX2ludGVyb3AuTWF0cml4U3RhdHVzLlN0YWdlUgVzdGFnZRIlCg5yZWNl'
    'aXZlZF9ieXRlcxgDIAEoDVINcmVjZWl2ZWRCeXRlcxIaCghyZXZpc2lvbhgEIAEoBFIIcmV2aX'
    'Npb24SJQoObWFzdGVyX3Nlc3Npb24YBSABKARSDW1hc3RlclNlc3Npb24SFAoFZXJyb3IYBiAB'
    'KAlSBWVycm9yEjQKBW5vZGVzGAcgAygLMh4ubWVzaF9pbnRlcm9wLk1hdHJpeE5vZGVTdGF0dX'
    'NSBW5vZGVzEh0KCm1hc3Rlcl9tYWMYCCABKAxSCW1hc3Rlck1hYyJaCgVTdGFnZRIICgRJRExF'
    'EAASDQoJUkVDRUlWSU5HEAESDgoKVkFMSURBVElORxACEhAKDERJU1RSSUJVVElORxADEgoKBk'
    'FDVElWRRAEEgoKBkZBSUxFRBAF');

@$core.Deprecated('Use animationLayerDescriptor instead')
const AnimationLayer$json = {
  '1': 'AnimationLayer',
  '2': [
    {'1': 'entry_id', '3': 1, '4': 1, '5': 13, '10': 'entryId'},
    {
      '1': 'effect',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.mesh_interop.MatrixEffect',
      '10': 'effect'
    },
    {'1': 'priority', '3': 4, '4': 1, '5': 13, '10': 'priority'},
    {'1': 'order', '3': 5, '4': 1, '5': 13, '10': 'order'},
    {
      '1': 'opaque_background',
      '3': 6,
      '4': 1,
      '5': 8,
      '10': 'opaqueBackground'
    },
  ],
  '9': [
    {'1': 3, '2': 4},
  ],
  '10': ['drivers'],
};

/// Descriptor for `AnimationLayer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List animationLayerDescriptor = $convert.base64Decode(
    'Cg5BbmltYXRpb25MYXllchIZCghlbnRyeV9pZBgBIAEoDVIHZW50cnlJZBIyCgZlZmZlY3QYAi'
    'ABKAsyGi5tZXNoX2ludGVyb3AuTWF0cml4RWZmZWN0UgZlZmZlY3QSGgoIcHJpb3JpdHkYBCAB'
    'KA1SCHByaW9yaXR5EhQKBW9yZGVyGAUgASgNUgVvcmRlchIrChFvcGFxdWVfYmFja2dyb3VuZB'
    'gGIAEoCFIQb3BhcXVlQmFja2dyb3VuZEoECAMQBFIHZHJpdmVycw==');

@$core.Deprecated('Use animationOutputMappingDescriptor instead')
const AnimationOutputMapping$json = {
  '1': 'AnimationOutputMapping',
  '2': [
    {
      '1': 'driver',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.mesh_interop.MatrixDriver',
      '10': 'driver'
    },
    {'1': 'from', '3': 2, '4': 1, '5': 13, '10': 'from'},
    {'1': 'to', '3': 3, '4': 1, '5': 13, '10': 'to'},
    {'1': 'source_index', '3': 4, '4': 1, '5': 13, '10': 'sourceIndex'},
  ],
};

/// Descriptor for `AnimationOutputMapping`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List animationOutputMappingDescriptor = $convert.base64Decode(
    'ChZBbmltYXRpb25PdXRwdXRNYXBwaW5nEjIKBmRyaXZlchgBIAEoDjIaLm1lc2hfaW50ZXJvcC'
    '5NYXRyaXhEcml2ZXJSBmRyaXZlchISCgRmcm9tGAIgASgNUgRmcm9tEg4KAnRvGAMgASgNUgJ0'
    'bxIhCgxzb3VyY2VfaW5kZXgYBCABKA1SC3NvdXJjZUluZGV4');

@$core.Deprecated('Use animationDefinitionsDescriptor instead')
const AnimationDefinitions$json = {
  '1': 'AnimationDefinitions',
  '2': [
    {'1': 'schema_version', '3': 1, '4': 1, '5': 13, '10': 'schemaVersion'},
    {'1': 'master_session', '3': 2, '4': 1, '5': 4, '10': 'masterSession'},
    {'1': 'revision', '3': 3, '4': 1, '5': 4, '10': 'revision'},
    {
      '1': 'layers',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.AnimationLayer',
      '10': 'layers'
    },
    {'1': 'gpio_inputs', '3': 5, '4': 3, '5': 13, '10': 'gpioInputs'},
    {'1': 'canvas_size', '3': 6, '4': 1, '5': 13, '10': 'canvasSize'},
    {
      '1': 'output_mappings',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.AnimationOutputMapping',
      '10': 'outputMappings'
    },
  ],
};

/// Descriptor for `AnimationDefinitions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List animationDefinitionsDescriptor = $convert.base64Decode(
    'ChRBbmltYXRpb25EZWZpbml0aW9ucxIlCg5zY2hlbWFfdmVyc2lvbhgBIAEoDVINc2NoZW1hVm'
    'Vyc2lvbhIlCg5tYXN0ZXJfc2Vzc2lvbhgCIAEoBFINbWFzdGVyU2Vzc2lvbhIaCghyZXZpc2lv'
    'bhgDIAEoBFIIcmV2aXNpb24SNAoGbGF5ZXJzGAQgAygLMhwubWVzaF9pbnRlcm9wLkFuaW1hdG'
    'lvbkxheWVyUgZsYXllcnMSHwoLZ3Bpb19pbnB1dHMYBSADKA1SCmdwaW9JbnB1dHMSHwoLY2Fu'
    'dmFzX3NpemUYBiABKA1SCmNhbnZhc1NpemUSTQoPb3V0cHV0X21hcHBpbmdzGAcgAygLMiQubW'
    'VzaF9pbnRlcm9wLkFuaW1hdGlvbk91dHB1dE1hcHBpbmdSDm91dHB1dE1hcHBpbmdz');

@$core.Deprecated('Use animationCommandDescriptor instead')
const AnimationCommand$json = {
  '1': 'AnimationCommand',
  '2': [
    {'1': 'master_session', '3': 1, '4': 1, '5': 4, '10': 'masterSession'},
    {'1': 'revision', '3': 2, '4': 1, '5': 4, '10': 'revision'},
    {'1': 'sequence', '3': 3, '4': 1, '5': 13, '10': 'sequence'},
    {'1': 'entry_id', '3': 4, '4': 1, '5': 13, '10': 'entryId'},
    {'1': 'effective_at_us', '3': 5, '4': 1, '5': 4, '10': 'effectiveAtUs'},
    {'1': 'stop', '3': 6, '4': 1, '5': 8, '10': 'stop'},
  ],
};

/// Descriptor for `AnimationCommand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List animationCommandDescriptor = $convert.base64Decode(
    'ChBBbmltYXRpb25Db21tYW5kEiUKDm1hc3Rlcl9zZXNzaW9uGAEgASgEUg1tYXN0ZXJTZXNzaW'
    '9uEhoKCHJldmlzaW9uGAIgASgEUghyZXZpc2lvbhIaCghzZXF1ZW5jZRgDIAEoDVIIc2VxdWVu'
    'Y2USGQoIZW50cnlfaWQYBCABKA1SB2VudHJ5SWQSJgoPZWZmZWN0aXZlX2F0X3VzGAUgASgEUg'
    '1lZmZlY3RpdmVBdFVzEhIKBHN0b3AYBiABKAhSBHN0b3A=');

@$core.Deprecated('Use animationStateDescriptor instead')
const AnimationState$json = {
  '1': 'AnimationState',
  '2': [
    {'1': 'entry_id', '3': 1, '4': 1, '5': 13, '10': 'entryId'},
    {'1': 'started_at_us', '3': 2, '4': 1, '5': 4, '10': 'startedAtUs'},
    {'1': 'active', '3': 3, '4': 1, '5': 8, '10': 'active'},
  ],
};

/// Descriptor for `AnimationState`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List animationStateDescriptor = $convert.base64Decode(
    'Cg5BbmltYXRpb25TdGF0ZRIZCghlbnRyeV9pZBgBIAEoDVIHZW50cnlJZBIiCg1zdGFydGVkX2'
    'F0X3VzGAIgASgEUgtzdGFydGVkQXRVcxIWCgZhY3RpdmUYAyABKAhSBmFjdGl2ZQ==');

@$core.Deprecated('Use animationSnapshotDescriptor instead')
const AnimationSnapshot$json = {
  '1': 'AnimationSnapshot',
  '2': [
    {'1': 'master_session', '3': 1, '4': 1, '5': 4, '10': 'masterSession'},
    {'1': 'revision', '3': 2, '4': 1, '5': 4, '10': 'revision'},
    {'1': 'sequence', '3': 3, '4': 1, '5': 13, '10': 'sequence'},
    {'1': 'activate_at_us', '3': 4, '4': 1, '5': 4, '10': 'activateAtUs'},
    {
      '1': 'states',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.AnimationState',
      '10': 'states'
    },
    {
      '1': 'pending',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.AnimationCommand',
      '10': 'pending'
    },
  ],
};

/// Descriptor for `AnimationSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List animationSnapshotDescriptor = $convert.base64Decode(
    'ChFBbmltYXRpb25TbmFwc2hvdBIlCg5tYXN0ZXJfc2Vzc2lvbhgBIAEoBFINbWFzdGVyU2Vzc2'
    'lvbhIaCghyZXZpc2lvbhgCIAEoBFIIcmV2aXNpb24SGgoIc2VxdWVuY2UYAyABKA1SCHNlcXVl'
    'bmNlEiQKDmFjdGl2YXRlX2F0X3VzGAQgASgEUgxhY3RpdmF0ZUF0VXMSNAoGc3RhdGVzGAUgAy'
    'gLMhwubWVzaF9pbnRlcm9wLkFuaW1hdGlvblN0YXRlUgZzdGF0ZXMSOAoHcGVuZGluZxgGIAMo'
    'CzIeLm1lc2hfaW50ZXJvcC5BbmltYXRpb25Db21tYW5kUgdwZW5kaW5n');
