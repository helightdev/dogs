import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_odm/dogs_odm.dart';
import 'package:dogs_odm/memory/database.dart';
import 'package:dogs_odm/memory/odm.dart';
import 'package:dogs_odm/memory/repository.dart';
import 'package:test/test.dart';


void main() {
  var engine = DogEngine();
  engine.setSingleton();
  engine.registerAutomatic(DogStructureConverterImpl<Person>(personStructure));

  personMatrixGroup((systemFactory, repositoryFactory) {
    group("Basic Tests", () {
      late OdmSystem system;
      late dynamic personRepository;
      setUp(() {
        system = systemFactory();
        personRepository = repositoryFactory();
      });

      test('Save & Save All', () async {
        personRepository.saveAll([henry, john, mary]);
        var josh = await personRepository.findById("99");
        expect(false, await personRepository.existsById("99"));
        expect(josh, null);
        var henryResult = await personRepository.findById("1");
        expect(henryResult, henry);
        expect(true, await personRepository.existsById("1"));
        var all = await personRepository.findAll();
        expect(true, deepEquality.equals(all, [henry, john, mary]));
        expect(false, deepEquality.equals(all, [henry, john, mary, Person(name: "Me", age: 20)]));
      });

      test('Delete & Delete All', () async {
        personRepository.saveAll([henry, john, mary]);
        var all = await personRepository.findAll();
        expect(true, deepEquality.equals(all, [henry, john, mary]));
        await personRepository.deleteAll([henry, john]);
        all = await personRepository.findAll();
        expect(true, deepEquality.equals(all, [mary]));
      });

      test('Count & Clear', () async {
        personRepository.saveAll([henry, john, mary]);
        var count = await personRepository.count();
        expect(count, 3);
        await personRepository.deleteAll([henry, john]);
        count = await personRepository.count();
        expect(count, 1);
        await personRepository.clear();
        count = await personRepository.count();
        expect(count, 0);
      });

      test("ID Generation & Persistence", () async {
        var stored = await personRepository.save(Person(name: "Josh", age: 20));
        expect(stored.id, isNotNull);
        var stored2 = await personRepository.save(stored);
        expect(stored2.id, stored.id);
      });

      test("Update & Persistence", () async {
        var stored = await personRepository.save(Person(name: "Josh", age: 20));
        expect(stored.id, isNotNull);
        var stored2 = await personRepository.save(stored.copyWith(name: "Joshua"));
        expect(stored2.id, stored.id);
        expect(stored2.name, "Joshua");
        expect(stored2.age, stored.age);
      });
    });
  });
}


class Person {
  @Id()
  final String? id;
  final String name;
  final int age;

  Person({this.id, required this.name, required this.age});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Person &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          age == other.age;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ age.hashCode;

  Person copyWith({
    String? id,
    String? name,
    int? age,
  }) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
    );
  }

  @override
  String toString() {
    return 'Person{id: $id, name: $name, age: $age}';
  }
}

final DogStructure<Person> personStructure = DogStructure<Person>(
    "Person",
    StructureConformity.basic,
    [
      DogStructureField.string("id", optional: true, annotations: [Id()]),
      DogStructureField.string("name"),
      DogStructureField.int("age"),
    ],
    [],
    ObjectFactoryStructureProxy<Person>(
      (args) => Person(id: args[0] as String?, name: args[1] as String,
          age: args[2] as int),
      [
        (obj) => obj.id,
        (obj) => obj.name,
        (obj) => obj.age
      ],
      (obj) => [obj.id, obj.name, obj.age],
    ));

class PersonRepository extends MemoryRepository<Person, String> {}
class UniversalPersonRepository extends UniversalRepository<Person, String> {}

final List<(String, OdmSystem Function(), dynamic Function()) Function()> personMatrix = [
  () => ("Memory Repository", () {
    OdmSystem.reset();
    var system = MemoryOdmSystem();
    OdmSystem.register<MemoryOdmSystem>(system);
    return system;
  }, () => PersonRepository()),
  () => ("Universal Repository", () {
    OdmSystem.reset();
    var system = MemoryOdmSystem();
    OdmSystem.register<MemoryOdmSystem>(system);
    return system;
  }, () => UniversalPersonRepository()),
];

void personMatrixGroup(Function(OdmSystem Function() system, dynamic Function() repository) testFunc) {
  group("Person Matrix", () {
    for (var entry in personMatrix) {
      var (name,systemFactory,repositoryFactory) = entry();
      group(name, () {
        testFunc(systemFactory, repositoryFactory);
      });
    }
  });
}

final Person henry = Person(id: "1", name: "Henry", age: 20);
final Person john = Person(id: "2", name: "John", age: 30);
final Person mary = Person(id: "3", name: "Mary", age: 40);