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

import 'dart:convert';

import 'package:dogs/dogs.dart';

class DogJsonSerializer extends DogSerializer {
  @override
  DogGraphValue deserialize(value) {
    var decoded = jsonDecode(value);
    return DogGraphValue.fromNative(decoded);
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
  String jsonEncode<T>(dynamic value) {
    var graph = convertObjectToGraph(value, T);
    return _jsonSerializer.serialize(graph);
  }

  /// Async version of [jsonEncode].
  Future<String> jsonEncodeAsync<T>(dynamic value) {
    if (!asyncEnabled) return Future.value(jsonEncode<T>(value));
    return pool!.task((p0) async => await p0.encodeJson(value, T));
  }

  /// Decodes this [encoded] json to an [T] instance,
  /// using the [DogConverter] associated with [T].
  T jsonDecode<T>(String encoded) {
    var graph = _jsonSerializer.deserialize(encoded);
    return convertObjectFromGraph(graph, T);
  }

  /// Async version of [jsonDecode].
  Future<T> jsonDecodeAsync<T>(String encoded) {
    if (!asyncEnabled) return Future.value(jsonDecode<T>(encoded));
    return pool!.task((p0) async => await p0.decodeJson(encoded, T));
  }
}
