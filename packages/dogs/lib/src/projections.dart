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

typedef ProjectionTransformer = Map<String,dynamic> Function(Map<String,dynamic> data);

extension ProjectionExtension on DogEngine {

  dynamic createProjection(Type target, {
    Iterable<Map>? properties,
    Iterable<Object>? objects,
    Iterable<ProjectionTransformer>? transformers,
  }) {
    var struct = findStructureByType(target)!;
    var buffer = <String,dynamic>{};
    objects?.forEach((element) {
      var structure = findStructureByType(element.runtimeType)!;
      Map<String,dynamic> result;
      if (structure.isSynthetic) {
        result = convertObjectToNative(element, element.runtimeType);
      } else {
        result = structure.getFieldMap(element);
      }
      buffer.addAll(result);
    });
    properties?.forEach((element) {
      if (element is Map<String,dynamic>) {
        buffer.addAll(element);
      } else {
        buffer.addAll(element.cast<String,dynamic>());
      }
    });
    if (transformers != null) {
      for (var func in transformers) {
        buffer = func(buffer);
      }
    }
    var fieldValues = struct.fields.map((e) => buffer[e.name]).toList();
    return struct.proxy.instantiate(fieldValues);
  }

  TARGET project<TARGET>(Object value, [Object? a, Object? b, Object? c]) {
    // Combine additional args into an iterable value
    if ((a != null || b != null || c != null)) {
      value = [
        ...value.asIterable(),
        if (a != null) ...a.asIterable(),
        if (b != null) ...b.asIterable(),
        if (c != null) ...c.asIterable()
      ];
    }

    var properties = <Map>[];
    var objects = <Object>[];
    for (var element in value.asIterable()) {
      if (element is Map) {
        properties.add(element);
      } else {
        objects.add(element);
      }
    }

    return createProjection(TARGET,
      properties: properties,
      objects: objects
    );
  }
}

extension on Object {
  Iterable asIterable() {
    if (this is Iterable) {
      return this as Iterable;
    }
    return [this];
  }
}