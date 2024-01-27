import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_odm/dogs_odm.dart';
import 'package:dogs_odm/memory/database.dart';
import 'package:dogs_odm/memory/odm.dart';
import 'package:dogs_odm/memory/repository.dart';
import 'package:dogs_odm/query_dsl.dart';
import 'package:test/test.dart';

import 'person_test.dart';


void main() {
  var engine = DogEngine();
  engine.setSingleton();
  engine.registerAutomatic(DogStructureConverterImpl<Person>(personStructure));
  group('Basic Tests', () {
    late MemoryOdmSystem system;
    late PersonRepository personRepository;
    setUp(() {
      system = MemoryOdmSystem();
      personRepository = PersonRepository();
      OdmSystem.register<MemoryOdmSystem>(system);
    });

    test('EQ', () async {
      await personRepository.saveAll([mary, john, henry]);
      var page = await personRepository.findAllByQuery(eq("name", "Mary"));
      expect(page, containsAll([mary]));
    });

    test('NE', () async {
      await personRepository.saveAll([mary, john, henry]);
      var page = await personRepository.findAllByQuery(ne("name", "Mary"));
      expect(page, containsAll([john, henry]));
    });

    test('GT', () async {
      await personRepository.saveAll([mary, john, henry]);
      var page = await personRepository.findAllByQuery(gt("age", 30));
      expect(page, containsAll([mary]));
    });

    test('LT', () async {
      await personRepository.saveAll([mary, john, henry]);
      var page = await personRepository.findAllByQuery(lt("age", 30));
      expect(page, containsAll([henry]));
    });

    test('GTE', () async {
      await personRepository.saveAll([mary, john, henry]);
      var page = await personRepository.findAllByQuery(gte("age", 30));
      expect(page, containsAll([mary, john]));
    });

    test('LTE', () async {
      await personRepository.saveAll([mary, john, henry]);
      var page = await personRepository.findAllByQuery(lte("age", 30));
      expect(page, containsAll([henry, john]));
    });

    test('AND', () async {
      await personRepository.saveAll([mary, john, henry]);
      var page = await personRepository.findAllByQuery(and([
        eq("name", "Mary"),
        eq("age", 40)
      ]));
      expect(page, containsAll([mary]));

      page = await personRepository.findAllByQuery(and([
        eq("name", "Mary"),
        eq("age", 30)
      ]));
      expect(page, isEmpty);
    });

    test('OR', () async {
      await personRepository.saveAll([mary, john, henry]);
      var page = await personRepository.findAllByQuery(or([
        eq("name", "Mary"),
        eq("age", 30)
      ]));
      expect(page, containsAll([mary, john]));

      page = await personRepository.findAllByQuery(or([
        eq("name", "Homer"),
        eq("age", 30)
      ]));
      expect(page, containsAll([john]));
    });
  });
}
