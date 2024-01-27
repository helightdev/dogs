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
    late MongoRepository<Person, String> repository;
    setUpAll(() async {
      db = await Db.create("mongodb://root:example@localhost:27017/");
      await db.open();
      system = MongoOdmSystem.fromDb(db);
      repository = MongoRepository<Person,String>
          .plain(collectionName: "repository_test");
      await repository.clear();
    });

    setUp(() async {
      await repository.database.clear();
    });

    test("Save / Find / Delete", () async {
      expect(personA.id, isNull);
      expect(personB.id, isNull);
      var sa = await repository.save(personA);
      var sb = await repository.save(personB);
      expect(sa.id, isNotNull);
      expect(sb.id, isNotNull);
      expect(repository.findById(sa.id!), completion(sa));
      expect(repository.findById(sb.id!), completion(sb));
      await repository.delete(sa);
      expect(repository.findById(sa.id!), completion(null));
      await repository.deleteById(sb.id!);
      expect(repository.findById(sb.id!), completion(null));
    });

    test("Save All / Find All / Delete All", () async {
      var stored = await repository.saveAll(persons);
      expect(repository.findAll(), completion(stored));
      await repository.deleteAll([stored[0], stored[1]]);
      expect(repository.findAll(), completion([stored[2]]));
    });

    test("Count / Exists", () async {
      var stored = await repository.saveAll(persons);
      expect(repository.count(), completion(3));
      expect(repository.existsById(stored[0].id!), completion(true));
      expect(repository.existsById(ObjectId().oid), completion(false));
    });

    test("Query Simple", () async{
      var stored = await repository.saveAll(persons);
      var [a,b,c] = stored;
      expect(repository.findAllByQuery(eq("name", "Adam")), completion([a]));
      expect(repository.findAllByQuery(eq("age", 20)), completion([a,c]));
      expect(repository.countByQuery(eq("age", 20)), completion(2));
      repository.deleteAllByQuery(eq("age", 20));
      expect(repository.findAll(), completion([b]));
    });

    test("Query Complex", () async{
      var stored = await repository.saveAll(persons);
      var [a,b,c] = stored;
      expect(repository.findAllByQuery(
          eq("age", 20) & eq("name", "Adam")
      ), completion([a]));
      expect(repository.findAllByQuery(
          eq("age", 20) | eq("name", "Bert")
      ), completion([a,b,c]));
    });

    tearDownAll(() async {
      await repository.clear();
      await db.close();
    });
  });
}