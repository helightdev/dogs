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

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dogs/dogs.dart';

/// Graph node of the serialized DOG graph.
abstract class DogGraphValue {

  const DogGraphValue();

  /// Returns a string representation of this dog value.
  String coerceString() => "";

  /// Converts this value to a native one.
  /// All values that can be serialised by [jsonEncode] are considered native.
  dynamic coerceNative() => null;

  /// Accepts an [DogVisitor].
  void accept(DogVisitor visitor) {
    visitor.visit(this);
  }

  /// Returns a [DogGraphValue] for the native value [value].
  /// All values that can be serialised by [jsonEncode] are considered native.
  /// Only values which fulfill [isNative] or [Iterable] and [Map] instances
  /// containing only value which fulfill [isNative] are convertible.
  static DogGraphValue fromNative(dynamic value) {
    if (value == null) return DogNull();
    if (value is String) return DogString(value);
    if (value is int) return DogInt(value);
    if (value is double) return DogDouble(value);
    if (value is bool) return DogBool(value);
    if (value is Iterable) {
      return DogList(value.map((e) => fromNative(e)).toList());
    }
    if (value is Map) {
      return DogMap(value
          .map((key, value) => MapEntry(fromNative(key), fromNative(value))));
    }

    throw ArgumentError.value(
        value, null, "Can't coerce native value to dart object graph");
  }

  /// Returns true if [value] is of type [String], [int], [double] or [bool].
  static bool isNative(dynamic value) {
    return (value == null ||
        value is String ||
        value is int ||
        value is double ||
        value is bool);
  }
}

class DogString extends DogGraphValue {
  final String value;
  const DogString(this.value);

  @override
  String coerceString() => value;

  @override
  dynamic coerceNative() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DogString &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class DogInt extends DogGraphValue {
  final int value;
  const DogInt(this.value);

  @override
  String coerceString() => value.toString();

  @override
  dynamic coerceNative() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DogInt &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class DogDouble extends DogGraphValue {
  final double value;
  const DogDouble(this.value);

  @override
  String coerceString() => value.toString();

  @override
  dynamic coerceNative() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DogDouble &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class DogBool extends DogGraphValue {
  final bool value;
  const DogBool(this.value);

  @override
  String coerceString() => value.toString();

  @override
  dynamic coerceNative() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DogBool &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class DogNull extends DogGraphValue {
  const DogNull();

  @override
  String coerceString() => "null";

  @override
  dynamic coerceNative() => null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DogNull && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class DogList extends DogGraphValue {
  final List<DogGraphValue> value;
  const DogList(this.value);

  @override
  String coerceString() => "[${value.map((e) => e.coerceString()).join(", ")}]";

  @override
  dynamic coerceNative() => value.map((e) => e.coerceNative()).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DogList &&
          runtimeType == other.runtimeType &&
          ListEquality().equals(value, other.value);

  @override
  int get hashCode => value.hashCode;
}

class DogMap extends DogGraphValue {
  final Map<DogGraphValue, DogGraphValue> value;
  const DogMap(this.value);

  @override
  String coerceString() =>
      "{${value.entries.map((e) => "${e.key.coerceString()}: ${e.value.coerceString()}").join(", ")}}";

  @override
  dynamic coerceNative() => value
      .map((key, value) => MapEntry(key.coerceNative(), value.coerceNative()));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DogMap &&
          runtimeType == other.runtimeType &&
          MapEquality().equals(value, other.value);

  @override
  int get hashCode => value.hashCode;
}
