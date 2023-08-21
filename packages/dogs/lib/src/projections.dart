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

extension ProjectionExtension on DogEngine {

  TARGET project<TARGET>(dynamic value, [dynamic a, dynamic b, dynamic c]) {
    var struct = findStructureByType(TARGET)!;
    Map data;

    // Combine additional args into an iterable value
    if (value != null && (a != null || b != null || c != null)) {
      value = [
        value,
        if (a != null) a,
        if (b != null) b,
        if (c != null) c
      ];
    }

    // Initialize final data map
    if (value is Map) {
      data = value;
    } else if (value is Iterable) {
      Map m = {};
      for (var childMap in value.map((e) {
        if (e is Map) return e;
        var elementType = e.runtimeType;
        var elementValue = e;
        if (e is (Type,dynamic)) {
          elementValue = e.$2;
          elementType = e.$1;
        }
        var converter = findAssociatedConverterOrThrow(elementType);
        return converter.convertToNative(elementValue, this) as Map;
      })) {
       m.addAll(childMap);
      }
      data = m;
    } else if (value is (dynamic, Type)) {
      var converter = findAssociatedConverterOrThrow(value.$2);
      data = converter.convertToNative(value.$1, this);
    } else {
      var converter = findAssociatedConverterOrThrow(value.runtimeType);
      data = converter.convertToNative(value, this);
    }

    // Instantiate target object
    var fieldValues = struct.fields.map((e) => data[e]).toList();
    return struct.proxy.instantiate(fieldValues) as TARGET;
  }

}