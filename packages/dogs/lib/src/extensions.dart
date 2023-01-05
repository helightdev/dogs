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

abstract class TypeCaptureMixin<T> {
  Type get typeArgument => T;
  Type get deriveListType => List<T>;
  Type get deriveSetType => Set<T>;
  Type get deriveIterableType => Iterable<T>;
}

extension DogsMapExtension<K, V> on Map<K, V> {
  Type get keyTypeArgument => K;
  Type get valueTypeArgument => V;
}

extension DogEngineUsability on DogEngine {
  T copy<T>(T value, [Map<String, dynamic>? overrides]) {
    return copyObject(value, overrides, T);
  }

  DogGraphValue toGraph<T>(T value) => convertObjectToGraph(value, T);

  T fromGraph<T>(DogGraphValue value) => convertObjectFromGraph(value, T);
}

mixin DogsMixin on Object {
  dynamic copy([Map<String, dynamic>? overrides]) {
    return DogEngine.internalSingleton.copyObject(this, overrides, runtimeType);
  }

  @override
  String toString() {
    return "$runtimeType ${DogEngine.internalSingleton.convertObjectToGraph(this, runtimeType).coerceString()}";
  }
}
