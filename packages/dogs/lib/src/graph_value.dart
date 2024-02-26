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
sealed class DogGraphValue {
  /// Graph node of the serialized DOG graph.
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

  /// Returns a string representation of this dog value with the given [indent].
  String describe(int indent) {
    return "$runtimeType(${coerceString()})";
  }

  /// Returns a string representation of this dog value.
  String toDescriptionString() {
    return describe(0);
  }
}

/// Wrapped native value.
class DogNative extends DogGraphValue {
  /// The actual native value.
  final Object value;

  /// Label denoting the type of the native value.
  final String? label;

  /// Wrapped native value.
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

/// Graph node representing a string value.
class DogString extends DogGraphValue {
  /// The string value of this node.
  final String value;

  /// Graph node representing a string value.
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

/// Graph node representing an integer value.
class DogInt extends DogGraphValue {
  /// The integer value of this node.
  final int value;

  /// Graph node representing an integer value.
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

/// Graph node representing a double value.
class DogDouble extends DogGraphValue {
  /// The double value of this node.
  final double value;

  /// Graph node representing a double value.
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

/// Graph node representing a boolean value.
class DogBool extends DogGraphValue {
  /// The boolean value of this node.
  final bool value;

  /// Graph node representing a boolean value.
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

/// Graph node representing a null value.
class DogNull extends DogGraphValue {
  /// Graph node representing a null value.
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

/// Graph node representing a list value.
class DogList extends DogGraphValue {
  /// The list value of this node.
  final List<DogGraphValue> value;

  /// Graph node representing a list value.
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
    final StringBuffer buffer = StringBuffer();
    buffer.writeln(runtimeType);
    value.forEachIndexed((key, value) {
      buffer.write("${"  " * (indent + 1)}[$key]: ");
      buffer.writeln(value.describe(indent + 2).trimRight());
    });
    return buffer.toString().trimRight();
  }
}

/// Graph node representing a map value.
class DogMap extends DogGraphValue {
  /// The map value of this node.
  final Map<DogGraphValue, DogGraphValue> value;

  /// Graph node representing a map value.
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

  /// Merges this map with the given [map].
  DogMap merge(DogMap map) {
    return DogMap(mergeMaps(value, map.value)
        .map((key, value) => MapEntry(key.clone(), value.clone())));
  }

  @override
  DogGraphValue clone() =>
      DogMap(value.map((key, value) => MapEntry(key.clone(), value.clone())));

  @override
  String describe(int indent) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln(runtimeType);
    value.forEach((key, value) {
      buffer.write("${"  " * (indent + 1)}[${key.coerceString()}]: ");
      buffer.writeln(value.describe(indent + 2).trimRight());
    });
    return buffer.toString().trimRight();
  }
}
