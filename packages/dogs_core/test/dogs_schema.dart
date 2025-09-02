// ignore_for_file: unused_import

/*
 *    Copyright 2022, the DOGs authors
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

import "package:collection/collection.dart";
import "package:dogs_core/dogs_core.dart";
import "package:dogs_core/dogs_schema.dart" as z;
import "package:test/expect.dart";
import "package:test/scaffolding.dart";

import "utils/schema.dart";

void main() {
  group("Schema Type Serialization", () {
    test("Simple Primitives", () {
      expect(z.string().optional().property(SchemaProperties.description, "My description"),
          doesReserialize);
      expect(z.integer().optional().property(SchemaProperties.description, "My description"),
          doesReserialize);
      expect(z.number().optional().property(SchemaProperties.description, "My description"),
          doesReserialize);
      expect(z.boolean().optional().property(SchemaProperties.description, "My description"),
          doesReserialize);
    });

    test("Object", () {
      final actual = z.object({
        "name": z.string().optional().property(SchemaProperties.minLength, 5),
        "age": z.integer(),
      }).property(SchemaProperties.description, "My description");
      expect(actual, doesReserialize);
    });

    test("Array", () {
      final actual = z.array(z.string()).property(SchemaProperties.description, "My description");
      expect(actual, doesReserialize);
    });

    test("Map", () {
      final actual = z.map(z.string()).property(SchemaProperties.description, "My description");
      expect(actual, doesReserialize);
    });

    test("Reference", () {
      final actual = z.ref("MyRef").property(SchemaProperties.description, "My description");
      expect(actual, doesReserialize);
    });

    test("Does not reserialize (Sanity Check)", () {
      final actual = z.string().property(SchemaProperties.description, "My description");
      final properties = actual.toProperties();
      properties[SchemaProperties.description] = "My description 2";
      final parsed = SchemaType.fromProperties(properties);
      expect(actual.toSha256(), isNot(parsed.toSha256()));
    });
  });

  test("Enum Properties", () {
    final base = z.object({
      "first": z.enumeration(["A", "B", "C"]),
    });
    expect(base, doesReserialize);
    final case0 = {
      "first": "A",
    };
    final case1 = {
      "first": "B",
    };
    final case2 = {
      "first": "C",
    };
    final case3 = {
      "first": "D", // Invalid case
    };

    final serializer = DogEngine().materialize(base);
    final encoded0 = serializer.toJson(case0);
    final decoded0 = serializer.fromJson(encoded0);
    expect(decoded0, unorderedDeepEquals(case0));
    final encoded1 = serializer.toJson(case1);
    final decoded1 = serializer.fromJson(encoded1);
    expect(decoded1, unorderedDeepEquals(case1));
    final decoded2 = serializer.fromNative(case2);
    expect(decoded2, unorderedDeepEquals(case2));
    expect(() => serializer.fromNative(case3), throwsA(isA<DogException>()));
  });

  test("Unroll Nested Schema", () {
    final base = z.object({
      "name": z.string(),
      "age": z.integer(),
      "nested": z.object({
        "nestedName": z.string(),
        "deeper": z.object({
          "deeperName": z.string(),
          "deeperAge": z.integer(),
        }),
      })
    });
    expect(base, doesReserialize);
    final (objects, unrolled) = SchemaObjectUnroller.unroll(base);
    expect(objects.length, 3);
    expect(unrolled, doesReserialize);
  });

  test("Runtime Serializer", () {
    final base = z.object({
      "name": z.string(),
      "age": z.integer(),
      "birthday": z.ref("DateTime"),
      "nested": z.object({
        "nestedName": z.string(),
        "deeper": z.object({
          "deeperName": z.string(),
          "deeperAge": z.integer(),
        }),
      })
    });
    expect(base, doesReserialize);
    final serializer = DogEngine().materialize(base);
    final example = {
      "name": "John",
      "age": 30,
      "birthday": DateTime.now(),
      "nested": {
        "nestedName": "Nested John",
        "deeper": {
          "deeperName": "Deeper John",
          "deeperAge": 10,
        }
      }
    };
    final encoded = serializer.toJson(example);
    final decoded = serializer.fromJson(encoded);
    expect(decoded, unorderedDeepEquals(example));
  });

  test("Serialize Lists", () {
    final base = z.object({
      "strings": z.string().array(),
      "numbers": z.number().array(),
      "integers": z.integer().array(),
      "booleans": z.boolean().array(),
      "anys": z.any().array(),
      "objects": z.object({
        "name": z.string(),
        "age": z.integer(),
      }).array(),
    });
    expect(base, doesReserialize);
    final serializer = DogEngine().materialize(base);
    final example = {
      "strings": ["Hello", "World"],
      "numbers": [1.0, 2.0],
      "integers": [1, 2],
      "booleans": [true, false],
      "anys": ["Test", 1, true],
      "objects": [
        {"name": "John", "age": 30},
        {"name": "Jane", "age": 25}
      ]
    };
    final encoded = serializer.toJson(example);
    final decoded = serializer.fromJson(encoded);
    expect(decoded, unorderedDeepEquals(decoded));
  });

  test("Serialize Item Maps", () {
    final base = z.object({
      "strings": z.map(z.string()),
      "numbers": z.map(z.number()),
      "integers": z.map(z.integer()),
      "booleans": z.map(z.boolean()),
      "anys": z.map(z.any()),
      "objects": z.map(z.object({
        "name": z.string(),
        "age": z.integer(),
      })),
    });
    expect(base, doesReserialize);
    final serializer = DogEngine().materialize(base);
    final example = {
      "strings": {"a": "Hello", "b": "World"},
      "numbers": {"a": 1.0, "b": 2.0},
      "integers": {"a": 1, "b": 2},
      "booleans": {"a": true, "b": false},
      "anys": {"a": "Test", "b": 1, "c": true},
      "objects": {
        "a": {"name": "John", "age": 30},
        "b": {"name": "Jane", "age": 25}
      }
    };
    final encoded = serializer.toJson(example);
    final decoded = serializer.fromJson(encoded);
    expect(decoded, unorderedDeepEquals(decoded));
  });

  test("Serialize Single", () {
    final base = z.object({
      "string": z.string(),
      "number": z.number(),
      "integer": z.integer(),
      "boolean": z.boolean(),
      "any": z.any(),
      "object": z.object({
        "name": z.string(),
        "age": z.integer(),
      }),
    });
    expect(base, doesReserialize);
    final serializer = DogEngine().materialize(base);
    final example = {
      "string": "Hello",
      "number": 1.0,
      "integer": 1,
      "boolean": true,
      "any": "Test",
      "object": {"name": "John", "age": 30}
    };
    final encoded = serializer.toJson(example);
    final decoded = serializer.fromJson(encoded);
    expect(decoded, unorderedDeepEquals(decoded));
  });

  test("Serialize Single Nullable", () {
    final base = z.object({
      "string": z.string().optional(),
      "number": z.number().optional(),
      "integer": z.integer().optional(),
      "boolean": z.boolean().optional(),
      "any": z.any().optional(),
      "object": z.object({
        "name": z.string().optional(),
        "age": z.integer().optional(),
      }).optional(),
    });
    expect(base, doesReserialize);

    final serializer = DogEngine().materialize(base);
    final example = {
      "string": "Hello",
      "number": 1.0,
      "integer": 1,
      "boolean": true,
      "any": "Test",
      "object": {"name": "John", "age": 30}
    };
    final encoded = serializer.toJson(example);
    final decoded = serializer.fromJson(encoded);
    expect(decoded, unorderedDeepEquals(decoded));

    final example2 = {
      "string": null,
      "number": null,
      "integer": null,
      "boolean": null,
      "any": null,
      "object": null
    };

    final encoded2 = serializer.toJson(example2);
    final decoded2 = serializer.fromJson(encoded2);
    expect(decoded2, unorderedDeepEquals(example2));
  });

  test("Serialize List Nullable", () {
    final base = z.object({
      "strings": z.string().array().optional(),
      "numbers": z.number().array().optional(),
      "integers": z.integer().array().optional(),
      "booleans": z.boolean().array().optional(),
      "anys": z.any().array().optional(),
      "objects": z
          .object({
            "name": z.string().optional(),
            "age": z.integer().optional(),
          })
          .array()
          .optional(),
    });
    expect(base, doesReserialize);
    final serializer = DogEngine().materialize(base);
    final example = {
      "strings": ["Hello", "World"],
      "numbers": [1.0, 2.0],
      "integers": [1, 2],
      "booleans": [true, false],
      "anys": ["Test", 1, true],
      "objects": [
        {"name": "John", "age": 30},
        {"name": "Jane", "age": 25}
      ]
    };
    final encoded = serializer.toJson(example);
    final decoded = serializer.fromJson(encoded);
    expect(decoded, unorderedDeepEquals(decoded));

    final example2 = {
      "strings": null,
      "numbers": null,
      "integers": null,
      "booleans": null,
      "anys": null,
      "objects": null
    };

    final encoded2 = serializer.toJson(example2);
    final decoded2 = serializer.fromJson(encoded2);
    expect(decoded2, unorderedDeepEquals(example2));
  });
}
