/*
 *    Copyright 2022, the DOGs authors
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_mongo_driver/dogs_mongo_driver.dart';
import 'package:dogs_odm/dogs_odm.dart';

@serializable
class Person with Dataclass<Person> {

  @Id()
  String? id;
  String name;
  int age;

  Person({
    this.id,
    required this.name,
    required this.age,
  });
}

@serializable
class TypeTestModel with Dataclass<TypeTestModel> {

  ObjectId? id;
  Timestamp timestamp;
  RegExp regex;
  DbRef? ref;
  JsCode? code;

  TypeTestModel(this.id, this.timestamp, this.regex, this.ref, this.code);
}

@serializable
class Resident with Dataclass<Resident>{
  String name;
  int age;

  Resident({
    required this.name,
    required this.age,
  });
}

@serializable
class Address with Dataclass<Address> {
  String street;
  int number;
  String city;
  String country;

  Address({
    required this.street,
    required this.number,
    required this.city,
    required this.country,
  });
}

@serializable
class Room with Dataclass<Room> {
  String name;
  int size;

  Room({
    required this.name,
    required this.size,
  });
}

@serializable
class House with Dataclass<House> {
  ObjectId? id;
  String name;
  int size;
  Address address;
  Resident owner;
  List<Room> rooms;

  House({
    this.id,
    required this.name,
    required this.size,
    required this.address,
    required this.owner,
    required this.rooms,
  });
}


@serializable
@LightweightMigration([
  MigratedEntity.replaceEmptyTitle
])
class MigratedEntity with Dataclass<MigratedEntity> {
  @Id()
  String? id;
  String title;
  String content;

  MigratedEntity(this.id, this.title, this.content);
  
  static replaceEmptyTitle(Map<String, dynamic> map, DogStructure structure, DogEngine engine) {
    if (map["title"] as String == "") {
      map["title"] = "Untitled";
    }
  }
}