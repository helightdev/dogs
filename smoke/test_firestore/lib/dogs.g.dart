import 'package:test_firestore/models/person.conv.g.dart';
import 'package:test_firestore/models/town.conv.g.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:test_firestore/models/person.conv.g.dart' as gen0;
import 'package:test_firestore/models/town.conv.g.dart' as gen1;
export 'package:test_firestore/models/person.conv.g.dart';
export 'package:test_firestore/models/town.conv.g.dart';

Future initialiseDogs() async {
  var engine = DogEngine.hasValidInstance ? DogEngine.instance : DogEngine();
  engine.registerAllConverters([gen0.PersonConverter(), gen1.TownConverter()]);
  engine.setSingleton();
}
