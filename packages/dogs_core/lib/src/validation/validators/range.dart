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
import "package:dogs_core/src/validation/utils.dart";

/// A [FieldValidator] that restricts a numeric type to be positive.
const positive = Range(min: 0, minExclusive: true);

/// A [FieldValidator] that restricts a numeric type to be positive or zero.
const positiveOrZero = Range(min: 0, minExclusive: false);

/// A [FieldValidator] that restricts a numeric type to be negative.
const negative = Range(max: 0, maxExclusive: true);

/// A [FieldValidator] that restricts a numeric type to be negative or zero.
const negativeOrZero = Range(max: 0, maxExclusive: false);

/// A [FieldValidator] that restricts a numeric type to a minimum and maximum value.
class Range extends FieldValidator<bool> implements SchemaFieldVisitor, StructureMetadata {
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
  void visitSchemaField(SchemaField object) {
    final target = itemSchemaTarget(object);
    if (min != null) {
      if (minExclusive) {
        target[SchemaProperties.exclusiveMinimum] = min;
      } else {
        target[SchemaProperties.minimum] = min;
      }
    }

    if (max != null) {
      if (maxExclusive) {
        target[SchemaProperties.exclusiveMaximum] = max;
      } else {
        target[SchemaProperties.maximum] = max;
      }
    }
  }

  @override
  bool getCachedValue(DogStructureField field) {
    return field.iterableKind != IterableKind.none;
  }

  @override
  void verifyUsage(DogStructureField field) {
    final arg = field.serial.typeArgument;
    if (arg != int && arg != double) {
      throw DogException(
          "Field '${field.name}' must be a int|double/-List/-Iterable to use @Range().");
    }
  }

  @override
  bool validate(bool cached, value, DogEngine engine) {
    if (cached) {
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
  AnnotationResult annotate(bool cached, value, DogEngine engine) {
    final isValid = validate(cached, value, engine);
    if (isValid) return AnnotationResult.empty();
    AnnotationMessage result;
    if (min != null && max == null) {
      result =
          AnnotationMessage(id: messageId, message: "Must be more than %min% (%minExclusive%).");
    } else if (min == null && max != null) {
      result =
          AnnotationMessage(id: messageId, message: "Must be less than %max% (%maxExclusive%)");
    } else {
      result = AnnotationMessage(
          id: messageId,
          message: "Must be between %min%(%minExclusive%) and %max%(%maxExclusive%).");
    }

    return AnnotationResult(messages: [result]).withVariables({
      "min": min.toString(),
      "max": max.toString(),
      "minExclusive": minExclusive ? "exclusive" : "inclusive",
      "maxExclusive": maxExclusive ? "exclusive" : "inclusive",
    });
  }
}

/// A [FieldValidator] that restricts a numeric type to a minimum value.
class Minimum extends FieldValidator<bool> implements SchemaFieldVisitor, StructureMetadata {
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
  void visitSchemaField(SchemaField object) {
    final target = itemSchemaTarget(object);
    if (min != null) {
      if (minExclusive) {
        target[SchemaProperties.exclusiveMinimum] = min;
      } else {
        target[SchemaProperties.minimum] = min;
      }
    }
  }

  @override
  bool getCachedValue(DogStructureField field) {
    return field.iterableKind != IterableKind.none;
  }

  @override
  void verifyUsage(DogStructureField field) {
    final arg = field.serial.typeArgument;
    if (arg != int && arg != double) {
      throw DogException(
          "Field '${field.name}' must be a int|double/-List/-Iterable to use @Minimum().");
    }
  }

  @override
  bool validate(bool cached, value, DogEngine engine) {
    if (cached) {
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
  AnnotationResult annotate(bool cached, value, DogEngine engine) {
    final isValid = validate(cached, value, engine);
    if (isValid) return AnnotationResult.empty();
    return AnnotationResult(messages: [
      AnnotationMessage(id: messageId, message: "Must be more than %min% (%minExclusive%).")
    ]).withVariables({
      "min": min.toString(),
      "minExclusive": minExclusive ? "exclusive" : "inclusive",
    });
  }
}

/// A [FieldValidator] that restricts a numeric type to a maximum value.
class Maximum extends FieldValidator<bool> implements SchemaFieldVisitor, StructureMetadata {
  /// The maximum number of items. (exclusivity depends on [maxExclusive])
  final num? max;

  /// Whether [max] is exclusive.
  final bool maxExclusive;

  /// Restricts the value for a numeric type to [max].
  const Maximum(
    this.max, {
    this.maxExclusive = false,
  });

  /// The message id used for the annotation result.
  static const String messageId = "number-maximum";

  @override
  void visitSchemaField(SchemaField object) {
    final target = itemSchemaTarget(object);
    if (max != null) {
      if (maxExclusive) {
        target[SchemaProperties.exclusiveMaximum] = max;
      } else {
        target[SchemaProperties.maximum] = max;
      }
    }
  }

  @override
  bool getCachedValue(DogStructureField field) {
    return field.iterableKind != IterableKind.none;
  }

  @override
  void verifyUsage(DogStructureField field) {
    final arg = field.serial.typeArgument;
    if (arg != int && arg != double) {
      throw DogException(
          "Field '${field.name}' must be a int|double/-List/-Iterable to use @Maximum().");
    }
  }

  @override
  bool validate(bool cached, value, DogEngine engine) {
    if (cached) {
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
  AnnotationResult annotate(bool cached, value, DogEngine engine) {
    final isValid = validate(cached, value, engine);
    if (isValid) return AnnotationResult.empty();
    return AnnotationResult(messages: [
      AnnotationMessage(id: messageId, message: "Must be less than %max% (%maxExclusive%)")
    ]).withVariables({
      "max": max.toString(),
      "maxExclusive": maxExclusive ? "exclusive" : "inclusive",
    });
  }
}
