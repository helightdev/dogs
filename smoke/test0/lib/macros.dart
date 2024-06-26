import 'package:dogs_core/dogs_core.dart';
import 'package:test/test.dart';

void testMacros() {
  final engine = DogEngine();
  engine.registerAutomatic(Person.converter);

  test("Simple Serialization", () {
    final person = Person(name: "Christoph", age: 19);
    final json = engine.toJson<Person>(person);
    expect(json, """{"name":"Christoph","age":19}""");
    final person2 = engine.fromJson<Person>(json);
    expect(person2, person);
  });

  test("CopyWith", () {
    final person = Person(name: "Christoph", age: 19);
    final person2 = person.copyWith(name: "Adam");
    expect(person2, Person(name: "Adam", age: 19));
  });

  test("Rebuild", () {
    final person = Person(name: "Christoph", age: 19);
    final person2 = person.rebuild((p0) => p0..name = "Adam");
    expect(person2, Person(name: "Adam", age: 19));
  });

  test("Meta Annotation", () {
    print(Person.structure.annotations);
    expect(Person.structure.annotations.whereType<CustomAnnotation>().length, 1);
  });
}

@Model()
class Person {
  final String name;
  final int age;
}

class CustomAnnotation implements StructureMetadata {
  final String name;
  const CustomAnnotation(this.name);
}