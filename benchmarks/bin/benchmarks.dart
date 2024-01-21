import 'package:benchmarks/benchmarks.dart' as benchmarks;
import 'package:benchmarks/dogs.g.dart';
import 'package:benchmarks/exercises/builders.dart';
import 'package:benchmarks/exercises/direct_equality.dart';
import 'package:benchmarks/exercises/index_of.dart';
import 'package:benchmarks/exercises/json_deserialize.dart';
import 'package:benchmarks/exercises/json_serialize.dart';
import 'package:benchmarks/exercises/map_key.dart';
import 'package:benchmarks/serializables.dart';
import 'package:benchmarks/system.dart';

import 'benchmarks.mapper.g.dart';

void main(List<String> arguments) {
  initialiseDogs();
  initMappers();
  initializeJsonMapper();

  var benchmarkReactor = Benchmark(exercises: [
    JsonSerializeExercise(),
    JsonDeserializeExercise(),
    BuildersExercise(),
    DirectEqualityExercise(),
    IndexOfExercise(),
    MapKeyExercise()
  ]);
  benchmarkReactor.run();
  return;
}

void initMappers() {
  MappablePersonMapper.ensureInitialized();
}