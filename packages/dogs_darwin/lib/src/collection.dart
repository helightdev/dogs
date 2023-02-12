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

import 'package:darwin_marshal/darwin_marshal.dart';
import 'package:dogs_core/dogs_core.dart';

class DogsDarwinCollectionMapper extends DarwinMapper<dynamic> {
  final Type type;
  final DogConverter converter;
  final DogEngine engine;

  late Type listType;
  late Type setType;
  late Type iterableType;

  DogsDarwinCollectionMapper(this.type, this.converter, this.engine) {
    listType = converter.deriveList;
    setType = converter.deriveSet;
  }

  IterableKind getIterableKind(Type type) {
    if (type == listType) return IterableKind.list;
    return IterableKind.set;
  }

  @override
  bool checkDeserialize(DeserializationContext context) {
    return context.target == listType || context.target == setType;
  }

  @override
  bool checkSerialize(SerializationContext context) {
    return context.type == listType || context.type == setType;
  }

  @override
  dynamic deserialize(List<int> data, DeserializationContext context) {
    var kind = getIterableKind(context.target);
    var graphValue = engine.jsonSerializer.deserialize(utf8.decode(data));
    var mapped = (graphValue.asList!)
        .value
        .map((e) => engine.convertObjectFromGraph(e, type));
    var converted = adjustIterable(mapped, kind);
    return converted;
  }

  @override
  List<int> serialize(dynamic obj, SerializationContext context) {
    var mapped =
        (obj as Iterable).map((e) => engine.convertObjectToGraph(e, type));
    var graphValue = DogList(mapped.toList());
    return utf8.encode(engine.jsonSerializer.serialize(graphValue));
  }
}
