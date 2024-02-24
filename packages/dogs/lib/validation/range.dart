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

import "package:conduit_open_api/v3.dart";
import "package:dogs_core/dogs_core.dart";

/// A [FieldValidator] that restricts a numeric type to be positive.
const positive = Range(min: 0, minExclusive: true);

/// A [FieldValidator] that restricts a numeric type to be positive or zero.
const positiveOrZero = Range(min: 0, minExclusive: false);

/// A [FieldValidator] that restricts a numeric type to be negative.
const negative = Range(max: 0, maxExclusive: true);

/// A [FieldValidator] that restricts a numeric type to be negative or zero.
const negativeOrZero = Range(max: 0, maxExclusive: false);

/// A [FieldValidator] that restricts a numeric type to a minimum and maximum value.
class Range extends StructureMetadata
    implements APISchemaObjectMetaVisitor, FieldValidator {
  /// The minimum number of items. (exclusivity depends on [minExclusive])
  final num? min;

  /// The maximum number of items. (exclusivity depends on [maxExclusive])
  final num? max;

  /// Whether [min] is exclusive.
  final bool minExclusive;

  /// Whether [max] is exclusive.
  final bool maxExclusive;

  /// Restricts the maximum size for a numeric type to [min] and/or [max].
  /// By default, both [min] and [max] are inclusive.
  const Range({
    this.min,
    this.max,
    this.minExclusive = false,
    this.maxExclusive = false,
  });

  /// The message id used for the annotation result.
  static const String messageId = "number-range";

  @override
  void visit(APISchemaObject object) {
    object.minimum = min;
    object.maximum = max;
    object.exclusiveMinimum = minExclusive;
    object.exclusiveMaximum = maxExclusive;
  }

  @override
  getCachedValue(DogStructure<dynamic> structure, DogStructureField field) {
    return field.iterableKind != IterableKind.none;
  }

  @override
  bool isApplicable(DogStructure structure, DogStructureField field) {
    return field.serial.typeArgument == int ||
        field.serial.typeArgument == double;
  }

  @override
  bool validate(cached, value, DogEngine engine) {
    if (cached as bool) {
      if (value == null) return true;
      return (value as Iterable).every((e) => _validateSingle(e));
    } else {
      return _validateSingle(value);
    }
  }

  bool _validateSingle(dynamic value) {
    if (value == null) return true;
    final n = value as num;
    if (min != null) {
      if (minExclusive) {
        if (n <= min!) return false;
      } else {
        if (n < min!) return false;
      }
    }

    if (max != null) {
      if (maxExclusive) {
        if (n >= max!) return false;
      } else {
        if (n > max!) return false;
      }
    }

    return true;
  }

  @override
  AnnotationResult annotate(cached, value, DogEngine engine) {
    final isValid = validate(cached, value, engine);
    if (isValid) return AnnotationResult.empty();
    return AnnotationResult(messages: [
      AnnotationMessage(
          id: messageId,
          message: "Must be between %min% and %max% characters long.")
    ]).withVariables({
      "min": min.toString(),
      "max": max.toString(),
      "minExclusive": minExclusive ? "exclusive" : "inclusive",
      "maxExclusive": maxExclusive ? "exclusive" : "inclusive",
    });
  }
}

/// A [FieldValidator] that restricts a numeric type to a minimum value.
class Minimum extends StructureMetadata
    implements APISchemaObjectMetaVisitor, FieldValidator {
  /// The minimum number of items. (exclusivity depends on [minExclusive])
  final num? min;

  /// Whether [min] is exclusive.
  final bool minExclusive;

  /// Restricts the maximum size for a numeric type to [min].
  const Minimum(
    this.min, {
    this.minExclusive = false,
  });

  /// The message id used for the annotation result.
  static const String messageId = "number-minimum";

  @override
  void visit(APISchemaObject object) {
    object.minimum = min;
    object.exclusiveMinimum = minExclusive;
  }

  @override
  getCachedValue(DogStructure<dynamic> structure, DogStructureField field) {
    return field.iterableKind != IterableKind.none;
  }

  @override
  bool isApplicable(DogStructure structure, DogStructureField field) {
    return field.serial.typeArgument == int ||
        field.serial.typeArgument == double;
  }

  @override
  bool validate(cached, value, DogEngine engine) {
    if (cached as bool) {
      if (value == null) return true;
      return (value as Iterable).every((e) => _validateSingle(e));
    } else {
      return _validateSingle(value);
    }
  }

  bool _validateSingle(dynamic value) {
    if (value == null) return true;
    final n = value as num;
    if (min == null) return true;
    if (minExclusive) {
      return n > min!;
    } else {
      return n >= min!;
    }
  }

  @override
  AnnotationResult annotate(cached, value, DogEngine engine) {
    final isValid = validate(cached, value, engine);
    if (isValid) return AnnotationResult.empty();
    return AnnotationResult(messages: [
      AnnotationMessage(
          id: messageId, message: "Must be more than %min% (%minExclusive%).")
    ]).withVariables({
      "min": min.toString(),
      "minExclusive": minExclusive ? "exclusive" : "inclusive",
    });
  }
}

/// A [FieldValidator] that restricts a numeric type to a maximum value.
class Maximum extends StructureMetadata
    implements APISchemaObjectMetaVisitor, FieldValidator {
  /// The maximum number of items. (exclusivity depends on [maxExclusive])
  final num? max;

  /// Whether [max] is exclusive.
  final bool maxExclusive;

  /// Restricts the value for a numeric type to [max].
  const Maximum(
    this.max, {
    this.maxExclusive = false,
  });

  static const String messageId = "number-maximum";

  @override
  void visit(APISchemaObject object) {
    object.maximum = max;
    object.exclusiveMaximum = maxExclusive;
  }

  @override
  getCachedValue(DogStructure<dynamic> structure, DogStructureField field) {
    return field.iterableKind != IterableKind.none;
  }

  @override
  bool isApplicable(DogStructure structure, DogStructureField field) {
    return field.serial.typeArgument == int ||
        field.serial.typeArgument == double;
  }

  @override
  bool validate(cached, value, DogEngine engine) {
    if (cached as bool) {
      if (value == null) return true;
      return (value as Iterable).every((e) => _validateSingle(e));
    } else {
      return _validateSingle(value);
    }
  }

  bool _validateSingle(dynamic value) {
    if (value == null) return true;
    final n = value as num;
    if (max == null) return true;
    if (maxExclusive) {
      return n < max!;
    } else {
      return n <= max!;
    }
  }

  @override
  AnnotationResult annotate(cached, value, DogEngine engine) {
    final isValid = validate(cached, value, engine);
    if (isValid) return AnnotationResult.empty();
    return AnnotationResult(messages: [
      AnnotationMessage(
          id: messageId, message: "Must be less than %max% (%maxExclusive%).")
    ]).withVariables({
      "max": max.toString(),
      "maxExclusive": maxExclusive ? "exclusive" : "inclusive",
    });
  }
}
