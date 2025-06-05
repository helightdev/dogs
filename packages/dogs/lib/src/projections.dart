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

/// Transformer that applies a projection to a [Map] document and returns the
/// transformed document if a change was made.
typedef ProjectionTransformer = Map<String, dynamic> Function(
  Map<String, dynamic> data,
);

/// Extensions on the [DogEngine] related to projections.
extension ProjectionExtension on DogEngine {
  @Deprecated("Use Projection<T>().perform() instead")

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
      try {
        final structure = findStructureByType(element.runtimeType)!;
        Map<String, dynamic> result;
        if (structure.isSynthetic || !shallow) {
          result = convertObjectToNative(element, element.runtimeType);
        } else {
          result = structure.getFieldMap(element);
        }
        buffer.addAll(result);
      } catch (e, st) {
        throw DogProjectionException(
          message: "Exception occurred while projecting an object",
          object: element,
          cause: e,
          innerStackTrace: st,
        );
      }
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
        try {
          buffer = func(buffer);
        } catch (e, st) {
          throw DogProjectionException(
            message: "Exception occurred while applying a transformer",
            transformer: func,
            document: buffer,
            cause: e,
            innerStackTrace: st,
          );
        }
      }
    }
    return buffer;
  }

  @Deprecated("Use Projection<T>().perform() instead")

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
      objects: objects,
      properties: properties,
      transformers: transformers,
      shallow: shallow,
    );
    if (!shallow) {
      return dogs.convertObjectFromNative(document, target);
    }
    final fieldValues = struct.fields.map((e) => document[e.name]).toList();
    return struct.proxy.instantiate(fieldValues);
  }

  @Deprecated("Use Projection<T>().perform() instead")

  /// Creates a projection document from the given values, see [createProjectionDocument].
  Map<String, dynamic> projectDocument(
    Object value, [
    Object? a,
    Object? b,
    Object? c,
  ]) {
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

  @Deprecated("Use Projection<T>().perform() instead")

  /// Creates a shallow projection document from the given values, see [createProjectionDocument].
  Map<String, dynamic> projectDocumentShallow(
    Object value, [
    Object? a,
    Object? b,
    Object? c,
  ]) {
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

    return createProjectionDocument(
        properties: properties, objects: objects, shallow: true);
  }

  @Deprecated("Use Projection<T>().perform() instead")

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

  @Deprecated("Use Projection<T>().perform() instead")

  /// Creates a shallow projection from the given values, see [createProjection].
  TARGET projectShallow<TARGET>(Object value,
      [Object? a, Object? b, Object? c]) {
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

    return createProjection(TARGET,
        properties: properties, objects: objects, shallow: true);
  }
}

typedef Supplier<T> = T Function();

/// Creates a reusable list of projections that can be applied to a document.
final class Projection<T> {
  /// The engine to use for converting values.
  final DogEngine engine;

  /// Optional [TypeTree] that will be passed to [DogEngineShortcuts.fromNative] when merging values.
  final TypeTree? tree;

  /// Optional type that will be passed to [DogEngineShortcuts.fromNative] when merging values.
  final Type? type;

  /// If true, the field map will be used instead of the native representation
  /// for instantiating the final object.
  final bool useFieldMap;

  /// Creates a new projection with the given [engine] or the global [dogs] engine.
  Projection(
      {DogEngine? engine, this.tree, this.type, this.useFieldMap = false})
      : engine = engine ?? dogs;

  Projection.fieldMap({DogEngine? engine, this.tree, this.type})
      : engine = engine ?? dogs,
        useFieldMap = true;

  /// Ordered list of transformers that make up the projection.
  final List<ProjectionTransformer> transformers = [];

  /// Merge the given [map] into the projection.
  Projection<T> mergeMap(Map<String, dynamic> map) {
    transformers.add((v) {
      final result = <String, dynamic>{};
      result.addAll(v);
      result.addAll(map);
      return result;
    });
    return this;
  }

  /// Merges the given [value] into the projection.
  Projection<T> merge<S>(S value,
      {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    final native = engine.toNative(value, kind: kind, type: type, tree: tree);
    transformers.add((v) {
      final result = <String, dynamic>{};
      result.addAll(v);
      result.addAll(native);
      return result;
    });
    return this;
  }

  /// Merges the given [value] into the projection as a field map.
  Projection<T> mergeFields<S>(S value,
      {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    final fieldMap =
        engine.toFieldMap<S>(value, kind: kind, type: type, tree: tree);
    transformers.add((v) {
      final result = <String, dynamic>{};
      result.addAll(v);
      result.addAll(fieldMap);
      return result;
    });
    return this;
  }

  /// Sets the value at the given [path] to the native map representation of [instance].
  Projection<T> set<S>(String path, S value,
      {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    final native =
    engine.toNative<S>(value, kind: kind, type: type, tree: tree);
    transformers.add((v) => Projections.$set(v, path, native));
    return this;
  }

  /// Sets the value at the given [path] to the field map representation of [value].
  Projection<T> setFields<S>(String path, S value,
      {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    final fieldMap =
    engine.toFieldMap<S>(value, kind: kind, type: type, tree: tree);
    transformers.add((v) => Projections.$set(v, path, fieldMap));
    return this;
  }

  /// Sets the value at [path] to the [value].
  Projection<T> setValue(String path, dynamic value) {
    transformers.add((v) => Projections.$set(v, path, value));
    return this;
  }

  /// Moves the value from [from] and writes it to [to].
  ///
  /// To merge all values from a map to another map, specify [from] as
  /// `from.*` and [to] as the target path.
  ///
  /// To move to the root map, specify [to] as `""` or `"."`.
  Projection<T> move(String from, String to) {
    transformers.add(Projections.move(from, to));
    return this;
  }

  /// Deletes the value at the given [path].
  Projection<T> delete(String path) {
    transformers.add(Projections.delete(path));
    return this;
  }

  /// Adds a transformer to the projection.
  Projection<T> addTransformer(ProjectionTransformer transformer) {
    transformers.add(transformer);
    return this;
  }

  /// Unwraps the value at the given [path] and sets it to its native representation.
  Projection<T> unwrapType<S>(String path, {
    IterableKind kind = IterableKind.none, Type? type, TypeTree? tree,
  }) {
    transformers.add((v) {
      final result = Projections.$get(v, path);
      if (!result.exists) return v;
      final newValue = engine.toNative(result.value, kind: kind, type: type, tree: tree);
      return Projections.$set(v, path, newValue);
    });
    return this;
  }

  /// Unwraps the value at the given [path] and converts it to a field map.
  Projection<T> unwrapFields<S>(String path, {
    IterableKind kind = IterableKind.none, Type? type, TypeTree? tree,
  }) {
    transformers.add((v) {
      final result = Projections.$get(v, path);
      if (!result.exists) return v;
      final newValue = engine.toFieldMap(result.value, kind: kind, type: type, tree: tree);
      return Projections.$set(v, path, newValue);
    });
    return this;
  }


  /// Applies the projection to the given optional [initial] map and returns the result.
  T perform([Map<String, dynamic>? initial]) {
    var result = initial ?? <String, dynamic>{};
    for (final transformer in transformers) {
      result = transformer(result);
    }
    if (useFieldMap) {
      return engine.fromFieldMap<T>(result, type: type, tree: tree);
    }
    return engine.fromNative<T>(result, type: type, tree: tree);
  }

  /// Applies the projection to the given optional [initial] map and returns the result as a map.
  Map<String, dynamic> performMap([Map<String, dynamic>? initial]) {
    var result = initial ?? <String, dynamic>{};
    for (final transformer in transformers) {
      result = transformer(result);
    }
    return result;
  }
}

/// A result of traversing a map.
/// [exists] is true if the path exists in the map.
/// [value] is the value at the given path or null if it doesn't exist.
typedef TraverseResult = ({bool exists, dynamic value});

/// A collection of projection transformers.
class Projections {
  Projections._();

  /// Returns the value at [path] in the given [map].
  static TraverseResult $get(Map map, String path) {
    final subPaths = path.split(".");
    dynamic value = map;
    for (var path in subPaths) {
      if (path.isEmpty) continue;
      if (value is! Map) return (exists: false, value: null);
      if (!value.containsKey(path)) return (exists: false, value: null);
      value = value[path];
    }
    return (exists: true, value: value);
  }

  /// Sets the value at [path] in the given [map] to [value]. Returns a new map
  /// with the updated values and leaves the original map untouched.
  static Map<String, dynamic> $set(
      Map<String, dynamic> map, String path, dynamic value) {
    final subPaths = path.split(".");
    final result = <String, dynamic>{};
    var current = result;
    final isRoot = path.replaceAll(".", "").isEmpty;
    for (var i = 0; i < subPaths.length - 1; i++) {
      final path = subPaths[i];
      if (current.containsKey(path)) {
        current = current[path];
      } else {
        current[path] = <String, dynamic>{};
        current = current[path];
      }
    }
    if (isRoot) return value;
    current[subPaths.last] = value;
    return $clone(map)..addAll(result);
  }

  static Map<String,dynamic> $move(Map<String, dynamic> map, String from, String to, bool delete) {
    final isWildcard = from.endsWith(".*");
    if (isWildcard) {
      final path = from.substring(0, from.length - 2);
      final value = $get(map, path);
      if (!value.exists) return map;
      if (value.value is! Map) {
        throw ArgumentError("Source path '$from' is not a map");
      }
      if (delete) {
        map = $delete(map, path);
      }
      final target = $get(map, to);
      if (!target.exists) {
        return $set(map, to, value.value);
      }
      if (target.value is! Map) {
        throw ArgumentError("Target path '$to' is not a map");
      }

      final targetMap = $clone((target.value as Map<String, dynamic>?) ?? <String, dynamic>{});
      targetMap.addAll(value.value as Map<String, dynamic>);
      return $set(map, to, targetMap);
    } else {
      final value = $get(map, from);
      if (!value.exists) return map;
      if (delete) {
        map = $delete(map, from);
      }
      return $set(map, to, value.value);
    }
  }

  /// Deletes the value at [path] in the given [map]. Returns a new map
  /// with the updated values and leaves the original map untouched.
  static Map<String, dynamic> $delete(Map<String, dynamic> map, String path) {
    if (path.replaceAll(".", "").isEmpty) return <String, dynamic>{};
    final subPaths = path.split(".");

    final Map<String, dynamic> result = $clone(map);
    Map<String, dynamic> current = result;

    for (int i = 0; i < subPaths.length - 1; i++) {
      final key = subPaths[i];
      if (current[key] is Map<String, dynamic>) {
        current[key] = Map<String, dynamic>.from(current[key]);
        current = current[key];
      } else {
        return result;
      }
    }

    current.remove(subPaths.last);
    return result;
  }

  /// Deep clones the given [map] and returns a new map with the same values.
  static Map<String, dynamic> $clone(Map<String, dynamic> map) {
    return _deepClone(map);
  }

  static dynamic _deepClone(dynamic value) {
    if (value is Map) {
      return value.map<String, dynamic>(
          (key, value) => MapEntry(key, _deepClone(value)));
    } else if (value is List) {
      return value.map((e) => _deepClone(e)).toList();
    } else {
      return value;
    }
  }

  /// Applies a field transformer to the given [path].
  static ProjectionTransformer field(
      String path, dynamic Function(TraverseResult e) function) {
    return (data) {
      final result = $get(data, path);
      final functionResult =
          function((value: result.value, exists: result.exists));
      return $set(data, path, functionResult);
    };
  }

  /// Applies a field transformer to the given [path] that executes on iterable values.
  static ProjectionTransformer iterable(
      String path, dynamic Function(TraverseResult e) function) {
    return (data) {
      final result = $get(data, path);
      if (!result.exists) return function((value: null, exists: false));
      if (result.value is! Iterable) {
        throw ArgumentError("Value at path '$path' is not iterable");
      }
      final transformedData = (result.value as Iterable)
          .map((e) => function((value: e, exists: true)))
          .toList();
      return $set(data, path, transformedData);
    };
  }

  /// Applies a transformer that deletes the value at the given [path].
  static ProjectionTransformer delete(String path) {
    return (data) {
      return $delete(data, path);
    };
  }

  /// Applies a transformer that moves the value at [from] to [to].
  static ProjectionTransformer move(String from, String to) {
    return (data) => Projections.$move(data, from, to, true);
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
