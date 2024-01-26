import 'package:dogs_mongo_driver/dogs_mongo_driver.dart';
import 'package:mongo_dart/mongo_dart.dart';

void main() async {
  var db = await Db.create("mongodb://root:example@localhost:27017/");
  var collection = db.collection("test");
}
