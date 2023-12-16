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

/// Requires non-null strings to not be blank.
const notBlank = NotBlank();

class NotBlank extends StructureMetadata implements FieldValidator {
  /// Requires non-null strings to not be blank.
  const NotBlank();

  static const String messageId = "not-blank";

  @override
  getCachedValue(DogStructure<dynamic> structure, DogStructureField field) {
    return field.iterableKind != IterableKind.none;
  }

  @override
  bool isApplicable(DogStructure<dynamic> structure, DogStructureField field) {
    return field.serial.typeArgument == String;
  }

  @override
  bool validate(cached, value, DogEngine engine) {
    if (cached as bool) {
      if (value == null) return true;
      return (value as Iterable).every((e) => validateSingle(e));
    } else {
      return validateSingle(value);
    }
  }

  bool validateSingle(dynamic value) {
    if (value == null) return true;
    var str = value as String;
    return str.trim().isNotEmpty;
  }

  @override
  AnnotationResult annotate(cached, value, DogEngine engine) {
    var isValid = validate(cached, value, engine);
    if (isValid) return AnnotationResult.empty();
    return AnnotationResult(
        messages: [AnnotationMessage(id: messageId, message: "Must not be blank.")]
    );
  }
}
