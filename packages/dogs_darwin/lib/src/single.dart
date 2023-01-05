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

class DogsDarwinSingleMapper extends DarwinMapper<dynamic> {
  final Type type;
  final DogConverter converter;
  final DogEngine engine;

  DogsDarwinSingleMapper(this.type, this.converter, this.engine);

  @override
  bool checkDeserialize(DeserializationContext context) {
    return context.target == type;
  }

  @override
  bool checkSerialize(SerializationContext context) {
    return context.type == type;
  }

  @override
  dynamic deserialize(List<int> data, DeserializationContext context) {
    var graphValue = engine.jsonSerializer.deserialize(utf8.decode(data));
    return engine.convertObjectFromGraph(graphValue, type);
  }

  @override
  List<int> serialize(dynamic obj, SerializationContext context) {
    var graphValue = engine.convertObjectToGraph(obj, type);
    return utf8.encode(engine.jsonSerializer.serialize(graphValue));
  }
}
