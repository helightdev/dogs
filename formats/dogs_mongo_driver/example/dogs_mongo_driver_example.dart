import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_mongo_driver/dogs_mongo_driver.dart';
import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  DogEngine().setSingleton();
  var odm = await MongoOdmSystem.connect("mongodb://root:example@localhost:27017/");
}
