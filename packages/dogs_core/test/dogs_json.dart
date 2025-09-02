import "dart:convert";

import "package:dogs_core/dogs_core.dart";
import "package:test/test.dart";

void main() {
  test("structure converter", () {
    final engine = DogEngine();
    final structure = DogStructure(
        "TestStruct",
        StructureConformity.basic,
        [
          DogStructureField.string("name"),
          DogStructureField.int("age"),
          DogStructureField.string("note", optional: true)
        ],
        [],
        MemoryDogStructureProxy());
    final converter = DogStructureConverterImpl(structure);
    final operation =
        engine.modeRegistry.entry<NativeSerializerMode>().forConverter(converter, engine);
    final graph = operation.serialize(["Christoph", 19, "Hello!"], engine);
    expect(jsonEncode(graph), """{"name":"Christoph","age":19,"note":"Hello!"}""");
  });
}
