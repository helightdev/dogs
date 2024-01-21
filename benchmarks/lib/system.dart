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
import 'dart:developer';
import 'dart:io';

import 'package:vm_service/vm_service.dart';

class Benchmark {
  List<Exercise> exercises;

  Benchmark({
    required this.exercises,
  });

  void run() {
    print("Running benchmark");
    var results = <Map<String, Object>>[];
    for (var exercise in exercises) {
      print("Running exercise '${exercise.name}'");
      var result = exercise.perform();
      results.add(result);
      print(result.toString());
    }
    File("benchmark.json").writeAsStringSync(jsonEncode(results));
    print(results.toString());
  }
}

abstract class Exercise<T extends Exercise<T,C>, C extends ExerciseCompetitor<T,C>>  {
  String name;
  int warmupIterations;
  int iterations;
  Map<String,Object> options;
  List<C> competitors;

  Exercise({
    required this.name,
    this.competitors = const [],
    this.warmupIterations = 10,
    this.iterations = 1000,
    this.options = const {},
  });
  
  Map<String, Object> perform() {
    var times = runAll();
    return <String,Object>{
      "name": name,
      "iterations": iterations,
      "options": options,
      "times": times,
    };
  }
  
  Map<String, int> runAll() {
    var results = <String, int>{};
    for (var competitor in competitors) {
      var result = runBenchmark(competitor);
      results[competitor.name] = result;
    }
    return results;
  }

  void compete(C competitor, int iterations);

  int runBenchmark(C competitor) {
    competitor.setup(this as T);
    var stopwatch = Stopwatch();
    compete(competitor, warmupIterations);
    stopwatch.start();
    compete(competitor, iterations);
    stopwatch.stop();
    competitor.teardown(this as T);
    return stopwatch.elapsedMicroseconds;
  }
}

abstract class ExerciseCompetitor<T extends Exercise<T,C>, C extends ExerciseCompetitor<T,C>> {
  String name;

  ExerciseCompetitor({
    required this.name,
  });

  void setup(T exercise) {}
  void teardown(T exercise) {}
}