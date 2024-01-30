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

import "dart:convert";

import "package:collection/collection.dart";
import "package:dogs_core/dogs_core.dart";

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

  /// (Deep-)Clones this graph value.
  DogGraphValue clone();

  String describe(int indent) {
    return "$runtimeType(${coerceString()})";
  }

  String toDescriptionString() {
    return describe(0);
  }

  /// Returns a [DogGraphValue] for the native value [value].
  /// All values that can be serialised by [jsonEncode] are considered native.
  /// Only values which fulfill [isNative] or [Iterable] and [Map] instances
  /// containing only value which fulfill [isNative] are convertible.
  @Deprecated("Moved to DefaultNativeCodec")
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
  @Deprecated("Moved to DefaultNativeCodec")
  static bool isNative(dynamic value) {
    return (value == null ||
        value is String ||
        value is int ||
        value is double ||
        value is bool);
  }
}

class DogNative extends DogGraphValue {
  final Object value;
  final String? label;

  const DogNative(this.value, [this.label]);

  @override
  dynamic coerceNative() {
    return value;
  }

  @override
  String coerceString() {
    return value.toString();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DogString &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  DogGraphValue clone() {
    return this;
  }

  @override
  String describe(int indent) {
    if (label == null) {
      return "Native: $value";
    } else {
      return "Native[$label]: $value";
    }
  }
}

class DogString extends DogGraphValue {
  final String value;

  const DogString(this.value);

  @override
  String coerceString() => value;

  @override
  String coerceNative() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DogString &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  DogGraphValue clone() => DogString(value);
}

class DogInt extends DogGraphValue {
  final int value;

  const DogInt(this.value);

  @override
  String coerceString() => value.toString();

  @override
  int coerceNative() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DogInt &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  DogGraphValue clone() => DogInt(value);
}

class DogDouble extends DogGraphValue {
  final double value;

  const DogDouble(this.value);

  @override
  String coerceString() => value.toString();

  @override
  double coerceNative() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DogDouble &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  DogGraphValue clone() => DogDouble(value);
}

class DogBool extends DogGraphValue {
  final bool value;

  const DogBool(this.value);

  @override
  String coerceString() => value.toString();

  @override
  bool coerceNative() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DogBool &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  DogGraphValue clone() => DogBool(value);
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

  @override
  DogGraphValue clone() => DogNull();
}

class DogList extends DogGraphValue {
  final List<DogGraphValue> value;

  const DogList(this.value);

  @override
  String coerceString() => "[${value.map((e) => e.coerceString()).join(", ")}]";

  @override
  List<dynamic> coerceNative() => value.map((e) => e.coerceNative()).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DogList &&
          runtimeType == other.runtimeType &&
          ListEquality().equals(value, other.value);

  @override
  int get hashCode => value.hashCode;

  @override
  DogGraphValue clone() => DogList(value.map((e) => e.clone()).toList());

  @override
  String describe(int indent) {
    StringBuffer buffer = StringBuffer();
    buffer.writeln(runtimeType);
    value.forEachIndexed((key, value) {
      buffer.write("${"  " * (indent + 1)}[$key]: ");
      buffer.writeln(value.describe(indent + 2).trimRight());
    });
    return buffer.toString().trimRight();
  }
}

class DogMap extends DogGraphValue {
  final Map<DogGraphValue, DogGraphValue> value;

  const DogMap(this.value);

  @override
  String coerceString() =>
      "{${value.entries.map((e) => "${e.key.coerceString()}: ${e.value.coerceString()}").join(", ")}}";

  @override
  Map<dynamic, dynamic> coerceNative() => value
      .map((key, value) => MapEntry(key.coerceNative(), value.coerceNative()));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DogMap &&
          runtimeType == other.runtimeType &&
          MapEquality().equals(value, other.value);

  @override
  int get hashCode => value.hashCode;

  DogMap merge(DogMap map) {
    return DogMap(mergeMaps(value, map.value)
        .map((key, value) => MapEntry(key.clone(), value.clone())));
  }

  @override
  DogGraphValue clone() =>
      DogMap(value.map((key, value) => MapEntry(key.clone(), value.clone())));

  @override
  String describe(int indent) {
    StringBuffer buffer = StringBuffer();
    buffer.writeln(runtimeType);
    value.forEach((key, value) {
      buffer.write("${"  " * (indent + 1)}[${key.coerceString()}]: ");
      buffer.writeln(value.describe(indent + 2).trimRight());
    });
    return buffer.toString().trimRight();
  }
}
