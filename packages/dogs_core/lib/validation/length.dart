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
import "package:dogs_core/validation/utils.dart";

/// A [FieldValidator] that restricts the length of a [String].
class LengthRange extends FieldValidator<bool>
    implements SchemaFieldVisitor, StructureMetadata {
  /// The minimum length. (inclusive)
  final int? min;

  /// The maximum length. (inclusive)
  final int? max;

  /// Restricts the length of this [String] to [min] (inclusive) and/or [max] (inclusive).
  const LengthRange({this.min, this.max});

  /// The message id used for the annotation result.
  static const String messageId = "length-range";

  /// The message id used when only the min length is set.
  static const String messageMinId = "length-range-min";

  /// The message id used when only the max length is set.
  static const String messageMaxId = "length-range-max";

  @override
  void visitSchemaField(SchemaField object) {
    final target = itemSchemaTarget(object);
    if (min != null) target[SchemaProperties.minLength] = min;
    if (max != null) target[SchemaProperties.maxLength] = max;
  }

  @override
  bool getCachedValue(DogStructureField field) {
    return field.iterableKind != IterableKind.none;
  }

  @override
  void verifyUsage(DogStructureField field) {
    if (field.serial.typeArgument != String) {
      throw DogException(
          "Field '${field.name}' must be a String/-List/-Iterable to use @LengthRange().");
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
    final str = value as String;
    if (min != null) {
      if (str.length < min!) return false;
    }

    if (max != null) {
      if (str.length > max!) return false;
    }

    return true;
  }

  @override
  AnnotationResult annotate(bool cached, value, DogEngine engine) {
    final isValid = validate(cached, value, engine);
    if (isValid) return AnnotationResult.empty();
    if (max == null) {
      return AnnotationResult(messages: [
        AnnotationMessage(
            id: messageMinId, message: "Must be at least %min% characters long")
      ]).withVariables({
        "min": min.toString(),
      });
    } else if (min == null) {
      return AnnotationResult(messages: [
        AnnotationMessage(
            id: messageMaxId, message: "Must be at most %max% characters long")
      ]).withVariables({
        "max": max.toString(),
      });
    }

    return AnnotationResult(messages: [
      AnnotationMessage(
          id: messageId,
          message: "Must be between %min% and %max% characters long")
    ]).withVariables({
      "min": min.toString(),
      "max": max.toString(),
    });
  }
}
