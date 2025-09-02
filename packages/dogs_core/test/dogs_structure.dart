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

import "package:dogs_core/dogs_core.dart";
import "package:test/expect.dart";
import "package:test/scaffolding.dart";

void main() {
  test("Person", () {
    final structure = DogStructure(
        "Person",
        StructureConformity.basic,
        [
          DogStructureField.string("name"),
          DogStructureField.int("age"),
          DogStructureField.string("note", optional: true)
        ],
        [],
        MemoryDogStructureProxy());
    final obj = structure.proxy.instantiate(["Christoph", 19, null]);
    expect("Christoph", structure.proxy.getField(obj, 0));
    expect(19, structure.proxy.getField(obj, 1));
    expect(null, structure.proxy.getField(obj, 2));
  });
  test("Note", () {
    final structure = DogStructure(
        "Note",
        StructureConformity.basic,
        [
          DogStructureField.string("title", optional: true),
          DogStructureField.string("description"),
          DogStructureField.bool("favourite"),
          DogStructureField.string("tags", iterable: IterableKind.set),
        ],
        [],
        MemoryDogStructureProxy());
    final a = structure.proxy.instantiate([
      "Workout",
      "Lets get fit",
      true,
      {"sport", "lifestyle"}
    ]);
    expect(structure.proxy.getField(a, 0), "Workout");
    expect(structure.proxy.getField(a, 1), "Lets get fit");
    expect(structure.proxy.getField(a, 2), true);
    expect(structure.proxy.getField(a, 3), containsAllInOrder(["sport", "lifestyle"]));
    expect(structure.proxy.getField(a, 3), isA<Set>());

    final b = structure.proxy.instantiate([
      null,
      "Some Data",
      false,
      {"info"}
    ]);
    expect(structure.proxy.getField(b, 0), null);
    expect(structure.proxy.getField(b, 1), "Some Data");
    expect(structure.proxy.getField(b, 2), false);
    expect(structure.proxy.getField(b, 3), containsAllInOrder(["info"]));
    expect(structure.proxy.getField(b, 3), isA<Set>());
  });
}
