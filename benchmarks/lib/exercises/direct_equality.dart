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

import 'package:benchmarks/dataclasses.dart';
import 'package:benchmarks/serializables.dart';
import 'package:benchmarks/system.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:dogs_core/dogs_core.dart';

class DirectEqualityExercise extends Exercise<DirectEqualityExercise,DirectEqualityCompetitor> {
  DirectEqualityExercise() : super(
    name: "Direct Equality",
    iterations: 1000000,
    competitors: [
      _NativeCompetitor(),
      _DogsCompetitor(),
      _BuiltCompetitor(),
      _EquatableCompetitor(),
      _FreezedCompetitor(),
      _MappableCompetitor(),
    ]
  );

  @override
  void compete(DirectEqualityCompetitor competitor, int iterations) {
    var list = competitor._items;
    var a = list[0];
    var b = list[1];
    for (int i = 0; i < iterations; i++) {
      var $0 = a == a;
      var $1 = a == b;
    }
  }
}

abstract class DirectEqualityCompetitor<T> extends ExerciseCompetitor<DirectEqualityExercise,DirectEqualityCompetitor> {
  DirectEqualityCompetitor({required super.name});

  late List<T> _items;

  @override
  void teardown(DirectEqualityExercise exercise) {}
  
  Map<T,int> generateItems(int count);

  @override
  void setup(DirectEqualityExercise exercise) {
    var items = generateItems(2);
    _items = [items.keys.first, items.keys.last];
  }
}

class _DogsCompetitor extends DirectEqualityCompetitor<DogBenchmarkDataclassEntity> {

  _DogsCompetitor() : super(name: "dogs");

  @override
  Map<DogBenchmarkDataclassEntity,int> generateItems(int count) => dogMap(count);
}

class _BuiltCompetitor extends DirectEqualityCompetitor<BuiltBenchmarkDataclassEntity> {

  _BuiltCompetitor() : super(name: "built");
  
  @override
  Map<BuiltBenchmarkDataclassEntity,int> generateItems(int count) => builtMap(count);

}

class _EquatableCompetitor extends DirectEqualityCompetitor<EquatableBenchmarkDataclassEntity> {

  _EquatableCompetitor() : super(name: "equatable");

  @override
  Map<EquatableBenchmarkDataclassEntity,int> generateItems(int count) => equatableMap(count);

}

class _NativeCompetitor extends DirectEqualityCompetitor<NativeBenchmarkDataclassEntity> {

  _NativeCompetitor() : super(name: "native");
  
  @override
  Map<NativeBenchmarkDataclassEntity,int> generateItems(int count) => nativeMap(count);

}

class _FreezedCompetitor extends DirectEqualityCompetitor<FreezedBenchmarkDataclassEntity> {

  _FreezedCompetitor() : super(name: "freezed");

  @override
  Map<FreezedBenchmarkDataclassEntity,int> generateItems(int count) => freezedMap(count);

}

class _MappableCompetitor extends DirectEqualityCompetitor<MappableBenchmarkDataclassEntity> {

  _MappableCompetitor() : super(name: "mappable");
  
  @override
  Map<MappableBenchmarkDataclassEntity,int> generateItems(int count) => mappableMap(count);
  
}