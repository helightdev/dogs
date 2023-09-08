import 'package:dogs_core/dogs_core.dart';
import 'package:test/test.dart';

void main() {
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
    var operation = engine.modeRegistry
        .entry<GraphSerializerMode>()
        .forConverter(converter, engine);
    var graph = operation.serialize(["Christoph", 19, "Hello!"], engine);
    expect("""{"name":"Christoph","age":19,"note":"Hello!"}""",
        engine.jsonSerializer.serialize(graph));
  });
}
