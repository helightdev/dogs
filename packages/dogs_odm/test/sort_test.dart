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



import 'package:collection/collection.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_odm/dogs_odm.dart';
import 'package:dogs_odm/memory/sort.dart';
import 'package:dogs_odm/memory_db.dart';
import 'package:test/test.dart';

import 'person_test.dart';

var item0 = {
  "name": "Oliver",
  "age": 20,
};

var item1 = {
  "name": "Adam",
  "age": 20,
};

var item2 = {
  "name": "Bert",
  "age": 30,
};

var items = [item0, item1, item2];

void main() {
  var engine = DogEngine();
  engine.setSingleton();
  engine.registerAutomatic(DogStructureConverterImpl<Person>(personStructure));
  var system = MemoryOdmSystem();
  group("Sort Tests", () {
    test("Sort Name", () {
      var sorted = MapSorting.sort(items, SortScalar("name", true));
      expect(sorted, deepEquals([item1, item2, item0]));
    });
    test("Sort Age", () {
      var sorted = MapSorting.sort(items, SortScalar("age", true));
      expect(sorted, deepEquals([item0, item1, item2]));
    });
    test("Sort Name Desc", () {
      var sorted = MapSorting.sort(items, SortScalar("name", false));
      expect(sorted, deepEquals([item0, item2, item1]));
    });
    test("Sort Age Desc", () {
      var sorted = MapSorting.sort(items, SortScalar("age", false));
      expect(sorted, deepEquals([item2, item0, item1]));
    });
    test("Sort Age & Name", () {
      var sorted = MapSorting.sort(items, SortCombine([
        SortScalar("age", true),
        SortScalar("name", true),
      ]));
      expect(sorted, deepEquals([item1, item0, item2]));
    });
  });
}

Matcher deepEquals(dynamic expected) => DeepMatcher(expected);

class DeepMatcher extends Matcher {
  final dynamic expected;

  DeepMatcher(this.expected);

  @override
  Description describe(Description description) {
    return description.add("deep equals $expected");
  }

  @override
  bool matches(dynamic item, Map matchState) {
    return deepEquality.equals(item, expected);
  }
}