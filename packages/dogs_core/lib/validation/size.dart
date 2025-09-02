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

/// A [FieldValidator] that restricts the size of an [Iterable].
class SizeRange extends FieldValidator implements SchemaFieldVisitor, StructureMetadata {
  /// The minimum number of items. (inclusive)
  final int? min;

  /// The maximum number of items. (inclusive)
  final int? max;

  /// Restricts this [Iterable]s item count to [min] (inclusive) and/or [max] (inclusive).
  const SizeRange({this.min, this.max});

  /// The message id used for the annotation result.
  static const String messageId = "size-range";

  @override
  void visitSchemaField(SchemaField object) {
    if (min != null) object[SchemaProperties.minItems] = min;
    if (max != null) object[SchemaProperties.maxItems] = max;
  }

  @override
  getCachedValue(DogStructureField field) {
    return null;
  }

  @override
  void verifyUsage(DogStructureField field) {
    if (field.iterableKind == IterableKind.none) {
      throw DogException("Field '${field.name}' must be a List/Iterable to use @SizeRange().");
    }
  }

  @override
  bool validate(cached, value, DogEngine engine) {
    if (value == null) return true;
    final it = value as Iterable;

    if (min != null) {
      if (it.length < min!) return false;
    }

    if (max != null) {
      if (it.length > max!) return false;
    }

    return true;
  }

  @override
  AnnotationResult annotate(cached, value, DogEngine engine) {
    final isValid = validate(cached, value, engine);
    if (isValid) return AnnotationResult.empty();
    return AnnotationResult(messages: [
      AnnotationMessage(id: messageId, message: "Must have between %min% and %max% items")
    ]).withVariables({
      "min": min.toString(),
      "max": max.toString(),
    });
  }
}
