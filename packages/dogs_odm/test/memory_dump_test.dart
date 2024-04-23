import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_odm/dogs_odm.dart';
import 'package:dogs_odm/memory_db.dart';
import 'package:test/scaffolding.dart';
import 'package:test/test.dart';

import 'person_test.dart';

void main() {
  var engine = DogEngine();
  engine.setSingleton();
  engine.registerAutomatic(DogStructureConverterImpl<Person>(personStructure));
  group("Memory Dump Tests", () {
    late MemoryOdmSystem system;
    late PersonRepository personRepository;
    setUp(() {
      system = MemoryOdmSystem();
      personRepository = PersonRepository();
      OdmSystem.register<MemoryOdmSystem>(system);
    });

    test('Save & Save All', () async {
      personRepository.saveAll([henry, john, mary]);
      var josh = await personRepository.findById("99");
      expect(false, await personRepository.existsById("99"));
      expect(josh, null);
      var henryResult = await personRepository.findById("1");
      expect(henryResult, henry);
      expect(true, await personRepository.existsById("1"));

      // Dump and reload
      var jsonDump = system.createJsonDump();
      await personRepository.clear();
      expect(0, await personRepository.count());
      system.loadJsonDump(jsonDump);

      var all = await personRepository.findAll();
      expect(true, deepEquality.equals(all, [henry, john, mary]));
      expect(false, deepEquality.equals(all, [henry, john, mary, Person(name: "Me", age: 20)]));

      // Simulate fresh start
      system.reset();
      system.loadJsonDump(jsonDump);
      personRepository = PersonRepository();

      all = await personRepository.findAll();
      expect(true, deepEquality.equals(all, [henry, john, mary]));
      expect(false, deepEquality.equals(all, [henry, john, mary, Person(name: "Me", age: 20)]));
    });
  });
}