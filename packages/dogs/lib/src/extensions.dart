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
    if (!isValid) {
      throw ValidationException(validateAnnotated(value, T));
    }
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
      final converter = getTreeConverter(tree);
      return modeRegistry.nativeSerialization
          .forConverter(converter, this)
          .deserialize(value, this);
    }
    return convertIterableFromNative(value, type ?? T, kind);
  }

  /// Converts a field map to an instance of [T] using the structure
  /// associated with [T] or [type] and the supplied [IterableKind].
  /// If [tree] is supplied, the structure associated with the tree is used.
  T fromFieldMap<T>(Map<String,dynamic> fieldMap, {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    final structureType = tree?.base.typeArgument ?? type ?? T;
    final structure = findStructureByType(structureType);
    if (structure == null) {
      throw DogException("No structure found for type $structureType");
    }
    return structure.instantiateFromFieldMap(fieldMap);
  }


  /// Converts a value of type [T] to a field map using the structure
  /// associated with [T] or [type] and the supplied [IterableKind].
  /// If [tree] is supplied, the structure associated with the tree is used.
  Map<String,dynamic> toFieldMap<T>(T value, {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    final structureType = tree?.base.typeArgument ?? type ?? T;
    final structure = findStructureByType(structureType);
    if (structure == null) {
      throw DogException("No structure found for type $structureType");
    }
    return structure.getFieldMap(value);
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
        throw DogException("Missing required field ${field.name}");
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

  /// Returns the first field with the supplied [name] or null if not found.
  DogStructureField? getFieldByName(String name) {
    for (var field in fields) {
      if (field.name == name) {
        return field;
      }
    }
    return null;
  }

  /// Returns an [IsolatedClassValidator] that can be used to evaluate the
  /// [ClassValidator]s and [FieldValidator]s of this structure.
  IsolatedClassValidator getClassValidator({DogEngine? engine, List<IsolatedFieldValidator>? fieldValidators}) {
    engine ??= DogEngine.instance;
    final classValidators = annotationsOf<ClassValidator>().toList();
    for (var value in classValidators) {
      value.verifyUsage(this);
    }
    final classValidatorCacheData =
        classValidators.map((e) => e.getCachedValue(this)).toList();

    fieldValidators ??= fields
          .map((e) => e.getFieldValidator(engine: engine))
          .toList();

    final fieldAccessors = <dynamic Function(dynamic)>[];
    for (var i = 0; i < fields.length; i++) {
      fieldAccessors.add((instance) => proxy.getField(instance, i));
    }
    final contextValidators = <ContextFieldValidator>[];
    final contextValidatorCacheData = <dynamic>[];
    for (var field in fields) {
      for (var contextValidator in field.metadataOf<ContextFieldValidator>()) {
        contextValidator.verifyUsage(this, field);
        contextValidators.add(contextValidator);
        contextValidatorCacheData
            .add(contextValidator.getCachedValue(this, field));
      }
    }

    return IsolatedClassValidator(
        engine: engine,
        classValidators: classValidators,
        classValidatorCacheData: classValidatorCacheData,
        contextValidators: contextValidators,
        contextValidatorCacheData: contextValidatorCacheData,
        fieldValidators: fieldValidators,
        fieldAccessors: fieldAccessors,
        structure: this);
  }

  String toDebugString(DogEngine? engine) {
    final buffer = StringBuffer();
    buffer.writeln("Structure: $serialName");
    buffer.writeln("  Type: $typeArgument");
    buffer.writeln("  Proxy: $proxy");
    buffer.writeln("  Conformity: $conformity");
    if (fields.isNotEmpty) {
      buffer.writeln("  Fields:");
      for (var field in fields) {
        buffer.write("    ${field.name}: ${field.type.qualifiedOrBase.typeArgument}");
        if (field.optional) {
          buffer.write("?");
        }
        if (field.structure) {
          buffer.write(" (structure)");
        }
        if (field.annotations.isNotEmpty) {
          buffer.write(" [${field.annotations.map((e) => e).join(", ")}]");
        }
        buffer.writeln();
      }
    } else {
      buffer.writeln("  No fields (Synthetic structure)");
    }
    if (annotations.isNotEmpty) {
      buffer.writeln("  Annotations:");
      for (var annotation in annotations) {
        buffer.writeln("    ${annotation.runtimeType}");
      }
    }
    if (engine != null && fields.isNotEmpty) {
      buffer.writeln("  Converters:");
      for (var field in fields) {
        final converter = field.findConverter(this, engine: engine);
        if (converter != null) {
          buffer.writeln("    ${field.name}: ${converter.toString()}");
        } else {
          buffer.writeln("    ${field.name}: null");
        }
      }
    }

    return buffer.toString();
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
  DogConverter? findConverter(DogStructure? structure,
      {DogEngine? engine, bool nativeConverters = false}) {
    engine ??= DogEngine.instance;
    return StructureHarbinger.getConverter(engine, structure, this,
        nativeConverters: nativeConverters);
  }

  /// Returns an [IsolatedFieldValidator] that can be used to evaluate the [FieldValidator]s of this field.
  IsolatedFieldValidator getFieldValidator({
    DogEngine? engine,
    FieldValidator? guardValidator,
  }) {
    engine ??= DogEngine.instance;
    final fieldValidators = annotationsOf<FieldValidator>().toList();
    if (guardValidator != null) {
      fieldValidators.insert(0, guardValidator);
    }
    for (var value in fieldValidators) {
      value.verifyUsage(this);
    }
    final cacheData =
        fieldValidators.map((e) => e.getCachedValue(this)).toList();
    return IsolatedFieldValidator(
      hasGuardValidator: guardValidator != null,
      engine: engine,
      field: this,
      fieldValidators: fieldValidators,
      fieldValidatorCacheData: cacheData,
    );
  }
}
