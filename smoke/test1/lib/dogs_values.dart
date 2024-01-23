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

import 'package:built_collection/built_collection.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:smoke_test_1/values.dart';

@serializable
class MyDogsModel with Dataclass<MyDogsModel> {
  BuiltList<String> strings;
  BuiltList<int> ints;
  BuiltSet<VerySimpleValue> simpleValues;

  MyDogsModel(this.strings, this.ints, this.simpleValues);

  static MyDogsModel variant0() {
    return MyDogsModel(
      BuiltList<String>(["A", "B", "C"]),
      BuiltList<int>([1, 2, 3]),
      BuiltSet<VerySimpleValue>([VerySimpleValue(1), VerySimpleValue(2), VerySimpleValue(3)]),
    );
  }
}

@serializable
class MultimapModel with Dataclass<MultimapModel> {
  BuiltListMultimap<String, int> stringsToInts;
  BuiltSetMultimap<String, VerySimpleValue> intsToSimpleValues;

  MultimapModel(this.stringsToInts, this.intsToSimpleValues);

  static MultimapModel variant0() {
    return MultimapModel(
      BuiltListMultimap<String, int>({
        "A": [1, 2, 3],
        "B": [4, 5, 6],
        "C": [7, 8, 9],
      }),
      BuiltSetMultimap<String, VerySimpleValue>({
        "1": [VerySimpleValue(1), VerySimpleValue(2), VerySimpleValue(3)],
        "2": [VerySimpleValue(4), VerySimpleValue(5), VerySimpleValue(6)],
        "3": [VerySimpleValue(7), VerySimpleValue(8), VerySimpleValue(9)],
      }),
    );
  }
}

@serializable
class PolymorphicBuiltModel with Dataclass<PolymorphicBuiltModel> {

  @polymorphic
  BuiltListMultimap<String, Object> polymorphicMultimap;

  PolymorphicBuiltModel(this.polymorphicMultimap);

  static PolymorphicBuiltModel variant0() {
    return PolymorphicBuiltModel(
      BuiltListMultimap<String, Object>({
        "A": [1, 2, 3],
        "B": ["Hello", "World"],
        "C": [false, false, true, true],
      }),
    );
  }
}