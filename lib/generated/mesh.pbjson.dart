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
