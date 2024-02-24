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

/// Deeply converts a map with dynamic keys to a map with string keys.
Object? stringKeyedMapFrom(Object? value) => switch (value) {
      null => null,
      Map() => value.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), stringKeyedMapFrom(value))),
      List() => value.map((e) => stringKeyedMapFrom(e)).toList(),
      _ => value
    };

class StringKeyedMapVisitor extends DogVisitor<dynamic> {
  Map<String, dynamic> visitFinal(DogMap map) {
    return visit(map) as Map<String, dynamic>;
  }

  @override
  visitNull(DogNull n) {
    return null;
  }

  @override
  visitBool(DogBool b) {
    return b.value;
  }

  @override
  visitDouble(DogDouble d) {
    return d.value;
  }

  @override
  visitInt(DogInt i) {
    return i.value;
  }

  @override
  visitString(DogString s) {
    return s.value;
  }

  @override
  visitList(DogList l) {
    return l.value.map((e) => visit(e)).toList();
  }

  @override
  visitMap(DogMap m) {
    return m.value.map((key, value) => MapEntry(key.asString!, visit(value)));
  }
}
