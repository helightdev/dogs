import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_mongo_driver/dogs_mongo_driver.dart';
import 'package:dogs_odm/dogs_odm.dart';
import 'package:dogs_odm/query_dsl.dart';
import 'package:test/test.dart';

import 'common/person.dart';

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

void main() {
  DogEngine().withPersonStructure().setSingleton();
  group("Mongo", () {
    late Db db;
    late MongoOdmSystem system;
    late DbCollection collection;
    setUpAll(() async {
      db = await Db.create("mongodb://root:example@localhost:27017/");
      await db.open();
      system = MongoOdmSystem.fromDb(db);
      collection = db.collection("smoke_filter");
      await collection.drop();
      await collection.insert(house);
    });

    Future<int> count(FilterExpr expr) async {
      return await collection.count(MongoFilterParser.parse(expr, system));
    }

    test("EQ", () async {
      expect(count(eq("name", "House")), completion(1));
      expect(count(eq("name", "Homer")), completion(0));
    });

    test("EQ Person", () async {
      expect(
          count(eq<Person>("owner", Person(id: "0", name: "Homer", age: 40))),
          completion(1));
      expect(
          count(eq<Person>("owner", Person(id: "1", name: "Homer", age: 40))),
          completion(0));
    });

    test("NE", () async {
      expect(count(ne("name", "Homer")), completion(1));
      expect(count(ne("name", "House")), completion(0));
    });

    test("NE Person", () async {
      expect(
          count(ne<Person>("owner", Person(id: "1", name: "Homer", age: 40))),
          completion(1));
      expect(
          count(ne<Person>("owner", Person(id: "0", name: "Homer", age: 40))),
          completion(0));
    });

    test("LT", () async {
      expect(count(lt("size", 101)), completion(1));
      expect(count(lt("size", 100)), completion(0));
    });

    test("GT", () async {
      expect(count(gt("size", 99)), completion(1));
      expect(count(gt("size", 100)), completion(0));
    });

    test("LTE", () async {
      expect(count(lte("size", 100)), completion(1));
      expect(count(lte("size", 99)), completion(0));
    });

    test("GTE", () async {
      expect(count(gte("size", 100)), completion(1));
      expect(count(gte("size", 101)), completion(0));
    });

    test("AND", () async {
      expect(count(and([eq("name", "House"), eq("size", 100)])), completion(1));
      expect(count(and([eq("name", "House"), eq("size", 99)])), completion(0));
    });

    test("OR", () async {
      expect(count(or([eq("name", "House"), eq("size", 99)])), completion(1));
      expect(count(or([eq("name", "Homer"), eq("size", 99)])), completion(0));
    });

    test("EXISTS", () {
      expect(count(exists("size")), completion(1));
      expect(count(exists("size2")), completion(0));
      expect(count(exists("owner")), completion(1));
      expect(count(exists("owner2")), completion(0));
    });

    test("IN", () {
      expect(count(inArray("name", ["House", "House2"])), completion(1));
      expect(count(inArray("name", ["House2", "House3"])), completion(0));
    });

    test("NOT IN", () {
      expect(count(notInArray("name", ["House2", "House3"])), completion(1));
      expect(count(notInArray("name", ["House", "House2"])), completion(0));
    });

    test("ARRAY CONTAINS", () {
      expect(count(arrayContains("rooms", {"name": "Kitchen", "size": 20})),
          completion(1));
      expect(count(arrayContains("rooms", {"name": "Kitchen2", "size": 20})),
          completion(0));
    });

    test("ANY", () {
      expect(count(matcherArrayAny("rooms", eq("name", "Kitchen"))),
          completion(1));
      expect(count(matcherArrayAny("rooms", eq("name", "Bathroom"))),
          completion(0));
      expect(
          count(matcherArrayAny(
              "rooms", or([eq("name", "Kitchen"), eq("name", "Bathroom")]))),
          completion(1));
      expect(
          count(matcherArrayAny(
              "rooms", or([eq("name", "Bathroom"), eq("name", "Bathroom")]))),
          completion(0));
    });

    test("NESTED", () {
      expect(count(eq("address.street", "Main Street")), completion(1));
      expect(count(eq("address.street", "Second Street")), completion(0));
    });

    tearDownAll(() async {
      await collection.drop();
      await db.close();
    });
  });
}
