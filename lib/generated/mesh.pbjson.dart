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
  ],
};

/// Descriptor for `MatrixDriver`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List matrixDriverDescriptor = $convert.base64Decode(
    'CgxNYXRyaXhEcml2ZXISFgoSRFJJVkVSX1VOU1BFQ0lGSUVEEAASCgoGV1MyODEyEAESCQoFSE'
    'M1OTUQAg==');

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
  ],
  '4': [MatrixEffect_Kind$json],
};

@$core.Deprecated('Use matrixEffectDescriptor instead')
const MatrixEffect_Kind$json = {
  '1': 'Kind',
  '2': [
    {'1': 'EFFECT_UNSPECIFIED', '2': 0},
    {'1': 'STATIC_COLOR', '2': 1},
  ],
};

/// Descriptor for `MatrixEffect`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixEffectDescriptor = $convert.base64Decode(
    'CgxNYXRyaXhFZmZlY3QSDgoCaWQYASABKA1SAmlkEjMKBGtpbmQYAiABKA4yHy5tZXNoX2ludG'
    'Vyb3AuTWF0cml4RWZmZWN0LktpbmRSBGtpbmQSEAoDcmVkGAMgASgNUgNyZWQSFAoFZ3JlZW4Y'
    'BCABKA1SBWdyZWVuEhIKBGJsdWUYBSABKA1SBGJsdWUSFAoFYWxwaGEYBiABKA1SBWFscGhhEh'
    '8KC2R1cmF0aW9uX21zGAcgASgNUgpkdXJhdGlvbk1zIjAKBEtpbmQSFgoSRUZGRUNUX1VOU1BF'
    'Q0lGSUVEEAASEAoMU1RBVElDX0NPTE9SEAE=');

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
  ],
};

/// Descriptor for `MatrixSource`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixSourceDescriptor = $convert.base64Decode(
    'CgxNYXRyaXhTb3VyY2USDgoCaWQYASABKA1SAmlkEjMKBGtpbmQYAiABKA4yHy5tZXNoX2ludG'
    'Vyb3AuTWF0cml4U291cmNlLktpbmRSBGtpbmQSGQoIbm9kZV9tYWMYAyABKAxSB25vZGVNYWMS'
    'EgoEZ3BpbxgEIAEoDVIEZ3BpbxIWCgZyaXNpbmcYBSABKAhSBnJpc2luZyJACgRLaW5kEhYKEl'
    'NPVVJDRV9VTlNQRUNJRklFRBAAEhEKDURFRkFVTFRfU1RBVEUQARINCglHUElPX0VER0UQAg==');

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
  ],
  '4': [MatrixCondition_Kind$json],
};

@$core.Deprecated('Use matrixConditionDescriptor instead')
const MatrixCondition_Kind$json = {
  '1': 'Kind',
  '2': [
    {'1': 'CONDITION_UNSPECIFIED', '2': 0},
    {'1': 'ALWAYS', '2': 1},
  ],
};

/// Descriptor for `MatrixCondition`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixConditionDescriptor = $convert.base64Decode(
    'Cg9NYXRyaXhDb25kaXRpb24SDgoCaWQYASABKA1SAmlkEjYKBGtpbmQYAiABKA4yIi5tZXNoX2'
    'ludGVyb3AuTWF0cml4Q29uZGl0aW9uLktpbmRSBGtpbmQiLQoES2luZBIZChVDT05ESVRJT05f'
    'VU5TUEVDSUZJRUQQABIKCgZBTFdBWVMQAQ==');

@$core.Deprecated('Use matrixTargetDescriptor instead')
const MatrixTarget$json = {
  '1': 'MatrixTarget',
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
  ],
};

/// Descriptor for `MatrixTarget`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixTargetDescriptor = $convert.base64Decode(
    'CgxNYXRyaXhUYXJnZXQSGQoIbm9kZV9tYWMYASABKAxSB25vZGVNYWMSMgoGZHJpdmVyGAIgAS'
    'gOMhoubWVzaF9pbnRlcm9wLk1hdHJpeERyaXZlclIGZHJpdmVy');

@$core.Deprecated('Use matrixEntryDescriptor instead')
const MatrixEntry$json = {
  '1': 'MatrixEntry',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'effect_id', '3': 2, '4': 1, '5': 13, '10': 'effectId'},
    {'1': 'source_id', '3': 3, '4': 1, '5': 13, '10': 'sourceId'},
    {'1': 'condition_id', '3': 4, '4': 1, '5': 13, '10': 'conditionId'},
    {'1': 'priority', '3': 5, '4': 1, '5': 13, '10': 'priority'},
    {
      '1': 'targets',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.mesh_interop.MatrixTarget',
      '10': 'targets'
    },
  ],
};

/// Descriptor for `MatrixEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixEntryDescriptor = $convert.base64Decode(
    'CgtNYXRyaXhFbnRyeRIOCgJpZBgBIAEoDVICaWQSGwoJZWZmZWN0X2lkGAIgASgNUghlZmZlY3'
    'RJZBIbCglzb3VyY2VfaWQYAyABKA1SCHNvdXJjZUlkEiEKDGNvbmRpdGlvbl9pZBgEIAEoDVIL'
    'Y29uZGl0aW9uSWQSGgoIcHJpb3JpdHkYBSABKA1SCHByaW9yaXR5EjQKB3RhcmdldHMYBiADKA'
    'syGi5tZXNoX2ludGVyb3AuTWF0cml4VGFyZ2V0Ugd0YXJnZXRz');

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
  ],
};

/// Descriptor for `MatrixConfig`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matrixConfigDescriptor = $convert.base64Decode(
    'CgxNYXRyaXhDb25maWcSJQoOc2NoZW1hX3ZlcnNpb24YASABKA1SDXNjaGVtYVZlcnNpb24SNA'
    'oHZWZmZWN0cxgCIAMoCzIaLm1lc2hfaW50ZXJvcC5NYXRyaXhFZmZlY3RSB2VmZmVjdHMSNAoH'
    'c291cmNlcxgDIAMoCzIaLm1lc2hfaW50ZXJvcC5NYXRyaXhTb3VyY2VSB3NvdXJjZXMSPQoKY2'
    '9uZGl0aW9ucxgEIAMoCzIdLm1lc2hfaW50ZXJvcC5NYXRyaXhDb25kaXRpb25SCmNvbmRpdGlv'
    'bnMSMwoHZW50cmllcxgFIAMoCzIZLm1lc2hfaW50ZXJvcC5NYXRyaXhFbnRyeVIHZW50cmllcw'
    '==');

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
    'JvcnRCCwoJb3BlcmF0aW9u');

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
    {
      '1': 'drivers',
      '3': 3,
      '4': 3,
      '5': 14,
      '6': '.mesh_interop.MatrixDriver',
      '10': 'drivers'
    },
    {'1': 'priority', '3': 4, '4': 1, '5': 13, '10': 'priority'},
    {'1': 'order', '3': 5, '4': 1, '5': 13, '10': 'order'},
  ],
};

/// Descriptor for `AnimationLayer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List animationLayerDescriptor = $convert.base64Decode(
    'Cg5BbmltYXRpb25MYXllchIZCghlbnRyeV9pZBgBIAEoDVIHZW50cnlJZBIyCgZlZmZlY3QYAi'
    'ABKAsyGi5tZXNoX2ludGVyb3AuTWF0cml4RWZmZWN0UgZlZmZlY3QSNAoHZHJpdmVycxgDIAMo'
    'DjIaLm1lc2hfaW50ZXJvcC5NYXRyaXhEcml2ZXJSB2RyaXZlcnMSGgoIcHJpb3JpdHkYBCABKA'
    '1SCHByaW9yaXR5EhQKBW9yZGVyGAUgASgNUgVvcmRlcg==');

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
  ],
};

/// Descriptor for `AnimationDefinitions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List animationDefinitionsDescriptor = $convert.base64Decode(
    'ChRBbmltYXRpb25EZWZpbml0aW9ucxIlCg5zY2hlbWFfdmVyc2lvbhgBIAEoDVINc2NoZW1hVm'
    'Vyc2lvbhIlCg5tYXN0ZXJfc2Vzc2lvbhgCIAEoBFINbWFzdGVyU2Vzc2lvbhIaCghyZXZpc2lv'
    'bhgDIAEoBFIIcmV2aXNpb24SNAoGbGF5ZXJzGAQgAygLMhwubWVzaF9pbnRlcm9wLkFuaW1hdG'
    'lvbkxheWVyUgZsYXllcnMSHwoLZ3Bpb19pbnB1dHMYBSADKA1SCmdwaW9JbnB1dHM=');

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
