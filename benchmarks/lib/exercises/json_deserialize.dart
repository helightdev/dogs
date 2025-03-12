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
import 'package:dart_mappable/dart_mappable.dart';
import 'package:dogs_core/dogs_core.dart';

class JsonDeserializeExercise extends Exercise<JsonDeserializeExercise,JsonDeserializeCompetitor> {
  JsonDeserializeExercise() : super(
      name: "Json Deserialize",
      options: {
        "count": 500,
      },
      competitors: [
        _NativeCompetitor(),
        _JsonSerializableCompetitor(),
        //_DartJsonMapperCompetitor(),
        _FreezedCompetitor(),
        _DogsCompetitor(),
        _BuiltCompetitor(),
        _MappableCompetitor(),
      ]
  );

  @override
  void compete(JsonDeserializeCompetitor competitor, int iterations) {
    var count = options["count"] as int;
    var list = competitor._serialized;
    for (int i = 0; i < iterations; i++) {
      for (int c = 0; c < count; c++) {
        competitor.deserialize(list[c]);
      }
    }
  }
}

abstract class JsonDeserializeCompetitor<T> extends ExerciseCompetitor<JsonDeserializeExercise,JsonDeserializeCompetitor> {
  JsonDeserializeCompetitor({required super.name});

  late List<T> _items;
  late List<String> _serialized;

  @override
  void teardown(JsonDeserializeExercise exercise) {}

  T generateItem(int index);

  String serialize(T item);
  T deserialize(String json);

  @override
  void setup(JsonDeserializeExercise exercise) {
    _items = List.generate(exercise.options["count"] as int, (index) => generateItem(index));
    _serialized = _items.map((e) => serialize(e)).toList();
  }
}

class _DogsCompetitor extends JsonDeserializeCompetitor<DogPerson> {

  _DogsCompetitor() : super(name: "dogs");

  @override
  DogPerson generateItem(int index) => dogPerson();

  @override
  String serialize(DogPerson item) {
    return dogs.toJson<DogPerson>(item);
  }

  @override
  DogPerson deserialize(String json) {
    return dogs.fromJson<DogPerson>(json);
  }
}

class _JsonSerializableCompetitor extends JsonDeserializeCompetitor<JsonSerializablePerson> {

  _JsonSerializableCompetitor() : super(name: "json_ser");

  @override
  JsonSerializablePerson generateItem(int index) => jsonSerializablePerson();

  @override
  String serialize(JsonSerializablePerson item) {
    return jsonEncode(item.toJson());
  }

  @override
  JsonSerializablePerson deserialize(String json) {
    return JsonSerializablePerson.fromJson(jsonDecode(json));
  }
}

class _BuiltCompetitor extends JsonDeserializeCompetitor<BuiltPerson> {

  _BuiltCompetitor() : super(name: "built");

  @override
  BuiltPerson generateItem(int index) => builtPerson();

  @override
  String serialize(BuiltPerson item) {
    return jsonEncode(serializers.serialize(item));
  }

  @override
  BuiltPerson deserialize(String json) {
    return serializers.deserialize(jsonDecode(json)) as BuiltPerson;
  }

}

class _NativeCompetitor extends JsonDeserializeCompetitor<NativePerson> {

  _NativeCompetitor() : super(name: "native");

  @override
  NativePerson generateItem(int index) => nativePerson();

  @override
  String serialize(NativePerson item) {
    return jsonEncode(item.toMap());
  }

  @override
  NativePerson deserialize(String json) {
    return NativePerson.fromMap(jsonDecode(json));
  }
}

class _FreezedCompetitor extends JsonDeserializeCompetitor<FreezedPerson> {

  _FreezedCompetitor() : super(name: "freezed");

  @override
  FreezedPerson generateItem(int index) => freezedPerson();

  @override
  String serialize(FreezedPerson item) {
    return jsonEncode(item.toJson());
  }

  @override
  FreezedPerson deserialize(String json) {
    return FreezedPerson.fromJson(jsonDecode(json));
  }
}

class _MappableCompetitor extends JsonDeserializeCompetitor<MappablePerson> {

  _MappableCompetitor() : super(name: "mappable");

  @override
  MappablePerson generateItem(int index) => mappablePerson();

  @override
  String serialize(MappablePerson item) {
    return MapperContainer.globals.toJson<MappablePerson>(item);
  }

  @override
  MappablePerson deserialize(String json) {
    return MapperContainer.globals.fromJson<MappablePerson>(json);
  }
}