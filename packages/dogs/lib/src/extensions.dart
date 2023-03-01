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

import 'dart:async';

import 'package:dogs_core/dogs_core.dart';
import 'package:lyell/lyell.dart';

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
  DogGraphValue get asGraph => DogGraphValue.fromNative(this);
}

extension DogsListExtension<T> on List<T> {
  DogGraphValue get asGraph => DogGraphValue.fromNative(this);
}

extension DogEngineShortcuts on DogEngine {
  /// Validates the supplied [value] using the [Validatable] mapped to [T].
  /// Throws a [ValidationException] if [validateObject] returns false.
  void validate<T>(T value) {
    var isValid = validateObject(value, T);
    if (!isValid) throw ValidationException();
  }

  /// Creates a copy of the supplied [value] using the [Copyable] associated
  /// with [T]. All given [overrides] will be applied on the resulting object.
  T copy<T>(T value, [Map<String, dynamic>? overrides]) {
    return copyObject(value, overrides, T);
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

mixin DogsMixin<T> on Object implements TypeCapture<T> {
  @override
  Type get typeArgument => T;
  @override
  Type get deriveList => List<T>;
  @override
  Type get deriveSet => Set<T>;
  @override
  Type get deriveIterable => Iterable<T>;
  @override
  Type get deriveFuture => Future<T>;
  @override
  Type get deriveFutureOr => FutureOr<T>;
  @override
  Type get deriveStream => Stream<T>;

  T copy([Map<String, dynamic>? overrides]) {
    return DogEngine.instance
        .copyObject(this, overrides, runtimeType);
  }

  bool get isValid => DogEngine.instance.validateObject(this, T);
  void validate() => DogEngine.instance.validate<T>(this as T);

  @override
  String toString() {
    return "$runtimeType ${DogEngine.instance.convertObjectToGraph(this, runtimeType).coerceString()}";
  }
}

extension StructureExtensions on DogStructure {
  List<dynamic Function(dynamic)> get getters => List.generate(
      fields.length, (index) => (obj) => this.proxy.getField(obj, index));

  List<T> metadataOf<T>() {
    return annotations.whereType<T>().toList();
  }

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

  DogConverter? findConverter() {
    if (converterType == null) {
      return dogs.findAssociatedConverter(serial.typeArgument);
    } else {
      return dogs.findConverter(converterType!);
    }
  }
}
