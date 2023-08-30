import 'dart:convert';

import 'package:dogs_core/dogs_core.dart';
import 'package:test/test.dart';

void main() {
  var dogs = DogEngine();
  test("structure converter", () {
    var engine = DogEngine();
    var structure = DogStructure(
        "TestStruct",
        StructureConformity.basic,
        [
          DogStructureField.string("name"),
          DogStructureField.int("age"),
          DogStructureField.string("note", optional: true)
        ],
        [],
        MemoryDogStructureProxy());
    var converter = DogStructureConverterImpl(structure);
    var graph = (converter.resolveOperationMode(GraphSerializerMode) as GraphSerializerMode)
        .serialize(["Christoph", 19, "Hello!"], engine);
    expect("""{"name":"Christoph","age":19,"note":"Hello!"}""",
        engine.jsonSerializer.serialize(graph));
  });
}
