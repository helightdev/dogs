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

import 'package:benchmarks/dataclasses.dart';
import 'package:benchmarks/system.dart';

class IndexOfExercise extends Exercise<IndexOfExercise, IndexOfCompetitor> {
  IndexOfExercise()
      : super(name: "Index Of", iterations: 1000, options: {
          "count": 500,
        }, competitors: [
          _NativeCompetitor(),
          _DogsCompetitor(),
          _BuiltCompetitor(),
          _EquatableCompetitor(),
          _FreezedCompetitor(),
          _MappableCompetitor(),
        ]);

  @override
  void compete(IndexOfCompetitor competitor, int iterations) {
    var count = options["count"] as int;
    var list = competitor._items;
    for (var i = 0; i < iterations; i++) {
      for (var c = 0; c < count; c++) {
        list.indexOf(list[c]);
      }
    }
  }
}

abstract class IndexOfCompetitor<T>
    extends ExerciseCompetitor<IndexOfExercise, IndexOfCompetitor> {
  IndexOfCompetitor({required super.name});

  late List<T> _items;

  @override
  void teardown(IndexOfExercise exercise) {}

  Map<T, int> generateItems(int count);

  @override
  void setup(IndexOfExercise exercise) {
    var items = generateItems(exercise.options["count"] as int);
    _items = items.keys.toList();
  }
}

class _DogsCompetitor extends IndexOfCompetitor<DogBenchmarkDataclassEntity> {
  _DogsCompetitor() : super(name: "dogs");

  @override
  Map<DogBenchmarkDataclassEntity, int> generateItems(int count) =>
      dogMap(count);
}

class _BuiltCompetitor
    extends IndexOfCompetitor<BuiltBenchmarkDataclassEntity> {
  _BuiltCompetitor() : super(name: "built");

  @override
  Map<BuiltBenchmarkDataclassEntity, int> generateItems(int count) =>
      builtMap(count);
}

class _EquatableCompetitor
    extends IndexOfCompetitor<EquatableBenchmarkDataclassEntity> {
  _EquatableCompetitor() : super(name: "equatable");

  @override
  Map<EquatableBenchmarkDataclassEntity, int> generateItems(int count) =>
      equatableMap(count);
}

class _NativeCompetitor
    extends IndexOfCompetitor<NativeBenchmarkDataclassEntity> {
  _NativeCompetitor() : super(name: "native");

  @override
  Map<NativeBenchmarkDataclassEntity, int> generateItems(int count) =>
      nativeMap(count);
}

class _FreezedCompetitor
    extends IndexOfCompetitor<FreezedBenchmarkDataclassEntity> {
  _FreezedCompetitor() : super(name: "freezed");

  @override
  Map<FreezedBenchmarkDataclassEntity, int> generateItems(int count) =>
      freezedMap(count);
}

class _MappableCompetitor
    extends IndexOfCompetitor<MappableBenchmarkDataclassEntity> {
  _MappableCompetitor() : super(name: "mappable");

  @override
  Map<MappableBenchmarkDataclassEntity, int> generateItems(int count) =>
      mappableMap(count);
}
