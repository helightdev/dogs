import 'dart:convert';

import 'package:dogs_core/dogs_core.dart';
import 'package:test/test.dart';

void main() {
  var dogs = DogEngine(false);
  test('dogs json serialization', () {
    var mapPayload = {
      "id": 0,
      "name": "Christoph",
      "developer": true,
    };
    expect(dogs.jsonEncode<Map>(mapPayload), jsonEncode(mapPayload));
  });

  test("structure converter", () {
    var engine = DogEngine();
    var structure = DogStructure(
        "TestStruct",
        [
          DogStructureField.string("name"),
          DogStructureField.int("age"),
          DogStructureField.string("note", optional: true)
        ],
        [],
        MemoryDogStructureProxy());
    var converter = DogStructureConverterImpl(structure);
    var graph = converter.convertToGraph(["Christoph", 19, "Hello!"], engine);
    expect("""{"name":"Christoph","age":19,"note":"Hello!"}""", engine.jsonSerializer.serialize(graph));
  });
}
