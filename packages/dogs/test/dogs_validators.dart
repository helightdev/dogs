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

import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_core/dogs_validation.dart';
import 'package:test/test.dart';

void main() {
  var emptyEngine = DogEngine(false); // Empty engine
  group("Strings", () {
    test("Length Range", () {
      var structure = DogStructure(
          "Person",
          [
            DogStructureField.string("name",
                annotations: [LengthRange(min: 3, max: 10)], optional: true),
            DogStructureField.int("age"),
            DogStructureField.string("tags", iterable: IterableKind.set)
          ],
          [],
          MemoryDogStructureProxy());
      var converter = DogStructureConverterImpl(structure);
      expect(
          true,
          converter.validate([
            null,
            18,
            {"Person"}
          ], emptyEngine));
      expect(
          true,
          converter.validate([
            "Max",
            18,
            {"Person"}
          ], emptyEngine));
      expect(
          true,
          converter.validate([
            "0123456789",
            18,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "Ma",
            18,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "0123456789_",
            18,
            {"Person"}
          ], emptyEngine));
    });
    test("Regex", () {
      var structure = DogStructure(
          "Person",
          [
            DogStructureField.string("name",
                annotations: [
                  Regex("([A-Z])+([a-z])*"),
                ],
                optional: true),
            DogStructureField.int("age"),
            DogStructureField.string("tags", iterable: IterableKind.set)
          ],
          [],
          MemoryDogStructureProxy());
      var converter = DogStructureConverterImpl(structure);
      expect(
          true,
          converter.validate([
            null,
            18,
            {"Person"}
          ], emptyEngine));
      expect(
          true,
          converter.validate([
            "M",
            18,
            {"Person"}
          ], emptyEngine));
      expect(
          true,
          converter.validate([
            "Max",
            18,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "maX",
            18,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "Max Max",
            18,
            {"Person"}
          ], emptyEngine));
    });
  });
  group("Numbers", () {
    test("Minimum (inclusive)", () {
      var structure = DogStructure(
          "Person",
          [
            DogStructureField.string("name"),
            DogStructureField.int("age",
                annotations: [Minimum(18)], optional: true),
            DogStructureField.string("tags", iterable: IterableKind.set)
          ],
          [],
          MemoryDogStructureProxy());
      var converter = DogStructureConverterImpl(structure);
      expect(
          true,
          converter.validate([
            "Max",
            null,
            {"Person"}
          ], emptyEngine));
      expect(
          true,
          converter.validate([
            "Max",
            18,
            {"Person"}
          ], emptyEngine));
      expect(
          true,
          converter.validate([
            "Max",
            20,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "Max",
            17,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "Max",
            10,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "Max",
            -10,
            {"Person"}
          ], emptyEngine));
    });
    test("Minimum (exclusive)", () {
      var structure = DogStructure(
          "Person",
          [
            DogStructureField.string("name"),
            DogStructureField.int("age",
                annotations: [Minimum(17, minExclusive: true)], optional: true),
            DogStructureField.string("tags", iterable: IterableKind.set)
          ],
          [],
          MemoryDogStructureProxy());
      var converter = DogStructureConverterImpl(structure);
      expect(
          true,
          converter.validate([
            "Max",
            null,
            {"Person"}
          ], emptyEngine));
      expect(
          true,
          converter.validate([
            "Max",
            18,
            {"Person"}
          ], emptyEngine));
      expect(
          true,
          converter.validate([
            "Max",
            20,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "Max",
            17,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "Max",
            10,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "Max",
            -10,
            {"Person"}
          ], emptyEngine));
    });
    test("Maximum (inclusive)", () {
      var structure = DogStructure(
          "Person",
          [
            DogStructureField.string("name"),
            DogStructureField.int("age",
                annotations: [Maximum(99, maxExclusive: false)],
                optional: true),
            DogStructureField.string("tags", iterable: IterableKind.set)
          ],
          [],
          MemoryDogStructureProxy());
      var converter = DogStructureConverterImpl(structure);
      expect(
          true,
          converter.validate([
            "Max",
            null,
            {"Person"}
          ], emptyEngine));
      expect(
          true,
          converter.validate([
            "Max",
            18,
            {"Person"}
          ], emptyEngine));
      expect(
          true,
          converter.validate([
            "Max",
            99,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "Max",
            100,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "Max",
            200,
            {"Person"}
          ], emptyEngine));
    });
    test("Maximum (exclusive)", () {
      var structure = DogStructure(
          "Person",
          [
            DogStructureField.string("name"),
            DogStructureField.int("age",
                annotations: [Maximum(100, maxExclusive: true)],
                optional: true),
            DogStructureField.string("tags", iterable: IterableKind.set)
          ],
          [],
          MemoryDogStructureProxy());
      var converter = DogStructureConverterImpl(structure);
      expect(
          true,
          converter.validate([
            "Max",
            null,
            {"Person"}
          ], emptyEngine));
      expect(
          true,
          converter.validate([
            "Max",
            18,
            {"Person"}
          ], emptyEngine));
      expect(
          true,
          converter.validate([
            "Max",
            99,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "Max",
            100,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "Max",
            200,
            {"Person"}
          ], emptyEngine));
    });
    test("Range (inclusive)", () {
      var structure = DogStructure(
          "Person",
          [
            DogStructureField.string("name"),
            DogStructureField.int("age",
                annotations: [Range(min: 18, max: 99)], optional: true),
            DogStructureField.string("tags", iterable: IterableKind.set)
          ],
          [],
          MemoryDogStructureProxy());
      var converter = DogStructureConverterImpl(structure);
      expect(
          true,
          converter.validate([
            "Max",
            null,
            {"Person"}
          ], emptyEngine));
      expect(
          true,
          converter.validate([
            "Max",
            18,
            {"Person"}
          ], emptyEngine));
      expect(
          true,
          converter.validate([
            "Max",
            99,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "Max",
            17,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "Max",
            -10,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "Max",
            100,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "Max",
            200,
            {"Person"}
          ], emptyEngine));
    });
    test("Range (exclusive)", () {
      var structure = DogStructure(
          "Person",
          [
            DogStructureField.string("name"),
            DogStructureField.int("age",
                annotations: [
                  Range(
                      min: 17, max: 100, minExclusive: true, maxExclusive: true)
                ],
                optional: true),
            DogStructureField.string("tags", iterable: IterableKind.set)
          ],
          [],
          MemoryDogStructureProxy());
      var converter = DogStructureConverterImpl(structure);
      expect(
          true,
          converter.validate([
            "Max",
            null,
            {"Person"}
          ], emptyEngine));
      expect(
          true,
          converter.validate([
            "Max",
            18,
            {"Person"}
          ], emptyEngine));
      expect(
          true,
          converter.validate([
            "Max",
            99,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "Max",
            17,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "Max",
            -10,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "Max",
            100,
            {"Person"}
          ], emptyEngine));
      expect(
          false,
          converter.validate([
            "Max",
            200,
            {"Person"}
          ], emptyEngine));
    });
  });
  group("Iterables", () {
    test("SizeRange", () {
      var structure = DogStructure(
          "Person",
          [
            DogStructureField.string("name"),
            DogStructureField.int("age"),
            DogStructureField.string("tags",
                iterable: IterableKind.set,
                optional: true,
                annotations: [SizeRange(min: 1, max: 4)])
          ],
          [],
          MemoryDogStructureProxy());
      var converter = DogStructureConverterImpl(structure);
      expect(true, converter.validate(["Max", 18, null], emptyEngine));
      expect(
          true,
          converter.validate([
            "Max",
            18,
            {"Person"}
          ], emptyEngine));
      expect(
          true,
          converter.validate([
            "Max",
            18,
            {"A", "B", "C", "D"}
          ], emptyEngine));
      expect(false, converter.validate(["Max", 18, <String>{}], emptyEngine));
      expect(
          false,
          converter.validate([
            "Max",
            18,
            {"A", "B", "C", "D", "E"}
          ], emptyEngine));
    });
  });
  test("Validated", () {
    var tempEngine = DogEngine(false);
    var innerStruct = DogStructure<_Inner>(
        "inner",
        [
          DogStructureField.string("text",
              annotations: [LengthRange(min: 1, max: 5)])
        ],
        [],
        _Inner.proxy);
    var innerConverter = DogStructureConverterImpl(innerStruct);
    tempEngine.registerConverter(innerConverter);

    var structure = DogStructure(
        "Person",
        [
          DogStructureField.string("name"),
          DogStructureField.int("age"),
          DogStructureField.string("tags", iterable: IterableKind.set),
          DogStructureField.create<_Inner>(
              "children", List<_Inner>, IterableKind.list,
              annotations: [validated], optional: true)
        ],
        [],
        MemoryDogStructureProxy());
    var converter = DogStructureConverterImpl(structure);
    expect(
        true,
        converter.validate([
          "Max",
          18,
          {"Person"},
          null
        ], tempEngine));
    expect(
        true,
        converter.validate([
          "Max",
          18,
          {"Person"},
          [_Inner("Test")]
        ], tempEngine));
    expect(
        true,
        converter.validate([
          "Max",
          18,
          {"Person"},
          []
        ], tempEngine));
    expect(
        false,
        converter.validate([
          "Max",
          18,
          {"Person"},
          [_Inner("")]
        ], tempEngine));
    expect(
        false,
        converter.validate([
          "Max",
          18,
          {"Person"},
          [_Inner("12345A")]
        ], tempEngine));
  });
}

class _Inner {
  String text;
  _Inner(this.text);

  static _Inner parse(List args) => _Inner(args[0]);
  static $text(_Inner obj) => obj.text;
  static ObjectFactoryStructureProxy<_Inner> proxy =
      ObjectFactoryStructureProxy(parse, [$text]);
}
