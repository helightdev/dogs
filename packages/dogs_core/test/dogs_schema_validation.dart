// ignore_for_file: unused_import

import "package:collection/collection.dart";
import "package:dogs_core/dogs_core.dart";
import "package:dogs_core/dogs_schema.dart" as z;
import "package:dogs_core/dogs_validation.dart";
import "package:test/expect.dart";
import "package:test/scaffolding.dart";

import "utils/schema.dart";

void main() {
  test("Test", () {
    final basic = z.object({
      "name": z.string().length(3),
      "age": z.integer().min(0).max(100),
      "tags": z.string().array().max(3)
    });

    final engine = DogEngine();
    final converter = engine.materialize(basic);
    final example1 = {
      "name": "Jon",
      "age": 30,
      "tags": ["tag1", "tag2", "tag3"]
    };
    final example2 = {
      "name": "John",
      "age": 150,
      "tags": ["tag1", "tag2", "tag3", "tag4"]
    };

    expect(converter.structure.getFieldByName("name")!.annotationsOf<LengthRange>(), isNotEmpty);
    expect(converter.structure.getFieldByName("age")!.annotationsOf<Range>(), isNotEmpty);
    expect(converter.structure.getFieldByName("tags")!.annotationsOf<SizeRange>(), isNotEmpty);
    expect(converter.isValid(example1), true);
    expect(converter.isValid(example2), false);
    expect(converter.annotate(example2).messages, hasLength(3));
  });
}
