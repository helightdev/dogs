import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_mongo_driver/dogs_mongo_driver.dart';
import 'package:dogs_odm/dogs_odm.dart';
import 'package:dogs_odm/query_dsl.dart';
import 'package:test/test.dart';

import 'common/person.dart';

final items = List<Person>.generate(
    200,
        (index) => Person(
        id: ObjectId().oid,
        name: "Person $index",
        age: (index % 50) + 15)
);

void main() {
  print(items.join("\n"));
  DogEngine().withPersonStructure().setSingleton();
  group("Pagination", () {
    late Db db;
    late MongoOdmSystem system;
    late MongoRepository<Person,String> repository;
    setUpAll(() async {
      db = await Db.create("mongodb://root:example@localhost:27017/");
      await db.open();
      system = MongoOdmSystem.fromDb(db);
      repository = MongoRepository<Person,String>
          .plain(collectionName: "pagination_test");
      await repository.database.clear();
      await repository.saveAll(items);
    });

    test("Page Meta", () {
      var a = Page.fromData([], 0, 5, 20);
      var b = Page.fromData([], 5, 5, 20);
      var c = Page.fromData([], 15, 5, 20);
      expect(a.meta.number, 0);
      expect(b.meta.number, 1);
      expect(c.meta.number, 3);
      expect(a.meta.totalPages, 4);
    });

    test("DB Unsorted", () async {
      var database = repository.database;
      var a = await database.findPaginatedByQuery(Query.empty(), Sorted.empty(), skip: 0, limit: 4);
      expect(a[0].age, 15);
      expect(a[1].age, 16);
      expect(a[2].age, 17);
      expect(a[3].age, 18);
      expect(a.meta.totalPages, 50);
      expect(a.meta.totalElements, 200);
      expect(a.meta.number, 0);
      expect(a.meta.size, 4);

      var b = await database.findPaginatedByQuery(Query.empty(), Sorted.empty(), skip: 4, limit: 4);
      expect(b[0].age, 19);
      expect(b[1].age, 20);
      expect(b[2].age, 21);
      expect(b[3].age, 22);
      expect(b.meta.totalPages, 50);
      expect(b.meta.totalElements, 200);
      expect(b.meta.number, 1);
      expect(b.meta.size, 4);
    });

    test("DB Sorted", () async {
      var database = repository.database;
      var a = await database.findPaginatedByQuery(Query.empty(), Sorted.byField("age"), skip: 0, limit: 4);
      expect(a[0].age, 15);
      expect(a[1].age, 15);
      expect(a[2].age, 15);
      expect(a[3].age, 15);
      expect(a.meta.totalPages, 50);
      expect(a.meta.totalElements, 200);
      expect(a.meta.number, 0);
      expect(a.meta.size, 4);

      var b = await database.findPaginatedByQuery(Query.empty(), Sorted.byField("age"), skip: 4, limit: 4);
      expect(b[0].age, 16);
      expect(b[1].age, 16);
      expect(b[2].age, 16);
      expect(b[3].age, 16);
      expect(b.meta.totalPages, 50);
      expect(b.meta.totalElements, 200);
      expect(b.meta.number, 1);
      expect(b.meta.size, 4);
    });

    test("Repository", () async {
      var a = await repository.findPaginated(PageRequest(page: 0, size: 4));
      expect(a[0].age, 15);
      expect(a.meta.number, 0);
      var b = await repository.findPaginated(PageRequest(page: 1, size: 4));
      expect(b[0].age, 19);
      expect(b.meta.number, 1);
    });

    test("Repository Filtered", () async {
      var a = await repository.findPaginatedByQuery(
          eq("age", 19), PageRequest(page: 0, size: 4)
      );
      expect(a[0].age, 19);
      expect(a.meta.number, 0);
      expect(a.meta.totalPages, 1);
      expect(a.meta.totalElements, 4);

      var b = await repository.findPaginatedByQuery(
          Query.empty(), PageRequest(page: 1, size: 4),
        Sorted.byField("age", descending: true)
      );
      expect(b[0].age, 63);
      expect(b.meta.number, 1);
      expect(b.meta.totalPages, 50);
    });

    tearDownAll(() async {
      await repository.clear();
      await db.close();
    });
  });
}
