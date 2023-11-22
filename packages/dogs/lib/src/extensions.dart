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

extension DogValueExtension on DogGraphValue {
  bool get isNull => this is DogNull;

  /// Checks if this [DogGraphValue] is an [DogString]
  /// and returns its value or null otherwise.
  String? get asString {
    var ref = this;
    if (ref is! DogString) return null;
    return ref.value;
  }

  /// Checks if this [DogGraphValue] is an [DogInt]
  /// and returns its value or null otherwise.
  int? get asInt {
    var ref = this;
    if (ref is! DogInt) return null;
    return ref.value;
  }

  /// Checks if this [DogGraphValue] is an [DogDouble]
  /// and returns its value or null otherwise.
  double? get asDouble {
    var ref = this;
    if (ref is! DogDouble) return null;
    return ref.value;
  }

  /// Checks if this [DogGraphValue] is an [DogBool]
  /// and returns its value or null otherwise.
  bool? get asBool {
    var ref = this;
    if (ref is! DogBool) return null;
    return ref.value;
  }

  /// Checks if this [DogGraphValue] is an [DogList]
  /// and returns it or null otherwise.
  DogList? get asList {
    var ref = this;
    if (ref is! DogList) return null;
    return ref;
  }

  /// Checks if this [DogGraphValue] is an [DogMap]
  /// and returns it or null otherwise.
  DogMap? get asMap {
    var ref = this;
    if (ref is! DogMap) return null;
    return ref;
  }
}

extension DogsIterableExtension<T> on Iterable<T> {
  Type get typeArgument => T;
  Type get deriveListType => List<T>;
  Type get deriveSetType => Set<T>;
  Type get deriveIterableType => Iterable<T>;

  T? firstWhereOrNull(bool Function(T element) func) {
    for (var element in this) {
      if (func(element)) return element;
    }
    return null;
  }
}

extension DogsMapExtension<K, V> on Map<K, V> {
  Type get keyTypeArgument => K;
  Type get valueTypeArgument => V;
  @Deprecated("Moved to DefaultNativeCodec")
  DogGraphValue get asGraph => DogGraphValue.fromNative(this);
}

extension DogsListExtension<T> on List<T> {
  @Deprecated("Moved to DefaultNativeCodec")
  DogGraphValue get asGraph => DogGraphValue.fromNative(this);
}

extension DogEngineShortcuts on DogEngine {
  /// Validates the supplied [value] using the [ValidationMode] mapped to [T].
  /// Throws a [ValidationException] if [validateObject] returns false.
  void validate<T>(T value) {
    var isValid = validateObject(value, T);
    if (!isValid) throw ValidationException();
  }

  /// Converts a [value] to its [DogGraphValue] representation using the
  /// converter associated with [T].
  DogGraphValue toGraph<T>(T value,
          {IterableKind kind = IterableKind.none, Type? type}) =>
      convertIterableToGraph(value, type ?? T, kind);

  /// Converts [DogGraphValue] supplied via [value] to its normal representation
  /// by using the converter associated with [t].
  T fromGraph<T>(DogGraphValue value,
          {IterableKind kind = IterableKind.none, Type? type}) =>
      convertIterableFromGraph(value, type ?? T, kind);
}

extension StructureExtensions on DogStructure {

  /// Returns all field getters for this structure.
  List<dynamic Function(dynamic)> get getters => List.generate(
      fields.length, (index) => (obj) => proxy.getField(obj, index));

  /// Returns all field values of the supplied [obj] as a field name keyed map.
  /// If a field defines a custom serial name, that name is used instead.
  Map<String, dynamic> getFieldMap(dynamic obj) => Map.fromEntries(
      fields.mapIndexed((i, e) => MapEntry(e.name, proxy.getField(obj, i))));

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

extension FieldExtension on DogStructureField {
  List<T> metadataOf<T>() {
    return annotations.whereType<T>().toList();
  }

  DogConverter? findConverter(DogStructure structure, [DogEngine? engine]) {
    engine ??= DogEngine.instance;
    final supplier = firstAnnotationOf<ConverterSupplyingVisitor>();
    if (supplier != null) {
      return supplier.resolve(structure, this, engine);
    }

    if (converterType != null) {
      return engine.findConverter(converterType!);
    }

    if (engine.codec.isNative(serial.typeArgument)) {
      return null;
    }

    var directConverter =
        engine.findAssociatedConverter(type.qualified.typeArgument);
    if (directConverter != null) return directConverter;
    return engine.findAssociatedConverter(serial.typeArgument);
  }
}
