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

typedef ProjectionTransformer = Map<String, dynamic> Function(
    Map<String, dynamic> data,);

extension ProjectionExtension on DogEngine {

  /// Creates a projection document from the given [properties] and [objects].
  /// The [properties] are merged into the document first, followed by the
  /// [objects]. If [shallow] is true, the objects are not converted to
  /// their native representation, but instead their field map is used.
  /// If [transformers] are given, they are applied to the document in order.
  Map<String, dynamic> createProjectionDocument({
    Iterable<Map>? properties,
    Iterable<Object>? objects,
    Iterable<ProjectionTransformer>? transformers,
    bool shallow = false,
  }) {
    var buffer = <String, dynamic>{};
    objects?.forEach((element) {
      final structure = findStructureByType(element.runtimeType)!;
      Map<String, dynamic> result;
      if (structure.isSynthetic || !shallow) {
        result = convertObjectToNative(element, element.runtimeType);
      } else {
        result = structure.getFieldMap(element);
      }
      buffer.addAll(result);
    });
    properties?.forEach((element) {
      if (element is Map<String, dynamic>) {
        buffer.addAll(element);
      } else {
        buffer.addAll(element.cast<String, dynamic>());
      }
    });
    if (transformers != null) {
      for (final func in transformers) {
        buffer = func(buffer);
      }
    }
    return buffer;
  }

  /// Creates a projection from the given [properties] and [objects] using
  /// [createProjectionDocument]. If [shallow] is true, the objects are not
  /// converted to their native representation, but instead their field map
  /// is used. The resulting document is then converted to the given [target]
  /// type.
  dynamic createProjection(
      Type target, {
        Iterable<Map>? properties,
        Iterable<Object>? objects,
        Iterable<ProjectionTransformer>? transformers,
        bool shallow = false,
      }) {
    final struct = findStructureByType(target)!;
    final document = createProjectionDocument(
      objects: objects, properties: properties, transformers: transformers, shallow: shallow,);
    if (!shallow) {
      return dogs.convertObjectFromNative(document, target);
    }
    final fieldValues = struct.fields.map((e) => document[e.name]).toList();
    return struct.proxy.instantiate(fieldValues);
  }

  /// Creates a projection document from the given values, see [createProjectionDocument].
  Map<String, dynamic> projectDocument(Object value,
      [Object? a, Object? b, Object? c,]) {
    // Combine additional args into an iterable value
    if (a != null || b != null || c != null) {
      value = [
        ...value.asIterable(),
        if (a != null) ...a.asIterable(),
        if (b != null) ...b.asIterable(),
        if (c != null) ...c.asIterable(),
      ];
    }

    final properties = <Map>[];
    final objects = <Object>[];
    for (final element in value.asIterable()) {
      if (element is Map) {
        properties.add(element);
      } else {
        objects.add(element);
      }
    }

    return createProjectionDocument(properties: properties, objects: objects);
  }

  /// Creates a shallow projection document from the given values, see [createProjectionDocument].
  Map<String, dynamic> projectDocumentShallow(Object value,
      [Object? a, Object? b, Object? c,]) {
    // Combine additional args into an iterable value
    if (a != null || b != null || c != null) {
      value = [
        ...value.asIterable(),
        if (a != null) ...a.asIterable(),
        if (b != null) ...b.asIterable(),
        if (c != null) ...c.asIterable(),
      ];
    }

    final properties = <Map>[];
    final objects = <Object>[];
    for (final element in value.asIterable()) {
      if (element is Map) {
        properties.add(element);
      } else {
        objects.add(element);
      }
    }

    return createProjectionDocument(properties: properties, objects: objects, shallow: true);
  }


  /// Creates a projection from the given values, see [createProjection].
  /// Parameters can be either a [Map] or an [Object]. If an [Object] is given,
  /// it's runtime type is used to find the corresponding [DogStructure] before
  /// serializing the object to its native map form. This will therefore not work
  /// with generic types. Consider manually serializing the object [toNative] first
  /// in that case before passing it in as a map.
  TARGET project<TARGET>(Object value, [Object? a, Object? b, Object? c]) {
    // Combine additional args into an iterable value
    if (a != null || b != null || c != null) {
      value = [
        ...value.asIterable(),
        if (a != null) ...a.asIterable(),
        if (b != null) ...b.asIterable(),
        if (c != null) ...c.asIterable(),
      ];
    }

    final properties = <Map>[];
    final objects = <Object>[];
    for (final element in value.asIterable()) {
      if (element is Map) {
        properties.add(element);
      } else {
        objects.add(element);
      }
    }

    return createProjection(TARGET, properties: properties, objects: objects);
  }

  /// Creates a shallow projection from the given values, see [createProjection].
  TARGET projectShallow<TARGET>(Object value, [Object? a, Object? b, Object? c]) {
    // Combine additional args into an iterable value
    if (a != null || b != null || c != null) {
      value = [
        ...value.asIterable(),
        if (a != null) ...a.asIterable(),
        if (b != null) ...b.asIterable(),
        if (c != null) ...c.asIterable(),
      ];
    }

    final properties = <Map>[];
    final objects = <Object>[];
    for (final element in value.asIterable()) {
      if (element is Map) {
        properties.add(element);
      } else {
        objects.add(element);
      }
    }

    return createProjection(TARGET, properties: properties, objects: objects, shallow: true);
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
