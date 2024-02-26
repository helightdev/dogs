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

import "package:collection/collection.dart";
import "package:dogs_core/dogs_core.dart";

/// Extensions on [DogGraphValue]s.
extension DogValueExtension on DogGraphValue {
  /// Checks if this [DogGraphValue] is an [DogNull]
  bool get isNull => this is DogNull;

  /// Checks if this [DogGraphValue] is an [DogString]
  /// and returns its value or null otherwise.
  String? get asString {
    final ref = this;
    if (ref is! DogString) return null;
    return ref.value;
  }

  /// Checks if this [DogGraphValue] is an [DogInt]
  /// and returns its value or null otherwise.
  int? get asInt {
    final ref = this;
    if (ref is! DogInt) return null;
    return ref.value;
  }

  /// Checks if this [DogGraphValue] is an [DogDouble]
  /// and returns its value or null otherwise.
  double? get asDouble {
    final ref = this;
    if (ref is! DogDouble) return null;
    return ref.value;
  }

  /// Checks if this [DogGraphValue] is an [DogBool]
  /// and returns its value or null otherwise.
  bool? get asBool {
    final ref = this;
    if (ref is! DogBool) return null;
    return ref.value;
  }

  /// Checks if this [DogGraphValue] is an [DogList]
  /// and returns it or null otherwise.
  DogList? get asList {
    final ref = this;
    if (ref is! DogList) return null;
    return ref;
  }

  /// Checks if this [DogGraphValue] is an [DogMap]
  /// and returns it or null otherwise.
  DogMap? get asMap {
    final ref = this;
    if (ref is! DogMap) return null;
    return ref;
  }
}

/// Extensions on [Iterable]s.
extension DogsIterableExtension<T> on Iterable<T> {
  /// Returns the first element that satisfies the given [predicate] or null if
  /// no elements are found.
  T? firstWhereOrNullDogs(bool Function(T element) func) {
    for (var element in this) {
      if (func(element)) return element;
    }
    return null;
  }
}

/// Extensions which provide easier shortcuts for common operations.
extension DogEngineShortcuts on DogEngine {
  /// Validates the supplied [value] using the [ValidationMode] mapped to [T].
  /// Throws a [ValidationException] if [validateObject] returns false.
  void validate<T>(T value) {
    final isValid = validateObject(value, T);
    if (!isValid) throw ValidationException();
  }

  /// Converts a [value] to its [DogGraphValue] representation using the
  /// converter associated with [T] or [tree].
  DogGraphValue toGraph<T>(T value,
      {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    final native = toNative<T>(value, kind: kind, type: type, tree: tree);
    return codec.fromNative(native);
  }

  /// Converts [DogGraphValue] supplied via [value] to its normal representation
  /// by using the converter associated with [T] or [tree].
  T fromGraph<T>(DogGraphValue value,
      {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    final native = value.coerceNative();
    return fromNative<T>(native, kind: kind, type: type, tree: tree);
  }

  /// Converts a [value] to its native representation using the converter
  /// associated with [T] or [type] and the supplied [IterableKind].
  /// If [tree] is supplied, the converter associated with the tree is used.
  dynamic toNative<T>(T value,
      {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    // If the type is explicitly nullable, manually handle null values.
    final isNullable = null is T;
    if (value == null && isNullable) {
      return codec.postProcessNative(null);
    }
    dynamic result;

    if (tree != null) {
      if (!tree.isQualified) throw DogException("TypeTree must be qualified");
      final converter = getTreeConverter(tree);
      result = modeRegistry.nativeSerialization
          .forConverter(converter, this)
          .serialize(value, this);
    } else {
      result = convertIterableToNative(value, type ?? T, kind);
    }

    result = codec.postProcessNative(result);
    return result;
  }

  /// Converts a [value] to its native representation using the converter
  /// associated with [T] or [type] and the supplied [IterableKind].
  /// If [tree] is supplied, the converter associated with the tree is used.
  T fromNative<T>(dynamic value,
      {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    value = codec.preProcessNative(value);

    // If the type is explicitly nullable, manually handle null values.
    final isNullable = null is T;
    if (value == null && isNullable) {
      return null as T;
    }

    if (tree != null) {
      if (!tree.isQualified) throw DogException("TypeTree must be qualified");
      final converter = getTreeConverter(tree);
      return modeRegistry.nativeSerialization
          .forConverter(converter, this)
          .deserialize(value, this);
    }
    return convertIterableFromNative(value, type ?? T, kind);
  }
}

/// Extensions on [DogStructure]s.
extension StructureExtensions on DogStructure {
  /// Returns all field getters for this structure.
  List<dynamic Function(dynamic)> get getters => List.generate(
      fields.length, (index) => (obj) => proxy.getField(obj, index));

  /// Returns all field values of the supplied [obj] as a field name keyed map.
  /// If a field defines a custom serial name, that name is used instead.
  Map<String, dynamic> getFieldMap(dynamic obj) => Map.fromEntries(
      fields.mapIndexed((i, e) => MapEntry(e.name, proxy.getField(obj, i))));

  /// Reconstructs a new instance of [T] using the supplied [map] as field values.
  /// For more details on the map format, see [getFieldMap].
  /// Throws an exception if a required field is missing.
  dynamic instantiateFromFieldMap(Map<String, dynamic> map) {
    final values = [];
    for (var i = 0; i < fields.length; i++) {
      final field = fields[i];
      final value = map[field.name];
      if (value == null && field.optional) {
        values.add(null);
      } else if (value != null) {
        values.add(value);
      } else {
        throw Exception("Missing required field ${field.name}");
      }
    }
    return proxy.instantiate(values);
  }

  /// Returns all annotations of type [T] for this structure.
  List<T> metadataOf<T>() {
    return annotations.whereType<T>().toList();
  }

  /// Returns the index of the field with the supplied [name] or null if not found.
  int? indexOfFieldName(String name) {
    for (var i = 0; i < fields.length; i++) {
      if (fields[i].name == name) {
        return i;
      }
    }
    return null;
  }
}

/// Extensions on [DogStructureField]s.
extension FieldExtension on DogStructureField {
  /// Returns all annotations of type [T] for this field.
  List<T> metadataOf<T>() {
    return annotations.whereType<T>().toList();
  }

  /// Returns the [DogConverter] the [StructureHarbinger] would use to convert
  /// this field.
  DogConverter? findConverter(DogStructure structure, [DogEngine? engine]) {
    engine ??= DogEngine.instance;
    final harbinger = StructureHarbinger.create(structure, engine);
    return harbinger.getConverter(engine, this);
  }
}
