import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_mongo_driver/dogs_mongo_driver.dart';
import 'package:dogs_odm/dogs_odm.dart';
import 'package:dogs_odm/query_dsl.dart';
import 'package:test/test.dart';

import 'common/person.dart';

void main() {
  DogEngine()
      .withPersonStructure()
      .setSingleton();
  group("Repositories", () {
    late Db db;
    late MongoOdmSystem system;
    late DbCollection collection;
    setUpAll(() async {
      db = await Db.create("mongodb://root:example@localhost:27017/");
      await db.open();
      system = MongoOdmSystem.fromDb(db);
      await personRepository.database.clear();
    });

    setUp(() async {
      await personRepository.database.clear();
    });

    test("Save / Find / Delete", () async {
      expect(personA.id, isNull);
      expect(personB.id, isNull);
      var sa = await personRepository.save(personA);
      var sb = await personRepository.save(personB);
      expect(sa.id, isNotNull);
      expect(sb.id, isNotNull);
      expect(personRepository.findById(sa.id!), completion(sa));
      expect(personRepository.findById(sb.id!), completion(sb));
      await personRepository.delete(sa);
      expect(personRepository.findById(sa.id!), completion(null));
      await personRepository.deleteById(sb.id!);
      expect(personRepository.findById(sb.id!), completion(null));
    });

    test("Save All / Find All / Delete All", () async {
      var stored = await personRepository.saveAll(persons);
      expect(personRepository.findAll(), completion(stored));
      await personRepository.deleteAll([stored[0], stored[1]]);
      expect(personRepository.findAll(), completion([stored[2]]));
    });

    test("Count / Exists", () async {
      var stored = await personRepository.saveAll(persons);
      expect(personRepository.count(), completion(3));
      expect(personRepository.existsById(stored[0].id!), completion(true));
      expect(personRepository.existsById(ObjectId().oid), completion(false));
    });

    test("Query Simple", () async{
      var stored = await personRepository.saveAll(persons);
      var [a,b,c] = stored;
      expect(personRepository.findAllByQuery(eq("name", "Adam")), completion([a]));
      expect(personRepository.findAllByQuery(eq("age", 20)), completion([a,c]));
      expect(personRepository.countByQuery(eq("age", 20)), completion(2));
      personRepository.deleteAllByQuery(eq("age", 20));
      expect(personRepository.findAll(), completion([b]));
    });

    test("Query Complex", () async{
      var stored = await personRepository.saveAll(persons);
      var [a,b,c] = stored;
      expect(personRepository.findAllByQuery(
          eq("age", 20) & eq("name", "Adam")
      ), completion([a]));
      expect(personRepository.findAllByQuery(
          eq("age", 20) | eq("name", "Bert")
      ), completion([a,b,c]));
    });

    tearDownAll(() async {
      personRepository.database.clear();
      await db.close();
    });
  });
}
