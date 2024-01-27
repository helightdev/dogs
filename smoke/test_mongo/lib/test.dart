// Openapi Generator last run: : 2024-01-22T02:20:33.845832


import 'dart:io';

import 'package:dogs_odm/dogs_odm.dart';
import 'package:smoke_mongo/models.dart';
import 'package:dogs_mongo_driver/dogs_mongo_driver.dart';
import 'package:smoke_mongo/test_filter.dart';

import 'dogs.g.dart';

var personRepository = MongoRepository<Person,String>.plain();
var typeTestRepository = MongoRepository<TypeTestModel,String>.plain();
var houseRepository = MongoRepository<House,ObjectId>.plain();

late Db db;
late MongoOdmSystem system;

Future main() async {
  try {
    print("Start");
    await initialiseDogs();
    installOdmConverters();
    installMongoConverters();
    db = await Db.create("mongodb://root:example@localhost:27017/");
    await db.open();
    system = MongoOdmSystem.fromDb(db);
    print("Connected!");

    await testFilter();

    await personRepository.clear();
    await typeTestRepository.clear();
    await houseRepository.clear();

    print("Cleared!");
    await personRepository.save(Person(
      name: 'John',
      age: 42,
    ));
    await typeTestRepository.save(TypeTestModel(
      ObjectId(),
      Timestamp(),
      RegExp(r'^[a-z]*$'),
      DbRef('test', ObjectId()),
      JsCode('function() { return 42; }'),
    ));
    await houseRepository.save(House(
      name: 'House',
      size: 100,
      address: Address(
        street: 'Main Street',
        number: 1,
        city: 'Springfield',
        country: 'USA',
      ),
      owner: Resident(
        name: 'Homer',
        age: 40,
      ),
      rooms: [
        Room(
          name: 'Kitchen',
          size: 20,
        ),
        Room(
          name: 'Living Room',
          size: 30,
        ),
        Room(
          name: 'Bedroom',
          size: 15,
        ),
      ],
    ));
    var persons = await personRepository.findAll();
    var typeTests = await typeTestRepository.findAll();
    var houses = await houseRepository.findAll();
    print(persons);
    print(typeTests);
    print(houses);
  } catch (e, s) {
    await db.close();
    print(e);
    print(s);
    exit(1);
  }

  exit(0);
}
