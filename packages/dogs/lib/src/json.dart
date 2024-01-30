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

  DogJsonSerializer get jsonSerializer => _jsonSerializer;

  /// Encodes this [value] to json, using the [DogConverter] associated with [T].
  String jsonEncode<T>(T value) {
    var native = convertObjectToNative(value, T);
    return conv.jsonEncode(native);
  }

  String jsonEncodeList<T>(List<T> value) {
    var graph = convertIterableToGraph(value, T, IterableKind.list);
    return _jsonSerializer.serialize(graph);
  }

  String jsonEncodeSet<T>(Set<T> value) {
    var graph = convertIterableToGraph(value, T, IterableKind.set);
    return _jsonSerializer.serialize(graph);
  }

  /// Decodes this [encoded] json to an [T] instance,
  /// using the [DogConverter] associated with [T].
  T jsonDecode<T>(String encoded) {
    var native = conv.jsonDecode(encoded);
    return convertObjectFromNative(native, T);
  }

  List<T> jsonDecodeList<T>(String encoded) {
    var graph = _jsonSerializer.deserialize(encoded);
    return convertIterableFromGraph(graph, T, IterableKind.list);
  }

  Set<T> jsonDecodeSet<T>(String encoded) {
    var graph = _jsonSerializer.deserialize(encoded);
    return convertIterableFromGraph(graph, T, IterableKind.set);
  }
}
