import 'dart:convert';

import 'package:benchmarks/dataclasses.dart';
import 'package:benchmarks/dogs.g.dart';
import 'package:benchmarks/serializables.dart';
import 'package:built_collection/built_collection.dart';
import 'package:dogs_core/dogs_core.dart';

void benchmarkIndexOf() {
  var count = 500;
  var iterations = 1000;
  print(
      "==== Running IndexOf Benchmarks ($count items, $iterations iterations)  ");
  var dogs = _runIndexOfBenchmark(dogMap, count, iterations);
  print("Dogs took $dogsμs (${dogs / 1000}ms)  ");
  var built = _runIndexOfBenchmark(builtMap, count, iterations);
  print("BuiltValue took $builtμs (${built / 1000}ms)  ");
  var equatable = _runIndexOfBenchmark(equatableMap, count, iterations);
  print("Equatable took $equatableμs (${equatable / 1000}ms)  ");
  var native = _runIndexOfBenchmark(nativeMap, count, iterations);
  print("Native took $nativeμs (${native / 1000}ms)  ");
}

void benchmarkDirectEquality() {
  var iterations = 1000000;
  print("==== Running DirectEquality Benchmarks ($iterations iterations)  ");
  var dogs = _runDirectEquality(dogMap, iterations);
  print("Dogs took $dogsμs (${dogs / 1000}ms)  ");
  var built = _runDirectEquality(builtMap, iterations);
  print("BuiltValue took $builtμs (${built / 1000}ms)  ");
  var equatable = _runDirectEquality(equatableMap, iterations);
  print("Equatable took $equatableμs (${equatable / 1000}ms)  ");
  var native = _runDirectEquality(nativeMap, iterations);
  print("Native took $nativeμs (${native / 1000}ms)  ");
}

void benchmarkMapKey() {
  var count = 500;
  var iterations = 1000;
  print(
      "==== Running MapKey Benchmarks ($count items, $iterations iterations)  ");
  var dogs = _runMapKeyBenchmark(dogMap, count, iterations);
  print("Dogs took $dogsμs (${dogs / 1000}ms)  ");
  var built = _runMapKeyBenchmark(builtMap, count, iterations);
  print("BuiltValue took $builtμs (${built / 1000}ms)  ");
  var equatable = _runMapKeyBenchmark(equatableMap, count, iterations);
  print("Equatable took $equatableμs (${equatable / 1000}ms)  ");
  var native = _runMapKeyBenchmark(nativeMap, count, iterations);
  print("Native took $nativeμs (${native / 1000}ms)  ");
}

void benchmarkJsonSerialization() {
  var count = 500;
  var iterations = 1000;
  print(
      "==== Running JsonSerialization Benchmarks ($count items, $iterations iterations)  ");
  var dogEngine = DogEngine.instance;
  var dogs = _runJsonEncodeBenchmark(dogPerson, (p) {
    return dogEngine.jsonEncode<DogPerson>(p);
  }, count, iterations);
  print("Dogs took $dogsμs (${dogs / 1000}ms)  ");
  var built = _runJsonEncodeBenchmark(builtPerson,
      (p) => jsonEncode(serializers.serialize(p)), count, iterations);
  print("Built took $builtμs (${built / 1000}ms)  ");
  var native = _runJsonEncodeBenchmark(
      nativePerson, (p) => jsonEncode(p.toMap()), count, iterations);
  print("Native took $nativeμs (${native / 1000}ms)  ");
}

void benchmarkJsonDeserialization() {
  var count = 500;
  var iterations = 1000;
  print(
      "==== Running JsonDeserialization Benchmarks ($count items, $iterations iterations)  ");
  var dogEngine = DogEngine.instance;
  var dogs = _runJsonDecodeBenchmark(dogPerson, (p) {
    return dogEngine.jsonEncode<DogPerson>(p);
  }, (s) {
    return dogEngine.jsonDecode<DogPerson>(s);
  }, count, iterations);
  print("Dogs took $dogsμs (${dogs / 1000}ms)  ");
  var built = _runJsonDecodeBenchmark(
      builtPerson, (p) => jsonEncode(serializers.serialize(p)), (s) {
    return serializers.deserialize(jsonDecode(s));
  }, count, iterations);
  print("Built took $builtμs (${built / 1000}ms)  ");
  var native =
      _runJsonDecodeBenchmark(nativePerson, (p) => jsonEncode(p.toMap()), (s) {
    return NativePerson.fromMap(jsonDecode(s));
  }, count, iterations);
  print("Native took $nativeμs (${native / 1000}ms)  ");
}

void benchmarkBuilders() {
  var count = 500;
  var iterations = 1000;
  print(
      "==== Running Builder Benchmarks ($count items, $iterations iterations)  ");
  var dogEngine = DogEngine.instance;
  var dogs = _runBuilderBenchmark(dogPerson, (a, b) {
    return a.rebuild((builder) => builder
      ..name = b.name
      ..tags = b.tags);
  }, count, iterations);
  print("Dogs took $dogsμs (${dogs / 1000}ms)  ");
  var built = _runBuilderBenchmark(builtPerson, (a, b) {
    return a.rebuild((builder) => builder
      ..name = b.name
      ..tags = ListBuilder<String>(b.tags));
  }, count, iterations);
  print("Built took $builtμs (${built / 1000}ms)  ");
}

// ----
int _runDirectEquality<T>(Map Function(int) generator, int iterations) {
  var stopwatch = Stopwatch();
  stopwatch.start();
  var list = generator(2).keys.toList();
  var a = list[0];
  var b = list[1];
  for (int i = 0; i < iterations; i++) {
    var _0 = a == a;
    var _1 = a == b;
  }
  stopwatch.stop();
  return stopwatch.elapsedMicroseconds;
}

int _runBuilderBenchmark<T>(T Function() generator, T Function(T, T) converter,
    int count, int iterations) {
  var stopwatch = Stopwatch();
  stopwatch.start();
  var list = List.generate(count, (index) => generator());
  for (int i = 0; i < iterations; i++) {
    for (int c = 1; c < count; c++) {
      converter(list[c - 1], list[c]);
    }
  }
  stopwatch.stop();
  return stopwatch.elapsedMicroseconds;
}

int _runJsonEncodeBenchmark<T>(T Function() generator,
    dynamic Function(T) converter, int count, int iterations) {
  var stopwatch = Stopwatch();
  stopwatch.start();
  var list = List.generate(count, (index) => generator());
  for (int i = 0; i < iterations; i++) {
    for (int c = 0; c < count; c++) {
      converter(list[c]);
    }
  }
  stopwatch.stop();
  return stopwatch.elapsedMicroseconds;
}

int _runJsonDecodeBenchmark<T>(
    T Function() generator,
    String Function(T) converter,
    dynamic Function(String) reconverter,
    int count,
    int iterations) {
  var stopwatch = Stopwatch();
  stopwatch.start();
  var list = List.generate(count, (index) => converter(generator()));
  for (int i = 0; i < iterations; i++) {
    for (int c = 0; c < count; c++) {
      reconverter(list[c]);
    }
  }
  stopwatch.stop();
  return stopwatch.elapsedMicroseconds;
}

int _runMapKeyBenchmark(
    Map Function(int) generator, int count, int iterations) {
  var map = generator(count);
  var keys = map.keys.toList();
  var stopwatch = Stopwatch();
  stopwatch.start();
  for (var i = 0; i < iterations; i++) {
    for (var c = 0; c < count; c++) {
      map[keys[c]];
    }
  }
  stopwatch.stop();
  return stopwatch.elapsedMicroseconds;
}

int _runIndexOfBenchmark(
    Map Function(int) generator, int count, int iterations) {
  var map = generator(count);
  var keys = map.keys.toList();
  var stopwatch = Stopwatch();
  stopwatch.start();
  for (var i = 0; i < iterations; i++) {
    for (var c = 0; c < count; c++) {
      keys.indexOf(keys[c]);
    }
  }
  stopwatch.stop();
  return stopwatch.elapsedMicroseconds;
}
