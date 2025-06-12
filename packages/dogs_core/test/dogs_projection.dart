import "package:dogs_core/dogs_core.dart";
import "package:dogs_core/dogs_schema.dart" as z;
import "package:test/test.dart";

import "utils/schema.dart";

void main() {
  configureDogs(plugins: []);
  final person = dogs.importSchema(z.object({
    "name": z.string(),
    "age": z.integer(),
  }).serialName("Person"));

  group("Projection Tests", () {
    test("Value Construction", () {
      final value = Projection(tree: person)
          .setValue("name", "John")
          .setValue("age", 30)
          .perform();
      expect(
          value,
          unorderedDeepEquals({
            "name": "John",
            "age": 30,
          }));
    });

    test("Unwrapping", () {
      final initialPerson = {
        "name": "John",
        "age": 30,
      };
      final value = Projection(tree: person)
          .unwrapType("a", tree: person)
          .performMap({"a": initialPerson});
      expect(value["a"], unorderedDeepEquals(initialPerson));
    });

    test("Unwrap to root", () {
      final initialPerson = {
        "name": "John",
        "age": 30,
      };
      final value = Projection(tree: person)
          .unwrapType("a", tree: person)
          .move("a.*", ".")
          .perform({"a": initialPerson});
      expect(value, unorderedDeepEquals(initialPerson));
    });
  });
}
