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

import 'dart:async';

import 'package:dogs_mongo_driver/dogs_mongo_driver.dart';
import 'package:smoke_mongo/test.dart';
import 'package:dogs_odm/query_dsl.dart' as query;

import 'models.dart';

final house = {
  "id": ObjectId(),
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

Future testFilter() async {
  var collection = db.collection("smoke_filter");
  await collection.drop();
  await collection.insert(house);

  await test("EQ", () async {
    expect(1, await collection.count(MongoFilterParser.parse(query.eq("name", "House"), system)));
    expect(0, await collection.count(MongoFilterParser.parse(query.eq("name", "Homer"), system)));
  });
  await test("EQ Person", () async {
    expect(1, await collection.count(MongoFilterParser.parse(query.eq<Person>("owner", Person(
      id: "0", name: "Homer", age: 40
    )), system)));
    expect(0, await collection.count(MongoFilterParser.parse(query.eq<Person>("owner", Person(
      id: "1", name: "Homer", age: 40
    )), system)));
  });
  await test("NE", () async {
    expect(1, await collection.count(MongoFilterParser.parse(query.ne("name", "Homer"), system)));
    expect(0, await collection.count(MongoFilterParser.parse(query.ne("name", "House"), system)));
  });
  await test("NE Person", () async {
    expect(1, await collection.count(MongoFilterParser.parse(query.ne<Person>("owner", Person(
      id: "1", name: "Homer", age: 40
    )), system)));
    expect(0, await collection.count(MongoFilterParser.parse(query.ne<Person>("owner", Person(
      id: "0", name: "Homer", age: 40
    )), system)));
  });
  await test("LT", () async {
    expect(1, await collection.count(MongoFilterParser.parse(query.lt("size", 101), system)));
    expect(0, await collection.count(MongoFilterParser.parse(query.lt("size", 100), system)));
  });
  await test("GT", () async {
    expect(1, await collection.count(MongoFilterParser.parse(query.gt("size", 99), system)));
    expect(0, await collection.count(MongoFilterParser.parse(query.gt("size", 100), system)));
  });
  await test("LTE", () async {
    expect(1, await collection.count(MongoFilterParser.parse(query.lte("size", 100), system)));
    expect(0, await collection.count(MongoFilterParser.parse(query.lte("size", 99), system)));
  });
  await test("GTE", () async {
    expect(1, await collection.count(MongoFilterParser.parse(query.gte("size", 100), system)));
    expect(0, await collection.count(MongoFilterParser.parse(query.gte("size", 101), system)));
  });
  await test("AND", () async {
    expect(1, await collection.count(MongoFilterParser.parse(query.and([
      query.eq("name", "House"),
      query.eq("size", 100)
    ]), system)));
    expect(0, await collection.count(MongoFilterParser.parse(query.and([
      query.eq("name", "House"),
      query.eq("size", 99)
    ]), system)));
  });
  await test("OR", () async {
    expect(1, await collection.count(MongoFilterParser.parse(query.or([
      query.eq("name", "House"),
      query.eq("size", 99)
    ]), system)));
    expect(0, await collection.count(MongoFilterParser.parse(query.or([
      query.eq("name", "Homer"),
      query.eq("size", 99)
    ]), system)));
  });
  /*
  await test("NOT", () async {
    expect(1, await collection.count(MongoFilter.parse(query.not(query.eq("name", "Homer")), system)));
    expect(0, await collection.count(MongoFilter.parse(query.not(query.eq("name", "House")), system)));
  });
   */
  await test("EXISTS", () async {
    expect(1, await collection.count(MongoFilterParser.parse(query.exists("name"), system)));
    expect(0, await collection.count(MongoFilterParser.parse(query.exists("notExisting"), system)));
  });
  await test("SUB MAP", () async {
    expect(1, await collection.count(MongoFilterParser.parse(query.eq("address.street", "Main Street"), system)));
    expect(0, await collection.count(MongoFilterParser.parse(query.eq("address.street", "Other Street"), system)));
  });
}

Future test(String name, FutureOr Function() func) async {
  await func();
}

void expect(dynamic expected, dynamic actual) {
  if (expected != actual) {
    throw Exception("Expected $expected, but was $actual");
  }
}