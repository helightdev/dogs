/// Support for doing something awesome.
///
/// More dartdocs go here.
library dogs_cbor;

import 'dart:convert';

import 'package:cbor/cbor.dart' as cbor;
import 'package:cbor/cbor.dart';
import 'package:dogs_core/dogs_core.dart';

extension DogCborExtension on DogEngine {

  /// Converts a [value] to its Cbor representation using the
  /// converter associated with [T], [type] or [tree].
  List<int> toCbor<T>(T value,
      {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    final native = this.toNative<T>(value, kind: kind, type: type, tree: tree);
    return cbor.cborEncode(CborValue(native));
  }

  /// Converts Cbor supplied via [encoded] to its normal representation
  /// by using the converter associated with [T], [type] or [tree].
  T fromCbor<T>(List<int> encoded,
      {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    final native = cbor.cborDecode(encoded).toJson();
    return this.fromNative<T>(native, kind: kind, type: type, tree: tree);
  }

  /// Converts a [value] to its Cbor representation using the
  /// converter associated with [T], [type] or [tree]. Returns the result as a base64.
  String toCborString<T>(T value,
      {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    return base64Encode(toCbor<T>(value, kind: kind, type: type, tree: tree));
  }

  /// Converts Cbor supplied via [encoded] to its normal representation
  /// by using the converter associated with [T], [type] or [tree]. The [encoded] is
  /// expected to be a base64 encoded string.
  T fromCborString<T>(String encoded,
      {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    return fromCbor<T>(base64Decode(encoded),
        kind: kind, type: type, tree: tree);
  }
}
