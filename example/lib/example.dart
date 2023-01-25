import 'package:dogs_cbor/dogs_cbor.dart';
import 'package:dogs_toml/dogs_toml.dart';
import 'package:dogs_yaml/dogs_yaml.dart';
import 'dogs.g.dart';
import 'models.dart';
export 'dogs.g.dart';

void main() async {
  await initialiseDogs();
  print(DogSchema.create().getApiJson());

  var person = Person(
      name: "Christoph",
      age: 19,
      notes: [Note("I love dart!", 0, DateTime.now())],
      gender: Gender.male,
      birthdayDate: DateTime(2003, 11, 11)
  );

  var built = person.builder((builder) => builder
      ..name = "Günter"
  );

  print(built);

  testJson(person);
  testYaml(person);
  testCbor(person);
  testToml(person);

  dogs.shutdown();
}

void testJson(Person person) {
  var encoded = dogs.jsonEncode<Person>(person);
  print(encoded);
  var decoded = dogs.jsonDecode<Person>(encoded);
  print(decoded);
}

void testYaml(Person person) {
  var encoded = dogs.yamlEncode<Person>(person);
  print(encoded);
  var decoded = dogs.yamlDecode<Person>(encoded);
  print(decoded);
}

void testCbor(Person person) {
  var encoded = dogs.cborEncode<Person>(person);
  print(encoded.map((e) => e.toRadixString(16)).join(" "));
  var decoded = dogs.cborDecode<Person>(encoded);
  print(decoded);
}

void testToml(Person person) {
  var encoded = dogs.tomlEncode<Person>(person);
  print(encoded);
  var decoded = dogs.tomlDecode<Person>(encoded);
  print(decoded);
}
