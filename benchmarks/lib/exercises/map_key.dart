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

class MapKeyExercise extends Exercise<MapKeyExercise, MapKeyCompetitor> {
  MapKeyExercise()
      : super(name: "Map Key", iterations: 1000, options: {
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
  void compete(MapKeyCompetitor competitor, int iterations) {
    var count = options["count"] as int;
    var map = competitor._map;
    var keys = competitor._keys;
    for (var i = 0; i < iterations; i++) {
      for (var c = 0; c < count; c++) {
        map[keys[c]];
      }
    }
  }
}

abstract class MapKeyCompetitor<T>
    extends ExerciseCompetitor<MapKeyExercise, MapKeyCompetitor> {
  MapKeyCompetitor({required super.name});

  late Map<T, int> _map;
  late List<T> _keys;

  @override
  void teardown(MapKeyExercise exercise) {}

  Map<T, int> generateItems(int count);

  @override
  void setup(MapKeyExercise exercise) {
    _map = generateItems(exercise.options["count"] as int);
    _keys = _map.keys.toList();
  }
}

class _DogsCompetitor extends MapKeyCompetitor<DogBenchmarkDataclassEntity> {
  _DogsCompetitor() : super(name: "dogs");

  @override
  Map<DogBenchmarkDataclassEntity, int> generateItems(int count) =>
      dogMap(count);
}

class _BuiltCompetitor extends MapKeyCompetitor<BuiltBenchmarkDataclassEntity> {
  _BuiltCompetitor() : super(name: "built");

  @override
  Map<BuiltBenchmarkDataclassEntity, int> generateItems(int count) =>
      builtMap(count);
}

class _EquatableCompetitor
    extends MapKeyCompetitor<EquatableBenchmarkDataclassEntity> {
  _EquatableCompetitor() : super(name: "equatable");

  @override
  Map<EquatableBenchmarkDataclassEntity, int> generateItems(int count) =>
      equatableMap(count);
}

class _NativeCompetitor
    extends MapKeyCompetitor<NativeBenchmarkDataclassEntity> {
  _NativeCompetitor() : super(name: "native");

  @override
  Map<NativeBenchmarkDataclassEntity, int> generateItems(int count) =>
      nativeMap(count);
}

class _FreezedCompetitor
    extends MapKeyCompetitor<FreezedBenchmarkDataclassEntity> {
  _FreezedCompetitor() : super(name: "freezed");

  @override
  Map<FreezedBenchmarkDataclassEntity, int> generateItems(int count) =>
      freezedMap(count);
}

class _MappableCompetitor
    extends MapKeyCompetitor<MappableBenchmarkDataclassEntity> {
  _MappableCompetitor() : super(name: "mappable");

  @override
  Map<MappableBenchmarkDataclassEntity, int> generateItems(int count) =>
      mappableMap(count);
}
