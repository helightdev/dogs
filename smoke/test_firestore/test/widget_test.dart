import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_firestore/dogs_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dogs_firestore/src/engine.dart';

import 'package:test_firestore/main.dart';
import 'package:test_firestore/models/person.conv.g.dart';
import 'package:test_firestore/models/person.dart';
import 'package:test_firestore/models/town.dart';

Future<void> main() async {
  await initialize();
  var fakeFirebaseFirestore = FakeFirebaseFirestore();
  DogFirestoreEngine.install(dogs, fakeFirebaseFirestore);
  group("Basic Tests", () {
    late Town town;
    late Person person;

    setUpAll(() async {
      var townInsert = await FirestoreEntity.get<Town>("amberg",
          orCreate: () => Town("Amberg", "de")
      );
      var personInsert = Person("Christoph", 20, DateTime(11, 11, 2003), Timestamp.now(), GeoPoint(51.165691, 10.451526));
      town = townInsert!;
      person = (await townInsert.$store(personInsert))!;
    });


    test("Read", () async {
      var resolved = await town.$get<Person>(person.id!);
      expect(resolved, isNotNull);
      expect(resolved!.id, isNotNull);
      expect(resolved.id, person.id);
    });
    
    // Query
    test("Query", () async {
      var a = await town.$query<Person>(query: (q) => q.where("age", isGreaterThan: 10));
      expect(a, isNotNull);
      expect(a.length, 1);
      expect(a.first.id, person.id);

      var b = await town.$query<Person>(query: (q) => q.where("age", isGreaterThan: 20));
      expect(b, isNotNull);
      expect(b.length, 0);
      expect(b.isEmpty, true);

      var c = await town.$query<Person>(query: (q) => q.where("age", isLessThan: 20));
      expect(c, isNotNull);
      expect(c.length, 0);
      expect(c.isEmpty, true);
    });

    // Save
test("Save", () async {
      var person2 = Person("Christoph", 20, DateTime(11, 11, 2003), Timestamp.now(), GeoPoint(51.165691, 10.451526));
      var person2Saved = await town.$store(person2);
      expect(person2Saved!.name, "Christoph");
      expect(person2Saved.age, 20);
      await person2Saved.rebuild((b) => b
        ..age = 21
        ..name = "Alex"
      ).save();
      var resolved = await town.$get<Person>(person2Saved.id!);
      expect(resolved, isNotNull);
      expect(resolved!.name, "Alex");
      expect(resolved.age, 21);
      await resolved.delete();
      expect(resolved.exists(), completion(false));
    });
  });
}
