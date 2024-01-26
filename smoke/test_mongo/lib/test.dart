// Openapi Generator last run: : 2024-01-22T02:20:33.845832


import 'dart:io';

import 'package:smoke_mongo/models.dart';
import 'package:dogs_mongo_driver/dogs_mongo_driver.dart';
import 'package:smoke_mongo/test_filter.dart';

import 'dogs.g.dart';

class PersonRepository extends MongoRepository<Person, String> {}

var personRepository = PersonRepository();

late Db db;
late MongoOdmSystem system;

Future main() async {
  print("Start");
  await initialiseDogs();
  db = await Db.create("mongodb://root:example@localhost:27017/");
  await db.open();
  system = MongoOdmSystem.fromDb(db);
  print("Connected!");

  await testFilter();

  await personRepository.clear();
  print("Cleared!");
  await personRepository.save(Person(
    name: 'John',
    age: 42,
  ));
  var persons = await personRepository.findAll();
  print(persons);

  exit(0);
}
