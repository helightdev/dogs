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
import 'package:dogs_mongo_driver/dogs_mongo_driver.dart';
import 'package:dogs_odm/dogs_odm.dart';

class Person {
  @Id()
  final String? id;
  final String name;
  final int age;

  Person({this.id, required this.name, required this.age});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Person &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              age == other.age;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ age.hashCode;

  Person copyWith({
    String? id,
    String? name,
    int? age,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
    );
  }

  @override
  String toString() {
    return 'Person{id: $id, name: $name, age: $age}';
  }
}

final personA = Person(name: "Adam", age: 20);
final personB = Person(name: "Bert", age: 30);
final personC = Person(name: "Oliver", age: 20);
final personD = Person(name: "John", age: 40);

final persons = [personA, personB, personC];

final DogStructure<Person> personStructure = DogStructure<Person>(
    "Person",
    StructureConformity.basic,
    [
      DogStructureField.string("id", optional: true, annotations: [Id()]),
      DogStructureField.string("name"),
      DogStructureField.int("age"),
    ],
    [],
    ObjectFactoryStructureProxy<Person>(
          (args) => Person(id: args[0] as String?, name: args[1] as String,
          age: args[2] as int),
      [
            (obj) => obj.id,
            (obj) => obj.name,
            (obj) => obj.age
      ],
          (obj) => [obj.id, obj.name, obj.age],
    ));

extension InstallPerson on DogEngine {
  DogEngine withPersonStructure() {
    registerAutomatic(DogStructureConverterImpl<Person>(personStructure));
    return this;
  }
}