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
import "package:test/test.dart";

void main() {
  test("Revision Migration", () {
    final versioned = RevisionMigration([
      (m, __, ___) {
        m["a"] = true;
      },
      (m, __, ___) {
        m["b"] = true;
      },
      (m, __, ___) {
        m["c"] = true;
      }
    ]);
    var data = <String, dynamic>{"_rev": 0};
    versioned.beforeDeserialization(data, DogStructure.synthetic(""), DogEngine());
    versioned.postSerialization(null, data, DogStructure.synthetic(""), DogEngine());
    expect(data["_rev"], 3);
    expect(data["a"], true);
    expect(data["b"], true);
    expect(data["c"], true);

    data = <String, dynamic>{"_rev": 1};
    versioned.beforeDeserialization(data, DogStructure.synthetic(""), DogEngine());
    versioned.postSerialization(null, data, DogStructure.synthetic(""), DogEngine());
    expect(data["_rev"], 3);
    expect(data["a"], null);
    expect(data["b"], true);
    expect(data["c"], true);

    data = <String, dynamic>{"_rev": 3};
    versioned.beforeDeserialization(data, DogStructure.synthetic(""), DogEngine());
    versioned.postSerialization(null, data, DogStructure.synthetic(""), DogEngine());
    expect(data["_rev"], 3);
    expect(data["a"], null);
    expect(data["b"], null);
    expect(data["c"], null);
  });

  test("Lightweight Migration", () {
    final versioned = LightweightMigration([
      (m, __, ___) {
        m["a"] = true;
      },
      (m, __, ___) {
        m["b"] = true;
      },
      (m, __, ___) {
        m["c"] = true;
      }
    ]);
    final data = <String, dynamic>{};
    versioned.beforeDeserialization(data, DogStructure.synthetic(""), DogEngine());
    versioned.postSerialization(null, data, DogStructure.synthetic(""), DogEngine());
    expect(data["a"], true);
    expect(data["b"], true);
    expect(data["c"], true);
  });
}
