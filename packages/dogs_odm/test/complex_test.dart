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
import 'package:dogs_odm/dogs_odm.dart';
import 'package:dogs_odm/memory_db.dart';
import 'package:test/test.dart';

import 'person_test.dart';

class House {
  @Id()
  final String id;
  final String address;
  final List<Person> persons;

  House(this.id, this.address, this.persons);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is House &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          address == other.address &&
          deepEquality.equals(persons, other.persons);

  @override
  int get hashCode =>
      id.hashCode ^ address.hashCode ^ deepEquality.hash(persons);

  House copyWith({
    String? id,
    String? address,
    List<Person>? persons,
  }) {
    return House(
      id ?? this.id,
      address ?? this.address,
      persons ?? this.persons,
    );
  }
}

var houseStructure = DogStructure<House>(
    "House",
    StructureConformity.basic,
    [
      DogStructureField.string("id", annotations: [Id()]),
      DogStructureField.string("address"),
      DogStructureField.create<Person>("persons", iterable: IterableKind.list),
    ],
    [],
    ObjectFactoryStructureProxy<House>(
      (args) =>
          House(args[0] as String, args[1] as String, args[2] as List<Person>),
      [(obj) => obj.id, (obj) => obj.address, (obj) => obj.persons],
      (obj) => [obj.id, obj.address, obj.persons],
    ));

var parkerStreet = House("1", "Parker Street", [henry, john]);
var mainStreet = House("2", "Main Street", [john, mary]);

class HouseRepository extends MemoryRepository<House, String> {}

void main() {
  var engine = DogEngine();
  engine.setSingleton();
  engine.registerAutomatic(DogStructureConverterImpl<Person>(personStructure));
  engine.registerAutomatic(DogStructureConverterImpl<House>(houseStructure));
  group('House Tests', () {
    late MemoryOdmSystem system;
    late HouseRepository houseRepository;
    setUp(() {
      system = MemoryOdmSystem();
      houseRepository = HouseRepository();
      OdmSystem.register<MemoryOdmSystem>(system);
    });

    test('Encode & Decode', () async {
      await houseRepository.save(parkerStreet);
      await houseRepository.save(mainStreet);
      var houses = await houseRepository.findAll();

      expect(houses, containsAll([parkerStreet, mainStreet]));
      var house = await houseRepository.findById("1");
      expect(house, parkerStreet);
      await houseRepository.deleteById("1");
      houses = await houseRepository.findAll();
      expect(houses, containsAll([mainStreet]));
    });

    test("Update", () async {
      await houseRepository.save(parkerStreet);
      var house = await houseRepository.findById("1");
      expect(house, parkerStreet);
      var updatedHouse = house!.copyWith(address: "Parker Street 2", persons: [
        henry,
        john,
        mary,
      ]);
      var stored = await houseRepository.save(updatedHouse);
      expect(stored.persons, containsAll([henry, john, mary]));
      expect(stored.address, "Parker Street 2");
    });
  });
}