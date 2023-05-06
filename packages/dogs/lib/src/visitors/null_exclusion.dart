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

class NullExclusionVisitor extends DogVisitor<DogGraphValue> {
  @override
  DogGraphValue visitNull(DogNull n) => throw Exception("Can't convert null!");

  @override
  DogGraphValue visitBool(DogBool b) => b;

  @override
  DogGraphValue visitDouble(DogDouble d) => d;

  @override
  DogGraphValue visitInt(DogInt i) => i;

  @override
  DogGraphValue visitString(DogString s) => s;

  @override
  DogGraphValue visitList(DogList l) {
    return DogList(
        l.value.whereNot((e) => e is DogNull).map((e) => visit(e)).toList());
  }

  @override
  DogGraphValue visitMap(DogMap m) {
    return DogMap(Map.fromEntries(m.value.entries
        .whereNot(
            (element) => element.key is DogNull || element.value is DogNull)
        .map((e) => MapEntry(visit(e.key), visit(e.value)))));
  }
}
