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
import 'package:dogs_odm/memory_db.dart';
import 'package:dogs_odm/query_dsl.dart' as query;
import 'package:test/test.dart';

import 'person_test.dart';

final house = {
  "id": "1",
  "name": "House",
  "size": 100,
  "address": {
    "street": "Main Street",
    "number": 1,
    "city": "Springfield",
    "country": "USA"
  },
  "owner": {
    "id": "0",
    "name": "Homer",
    "age": 40,
  },
  "rooms": [
    {"name": "Kitchen", "size": 20},
    {"name": "Living Room", "size": 30},
    {"name": "Bedroom", "size": 15}
  ]
};

void main() {
  var engine = DogEngine();
  engine.setSingleton();
  engine.registerAutomatic(DogStructureConverterImpl<Person>(personStructure));
  var system = MemoryOdmSystem();

  group("Filter Tests", () {
    test("EQ", () {
      expect(true, MapMatcher.evaluate(query.eq("name", "House"), house, system));
      expect(false, MapMatcher.evaluate(query.eq("name", "Homer"), house, system));
      expect(true, MapMatcher.evaluate(query.eq<Person>("owner", Person(
        id: "0", name: "Homer", age: 40
      )), house, system));
      expect(false, MapMatcher.evaluate(query.eq<Person>("owner", Person(
        id: "1", name: "Homer", age: 40
      )), house, system));
    });
    test("NEQ", () {
      expect(false, MapMatcher.evaluate(query.ne("name", "House"), house, system));
      expect(true, MapMatcher.evaluate(query.ne("name", "Homer"), house, system));
      expect(false, MapMatcher.evaluate(query.ne<Person>("owner", Person(
        id: "0", name: "Homer", age: 40
      )), house, system));
      expect(true, MapMatcher.evaluate(query.ne<Person>("owner", Person(
        id: "1", name: "Homer", age: 40
      )), house, system));
    });
    test("LT", () {
      expect(false, MapMatcher.evaluate(query.lt("size", 100), house, system));
      expect(true, MapMatcher.evaluate(query.lt("size", 101), house, system));
      expect(false, MapMatcher.evaluate(query.lt("size", 99), house, system));
    });
    test("GT", () {
      expect(false, MapMatcher.evaluate(query.gt("size", 100), house, system));
      expect(false, MapMatcher.evaluate(query.gt("size", 101), house, system));
      expect(true, MapMatcher.evaluate(query.gt("size", 99), house, system));
    });
    test("LTE", () {
      expect(true, MapMatcher.evaluate(query.lte("size", 100), house, system));
      expect(true, MapMatcher.evaluate(query.lte("size", 101), house, system));
      expect(false, MapMatcher.evaluate(query.lte("size", 99), house, system));
    });
    test("GTE", () {
      expect(true, MapMatcher.evaluate(query.gte("size", 100), house, system));
      expect(false, MapMatcher.evaluate(query.gte("size", 101), house, system));
      expect(true, MapMatcher.evaluate(query.gte("size", 99), house, system));
    });
    test("EXISTS", () {
      expect(true, MapMatcher.evaluate(query.exists("size"), house, system));
      expect(false, MapMatcher.evaluate(query.exists("size2"), house, system));
      expect(true, MapMatcher.evaluate(query.exists("owner"), house, system));
      expect(false, MapMatcher.evaluate(query.exists("owner2"), house, system));
    });
    test("ALL", () {
      expect(true, MapMatcher.evaluate(query.all("rooms", [
        {"name": "Kitchen", "size": 20},
        {"name": "Living Room", "size": 30},
        {"name": "Bedroom", "size": 15}
      ]), house, system));
      expect(false, MapMatcher.evaluate(query.all("rooms", [
        {"name": "Kitchen", "size": 20},
        {"name": "Living Room", "size": 30},
        {"name": "Bedroom", "size": 15},
        {"name": "Bathroom", "size": 10}
      ]), house, system));
    });
    test("AND", () {
      expect(true, MapMatcher.evaluate(query.and([
        query.eq("name", "House"),
        query.eq("size", 100),
        query.exists("owner"),
        query.all("rooms", [
          {"name": "Kitchen", "size": 20},
          {"name": "Living Room", "size": 30},
          {"name": "Bedroom", "size": 15}
        ])
      ]), house, system));
      expect(false, MapMatcher.evaluate(query.and([
        query.eq("name", "House"),
        query.eq("size", 100),
        query.exists("owner"),
        query.all("rooms", [
          {"name": "Kitchen", "size": 20},
          {"name": "Living Room", "size": 30},
          {"name": "Bedroom", "size": 15},
          {"name": "Bathroom", "size": 10}
        ])
      ]), house, system));
    });
    test("OR", () {
      expect(true, MapMatcher.evaluate(query.or([
        query.eq("name", "House"),
        query.eq("name", "House2"),
      ]), house, system));
      expect(false, MapMatcher.evaluate(query.or([
        query.eq("name", "House2"),
        query.eq("name", "House3"),
      ]), house, system));
    });
    test("ANY", () {
      expect(true, MapMatcher.evaluate(query.any("rooms", query.eq("name", "Kitchen")), house, system));
      expect(false, MapMatcher.evaluate(query.any("rooms", query.eq("name", "Kitchen2")), house, system));
    });
    test("SUB MAP", () {
      expect(true, MapMatcher.evaluate(query.eq("address.city", "Springfield"), house, system));
      expect(false, MapMatcher.evaluate(query.eq("address.city", "Springfield2"), house, system));
    });
  });
}