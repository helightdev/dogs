import 'package:benchmarks/benchmarks.dart' as benchmarks;
import 'package:benchmarks/dogs.g.dart';
import 'package:benchmarks/serializables.dart';

void main(List<String> arguments) {
  initialiseDogs();
  initMappers();
  benchmarks.benchmarkJsonSerialization();
  benchmarks.benchmarkJsonDeserialization();
  benchmarks.benchmarkBuilders();
  benchmarks.benchmarkIndexOf();
  benchmarks.benchmarkDirectEquality();
  benchmarks.benchmarkMapKey();
}

void initMappers() {
  MappablePersonMapper.ensureInitialized();
}