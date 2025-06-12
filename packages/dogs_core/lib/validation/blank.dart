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

/// Requires non-null strings to not be blank.
const notBlank = NotBlank();

/// A [FieldValidator] that requires non-null strings to not be blank.
class NotBlank extends FieldValidator<bool> implements StructureMetadata {
  /// Requires non-null strings to not be blank.
  const NotBlank();

  /// The message id used for the annotation result.
  static const String messageId = "not-blank";

  @override
  bool getCachedValue(DogStructureField field) {
    return field.iterableKind != IterableKind.none;
  }

  @override
  void verifyUsage(DogStructureField field) {
    if (field.serial.typeArgument != String) {
      throw DogException(
          "Field '${field.name}' must be a String/-List/-Iterable to use @notBlank.");
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
    return str.trim().isNotEmpty;
  }

  @override
  AnnotationResult annotate(bool cached, value, DogEngine engine) {
    final isValid = validate(cached, value, engine);
    if (isValid) return AnnotationResult.empty();
    return AnnotationResult(messages: [
      AnnotationMessage(id: messageId, message: "Must not be blank")
    ]);
  }
}
