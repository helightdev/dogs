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

import 'package:benchmarks/serializables.dart';
import 'package:benchmarks/system.dart';
import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:dogs_core/dogs_core.dart';

class JsonSerializeExercise extends Exercise<JsonSerializeExercise,JsonSerializeCompetitor> {
  JsonSerializeExercise() : super(
    name: "Json Serialize",
    options: {
      "count": 500,
    },
    competitors: [
      _NativeCompetitor(),
      _JsonSerializableCompetitor(),
      _DartJsonMapperCompetitor(),
      _FreezedCompetitor(),
      _DogsCompetitor(),
      _BuiltCompetitor(),
      _MappableCompetitor(),
    ]
  );

  @override
  void compete(JsonSerializeCompetitor competitor, int iterations) {
    var count = options["count"] as int;
    var list = competitor._items;
    for (int i = 0; i < iterations; i++) {
      for (int c = 0; c < count; c++) {
        competitor.serialize(list[c]);
      }
    }
  }
}

abstract class JsonSerializeCompetitor<T> extends ExerciseCompetitor<JsonSerializeExercise,JsonSerializeCompetitor> {
  JsonSerializeCompetitor({required super.name});

  late List<T> _items;

  @override
  void teardown(JsonSerializeExercise exercise) {}
  
  T generateItem(int index);

  void serialize(T item);

  @override
  void setup(JsonSerializeExercise exercise) {
    _items = List.generate(exercise.options["count"] as int, (index) => generateItem(index));
  }
}

class _DogsCompetitor extends JsonSerializeCompetitor<DogPerson> {

  _DogsCompetitor() : super(name: "dogs");

  @override
  DogPerson generateItem(int index) => dogPerson();

  @override
  void serialize(DogPerson item) {
    dogs.jsonEncode<DogPerson>(item);
  }
}

class _JsonSerializableCompetitor extends JsonSerializeCompetitor<JsonSerializablePerson> {

  _JsonSerializableCompetitor() : super(name: "json_ser");

  @override
  JsonSerializablePerson generateItem(int index) => jsonSerializablePerson();

  @override
  void serialize(JsonSerializablePerson item) {
    jsonEncode(item.toJson());
  }
}

class _DartJsonMapperCompetitor extends JsonSerializeCompetitor<DartJsonMapperPerson> {

  _DartJsonMapperCompetitor() : super(name: "d_j_m");

  @override
  DartJsonMapperPerson generateItem(int index) => dartJsonMapperPerson();

  @override
  void serialize(DartJsonMapperPerson item) {
    JsonMapper.serialize(item);
  }
}

class _FreezedCompetitor extends JsonSerializeCompetitor<FreezedPerson> {

  _FreezedCompetitor() : super(name: "freezed");

  @override
  FreezedPerson generateItem(int index) => freezedPerson();

  @override
  void serialize(FreezedPerson item) {
    jsonEncode(item.toJson());
  }

}

class _BuiltCompetitor extends JsonSerializeCompetitor<BuiltPerson> {

  _BuiltCompetitor() : super(name: "built");

  @override
  BuiltPerson generateItem(int index) => builtPerson();

  @override
  void serialize(BuiltPerson item) {
    jsonEncode(serializers.serialize(item));
  }

}

class _NativeCompetitor extends JsonSerializeCompetitor<NativePerson> {

  _NativeCompetitor() : super(name: "native");

  @override
  NativePerson generateItem(int index) => nativePerson();

  @override
  void serialize(NativePerson item) {
    jsonEncode(item.toMap());
  }

}

class _MappableCompetitor extends JsonSerializeCompetitor<MappablePerson> {

  _MappableCompetitor() : super(name: "mappable");

  @override
  MappablePerson generateItem(int index) => mappablePerson();

  @override
  void serialize(MappablePerson item) {
    MapperContainer.globals.toJson<MappablePerson>(item);
  }
}