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

/// Requires a field to be deeply validated.
/// Example: You have a class Group with a field `List<Person> members` as well as
/// a type Person which is validatable. You can then annotate your field
/// `List<Person> members` with @validated to validate all members when validating
/// your container.
const validated = Validated();

/// A [FieldValidator] that requires a field to be deeply validated.
class Validated extends FieldValidator<ValidatedCacheEntry> implements StructureMetadata {
  /// Requires a field to be deeply validated.
  /// Example: You have a class Group with a field `List<Person> members` as well as
  /// a type Person which is validatable. You can then annotate your field
  /// `List<Person> members` with @validated to validate all members when validating
  /// your container.
  const Validated();

  /// The message id used for the annotation result.
  static const String messageId = "validated";

  @override
  ValidatedCacheEntry getCachedValue(DogStructureField field) {
    return ValidatedCacheEntry(
        field.serial.typeArgument, field.iterableKind != IterableKind.none);
  }

  @override
  void verifyUsage(DogStructureField field) {
    if (!field.structure) throw DogException("Field '${field.name}' must not be primitive in order to use @validated.");
  }

  @override
  bool validate(ValidatedCacheEntry cached, value, DogEngine engine) {
    final validatorMode =
        engine.modeRegistry.validation.forTypeNullable(cached.serial, engine);
    if (validatorMode == null) return true;
    if (cached.iterable) {
      if (value == null) return true;
      return (value as Iterable)
          .every((e) => _validateSingle(e, validatorMode, engine));
    } else {
      return _validateSingle(value, validatorMode, engine);
    }
  }

  bool _validateSingle(value, ValidationMode mode, DogEngine engine) {
    if (value == null) return true;
    return mode.validate(value, engine);
  }

  @override
  AnnotationResult annotate(ValidatedCacheEntry cached, value, DogEngine engine) {
    final isValid = validate(cached, value, engine);
    if (isValid) return AnnotationResult.empty();
    return AnnotationResult(messages: [
      AnnotationMessage(id: messageId, message: "Invalid value")
    ]);
  }
}

class ValidatedCacheEntry {
  Type serial;
  bool iterable;

  ValidatedCacheEntry(this.serial, this.iterable);
}