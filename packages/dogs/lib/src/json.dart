/*
 *    Copyright 2022, the DOGs authors
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

import "dart:convert";
import "dart:convert" as conv;

import "package:dogs_core/dogs_core.dart";

// ignore: deprecated_member_use_from_same_package
class DogJsonSerializer extends DogSerializer {
  final codec = DefaultNativeCodec();

  @override
  DogGraphValue deserialize(value) {
    var decoded = jsonDecode(value);
    return codec.fromNative(decoded);
  }

  @override
  dynamic serialize(DogGraphValue value) {
    var native = value.coerceNative();
    return jsonEncode(native);
  }
}

extension DogJsonExtension on DogEngine {
  
  static final _jsonSerializer = DogJsonSerializer();

  @Deprecated("Serializers are deprecated. Just use toJson/fromJson methods")
  DogJsonSerializer get jsonSerializer => _jsonSerializer;

  /// Converts a [value] to its JSON representation using the
  /// converter associated with [T] or [tree].
  String toJson<T>(T value,
        {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    var native = this.toNative(value, kind: kind, type: type, tree: tree);
    return conv.jsonEncode(native);
  }

  /// Converts JSON supplied via [encoded] to its normal representation
  /// by using the converter associated with [T] or [tree].
  T fromJson<T>(String encoded, {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    var native = conv.jsonDecode(encoded);
    return this.fromNative(native, kind: kind, type: type, tree: tree);
  }

  @Deprecated("Use toJson")
  /// Encodes this [value] to json, using the [DogConverter] associated with [T].
  String jsonEncode<T>(T value) {
    var native = convertObjectToNative(value, T);
    return conv.jsonEncode(native);
  }

  @Deprecated("Use fromJson")
  /// Decodes this [encoded] json to an [T] instance,
  /// using the [DogConverter] associated with [T].
  T jsonDecode<T>(String encoded) {
    var native = conv.jsonDecode(encoded);
    return convertObjectFromNative(native, T);
  }

  @Deprecated("use fromJson")
  List<T> jsonDecodeList<T>(String encoded) {
    var graph = _jsonSerializer.deserialize(encoded);
    return convertIterableFromGraph(graph, T, IterableKind.list);
  }

  @Deprecated("use fromJson")
  Set<T> jsonDecodeSet<T>(String encoded) {
    var graph = _jsonSerializer.deserialize(encoded);
    return convertIterableFromGraph(graph, T, IterableKind.set);
  }

  @Deprecated("use toJson")
  String jsonEncodeList<T>(List<T> value) {
    var graph = convertIterableToGraph(value, T, IterableKind.list);
    return _jsonSerializer.serialize(graph);
  }

  @Deprecated("use toJson")
  String jsonEncodeSet<T>(Set<T> value) {
    var graph = convertIterableToGraph(value, T, IterableKind.set);
    return _jsonSerializer.serialize(graph);
  }
}
