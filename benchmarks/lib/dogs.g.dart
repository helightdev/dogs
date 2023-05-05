import 'package:benchmarks/dataclasses.conv.g.dart';
import 'package:benchmarks/serializables.conv.g.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:benchmarks/dataclasses.conv.g.dart' as gen0;
import 'package:benchmarks/serializables.conv.g.dart' as gen1;
export 'package:benchmarks/dataclasses.conv.g.dart';
export 'package:benchmarks/serializables.conv.g.dart';

Future initialiseDogs() async {
  var engine = DogEngine.hasValidInstance ? DogEngine.instance : DogEngine();
  engine.registerAllConverters(
      [gen0.DogBenchmarkDataclassEntityConverter(), gen1.DogPersonConverter()]);
  engine.setSingleton();
}
