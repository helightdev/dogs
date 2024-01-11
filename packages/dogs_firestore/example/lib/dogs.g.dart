import 'package:dogs_core/dogs_core.dart';
import 'package:example/models/person.conv.g.dart' as gen0;
import 'package:example/models/town.conv.g.dart' as gen1;
export 'package:example/models/person.conv.g.dart';
export 'package:example/models/town.conv.g.dart';

Future initialiseDogs() async {
  var engine = DogEngine.hasValidInstance ? DogEngine.instance : DogEngine();
  engine.registerAllConverters([gen0.PersonConverter(), gen1.TownConverter()]);
  engine.setSingleton();
}
