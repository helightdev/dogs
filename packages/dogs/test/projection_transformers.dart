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
  test("Transform root field", () {
    final buffer = <String, dynamic>{
      "a": 1,
      "b": 2,
    };
    final transformed =
        Projections.field("a", (TraverseResult e) => "${e.value}")(buffer);
    expect(transformed["a"], "1");
    expect(buffer["a"], 1);
  });

  test("Transform field", () {
    final buffer = <String, dynamic>{
      "a": <String, dynamic>{
        "b": 1,
        "c": 2,
      }
    };
    final transformed =
        Projections.field("a.b", (TraverseResult e) => "${e.value}")(buffer);
    expect(transformed["a"]["b"], "1");
    expect(buffer["a"]["b"], 1);
  });

  test("Transform iterable", () {
    final buffer = <String, dynamic>{
      "a": <String, dynamic>{
        "b": [1, 2, 3],
        "c": 2,
      }
    };
    final transformed =
        Projections.iterable("a.b", (TraverseResult e) => (e.value as int) * 2)(buffer);
    expect(transformed["a"]["b"], [2, 4, 6]);
    expect(buffer["a"]["b"], [1, 2, 3]);
  });

  test("Transform delete", () {
    final buffer = <String, dynamic>{
      "a": <String, dynamic>{
        "b": 1,
        "c": 2,
      }
    };
    final transformed = Projections.delete("a.b")(buffer);
    expect(transformed["a"].containsKey("b"), false);
    expect(buffer["a"]["b"], 1);
  });

  test("Transform move upwards", () {
    final buffer = <String, dynamic>{
      "a": <String, dynamic>{
        "b": 1,
        "c": 2,
      }
    };
    final transformed = Projections.move("a.b", "d")(buffer);
    expect(transformed["a"].containsKey("b"), false);
    expect(transformed["d"], 1);
    expect(buffer["a"]["b"], 1);
  });

  test("Transform move downwards", () {
    final buffer = <String, dynamic>{
      "a": <String, dynamic>{
        "b": 1,
        "c": 2,
      }
    };
    final transformed = Projections.move("a.b", "a.d.e")(buffer);
    expect(transformed["a"].containsKey("b"), false);
    expect(transformed["a"]["d"]["e"], 1);
    expect(buffer["a"]["b"], 1);
  });
}
