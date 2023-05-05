import 'package:benchmarks/benchmarks.dart' as benchmarks;
import 'package:benchmarks/dogs.g.dart';
import 'package:dogs_core/dogs_core.dart';

void main(List<String> arguments) {
  initialiseDogs();
  benchmarks.benchmarkJsonSerialization();
  benchmarks.benchmarkJsonDeserialization();
  benchmarks.benchmarkBuilders();
  benchmarks.benchmarkIndexOf();
  benchmarks.benchmarkDirectEquality();
  benchmarks.benchmarkMapKey();
}
