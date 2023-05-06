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
// ignore_for_file: invalid_use_of_internal_member

import 'dart:convert';

import 'package:darwin_marshal/darwin_marshal.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:lyell/src/lyell_base.dart';

class DogsMarshal {
  static void link(DarwinMarshal marshal, [DogEngine? engineOverride]) {
    var engine = engineOverride ?? DogEngine.instance;
    engine.structures.forEach((key, value) {
      print("Linking for $key");
      marshal.registerMultiple(DogMarshalDirectMapper(value, engine));
    });
  }
}

class DogMarshalDirectMapper extends SimpleSerialMultiAdapter {
  final DogEngine engine;
  final TypeCapture capture;
  DogMarshalDirectMapper(this.capture, this.engine);

  @override
  Iterable? deserializeMultiple(
      List<int> data, DeserializationContext context) {
    if (data.isEmpty) return [];
    var str = utf8.decode(data);
    var graph = engine.jsonSerializer.deserialize(str);
    return engine.convertIterableFromGraph(
        graph, capture.typeArgument, IterableKind.list);
  }

  @override
  deserializeSingle(List<int> data, DeserializationContext context) {
    if (data.isEmpty) return [];
    var str = utf8.decode(data);
    var graph = engine.jsonSerializer.deserialize(str);
    return engine.convertObjectFromGraph(graph, capture.typeArgument);
  }

  @override
  List<int> serializeMultiple(Iterable? obj, SerializationContext context) {
    context.mime ??= "application/json";
    if (obj == null) return [];
    var graph = engine.convertIterableToGraph(
        obj, capture.typeArgument, IterableKind.list);
    var json = engine.jsonSerializer.serialize(graph);
    return utf8.encode(json);
  }

  @override
  List<int> serializeSingle(obj, SerializationContext context) {
    context.mime ??= "application/json";
    if (obj == null) return [];
    var graph = engine.convertObjectToGraph(obj, capture.typeArgument);
    var json = engine.jsonSerializer.serialize(graph);
    return utf8.encode(json);
  }

  @override
  TypeCapture get typeCapture => capture;
}
