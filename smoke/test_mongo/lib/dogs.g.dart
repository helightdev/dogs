import 'package:smoke_mongo/models.conv.g.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:smoke_mongo/models.conv.g.dart' as gen0;
export 'package:smoke_mongo/models.conv.g.dart';

Future initialiseDogs() async {
  var engine = DogEngine.hasValidInstance ? DogEngine.instance : DogEngine();
  engine.registerAllConverters([gen0.PersonConverter()]);
  engine.setSingleton();
}
