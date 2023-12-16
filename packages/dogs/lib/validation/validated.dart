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

/// Requires a field to be deeply validated.
/// Example: You have a class Group with a field `List<Person> members` as well as
/// a type Person which is validatable. You can then annotate your field
/// `List<Person> members` with @validated to validate all members when validating
/// your container.
const validated = Validated();

class Validated extends StructureMetadata implements FieldValidator {
  /// Requires a field to be deeply validated.
  /// Example: You have a class Group with a field `List<Person> members` as well as
  /// a type Person which is validatable. You can then annotate your field
  /// `List<Person> members` with @validated to validate all members when validating
  /// your container.
  const Validated();


  static const String messageId = "validated";

  @override
  getCachedValue(DogStructure<dynamic> structure, DogStructureField field) {
    return _ValidatedCacheEntry(
        field.serial.typeArgument, field.iterableKind != IterableKind.none);
  }

  @override
  bool isApplicable(DogStructure structure, DogStructureField field) {
    return field.structure;
  }

  @override
  bool validate(cached, value, DogEngine engine) {
    var entry = cached as _ValidatedCacheEntry;
    var validatorMode =
        engine.modeRegistry.validation.forTypeNullable(entry.serial, engine);
    if (validatorMode == null) return true;
    if (entry.iterable) {
      if (value == null) return true;
      return (value as Iterable)
          .every((e) => validateSingle(e, validatorMode, engine));
    } else {
      return validateSingle(value, validatorMode, engine);
    }
  }

  bool validateSingle(value, ValidationMode mode, DogEngine engine) {
    if (value == null) return true;
    return mode.validate(value, engine);
  }

  @override
  AnnotationResult annotate(cached, value, DogEngine engine) {
    var isValid = validate(cached, value, engine);
    if (isValid) return AnnotationResult.empty();
    return AnnotationResult(
        messages: [AnnotationMessage(id: messageId, message: "Invalid subtree.")]
    );
  }
}

class _ValidatedCacheEntry {
  Type serial;
  bool iterable;

  _ValidatedCacheEntry(this.serial, this.iterable);
}
