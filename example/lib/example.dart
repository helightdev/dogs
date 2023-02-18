import 'package:dogs_cbor/dogs_cbor.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_toml/dogs_toml.dart';
import 'package:dogs_yaml/dogs_yaml.dart';
import 'dogs.g.dart';
import 'models.dart';
export 'dogs.g.dart';

void main() async {
  await initialiseDogs();
  print(DogSchema.create().getApiJson());
  print("---");
  var person = Person(
      name: "Christoph",
      age: 19,
      notes: [Note("I love dart!", 0, DateTime.now(), [])],
      gender: Gender.male,
      birthdayDate: DateTime(2003, 11, 11)
  );

  var built = person.builder((builder) => builder
      ..name = "Günter"
  );

  print(built);
  print("---");

  testJson(person);
  print("---");
  testYaml(person);
  print("---");
  testCbor(person);
  print("---");
  testToml(person);
  print("---");
  testValidate();

  dogs.shutdown();
}

void testValidate() {
  print("TRUE ===");
  print(Person(name: "Gunter", age: 17, notes: [], gender: Gender.male, birthdayDate: DateTime.now()).isValid);
  print(Person(name: "Gunter", age: 17, notes: [Note("Test", 1, [], [1, 5, 7])], gender: Gender.male, birthdayDate: DateTime.now()).isValid);

  print("FALSE ===");
  print(Person(name: "", age: 17, notes: [], gender: Gender.male, birthdayDate: DateTime.now()).isValid);
  print(Person(name: "Gunter Mann", age: 17, notes: [], gender: Gender.male, birthdayDate: DateTime.now()).isValid);
  print(Person(name: "Gunter", age: 17, notes: [Note("Test", 1, [], [-1, 5, 7])], gender: Gender.male, birthdayDate: DateTime.now()).isValid);
}

void testJson(Person person) {
  var encoded = dogs.jsonEncode(person);
  print(encoded);
  Person decoded = dogs.jsonDecode(encoded);
  print(decoded);
}

void testYaml(Person person) {
  var encoded = dogs.yamlEncode(person);
  print(encoded);
  Person decoded = dogs.yamlDecode(encoded);
  print(decoded);
}

void testCbor(Person person) {
  var encoded = dogs.cborEncode(person);
  print(encoded.map((e) => e.toRadixString(16)).join(" "));
  Person decoded = dogs.cborDecode(encoded);
  print(decoded);
}

void testToml(Person person) {
  var encoded = dogs.tomlEncode(person);
  print(encoded);
  Person decoded = dogs.tomlDecode(encoded);
  print(decoded);
}

class TestValue {

}