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

import 'package:benchmarks/dogs.g.dart';
import 'package:benchmarks/serializables.dart';
import 'package:benchmarks/system.dart';
import 'package:built_collection/built_collection.dart';
import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:dogs_core/dogs_core.dart';

class BuildersExercise extends Exercise<BuildersExercise,BuildersCompetitor> {
  BuildersExercise() : super(
      name: "Builders",
      options: {
        "count": 500,
      },
      competitors: [
        _DogsCompetitor(),
        _BuiltCompetitor(),
        _FreezedCompetitor(),
        _DartJsonMapperCompetitor(),
        _MappableCompetitor(),
      ]
  );

  @override
  void compete(BuildersCompetitor competitor, int iterations) {
    var count = options["count"] as int;
    var list = competitor._items;
    for (int i = 0; i < iterations; i++) {
      for (int c = 1; c < count; c++) {
        competitor.rebuild(list[c - 1], list[c]);
      }
    }
  }
}

abstract class BuildersCompetitor<T> extends ExerciseCompetitor<BuildersExercise,BuildersCompetitor> {
  BuildersCompetitor({required super.name});

  late List<T> _items;

  @override
  void teardown(BuildersExercise exercise) {}

  T generateItem(int index);

  T rebuild(T from, T to);

  @override
  void setup(BuildersExercise exercise) {
    _items = List.generate(exercise.options["count"] as int, (index) => generateItem(index));
  }
}

class _DogsCompetitor extends BuildersCompetitor<DogPerson> {

  _DogsCompetitor() : super(name: "dogs");

  @override
  DogPerson generateItem(int index) => dogPerson();

  @override
  DogPerson rebuild(DogPerson from, DogPerson to) {
    return from.rebuild((builder) => builder
      ..name = to.name
      ..tags = to.tags);
  }
}

class _BuiltCompetitor extends BuildersCompetitor<BuiltPerson> {

  _BuiltCompetitor() : super(name: "built");

  @override
  BuiltPerson generateItem(int index) => builtPerson();

  @override
  BuiltPerson rebuild(BuiltPerson from, BuiltPerson to) {
    return from.rebuild((builder) => builder
      ..name = to.name
      ..tags = ListBuilder<String>(to.tags));
  }
}

class _FreezedCompetitor extends BuildersCompetitor<FreezedPerson> {

  _FreezedCompetitor() : super(name: "freezed");

  @override
  FreezedPerson generateItem(int index) => freezedPerson();

  @override
  FreezedPerson rebuild(FreezedPerson from, FreezedPerson to) {
    return from.copyWith(name: to.name, tags: to.tags);
  }
}

class _DartJsonMapperCompetitor extends BuildersCompetitor<DartJsonMapperPerson> {

  _DartJsonMapperCompetitor() : super(name: "d_j_m");

  @override
  DartJsonMapperPerson generateItem(int index) => dartJsonMapperPerson();

  @override
  DartJsonMapperPerson rebuild(DartJsonMapperPerson from, DartJsonMapperPerson to) {
    return JsonMapper.copyWith<DartJsonMapperPerson>(from, {
      "name": to.name,
      "tags": to.tags,
    })!;
  }
}

class _MappableCompetitor extends BuildersCompetitor<MappablePerson> {

  _MappableCompetitor() : super(name: "mappable");

  @override
  MappablePerson generateItem(int index) => mappablePerson();

  @override
  MappablePerson rebuild(MappablePerson from, MappablePerson to) {
    return from.copyWith(name: to.name, tags: to.tags);
  }
}