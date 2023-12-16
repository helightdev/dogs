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

import 'package:conduit_open_api/v3.dart';
import 'package:dogs_core/dogs_core.dart';

class LengthRange extends StructureMetadata
    implements APISchemaObjectMetaVisitor, FieldValidator {
  final int? min;
  final int? max;

  /// Restricts the length of this [String] to [min] (inclusive) and/or [max] (inclusive).
  const LengthRange({this.min, this.max});

  static const String messageId = "length-range";

  @override
  void visit(APISchemaObject object) {
    object.minLength = min;
    object.maxLength = max;
  }

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
    if (min != null) {
      if (str.length < min!) return false;
    }

    if (max != null) {
      if (str.length > max!) return false;
    }

    return true;
  }

  @override
  AnnotationResult annotate(cached, value, DogEngine engine) {
    var isValid = validate(cached, value, engine);
    if (isValid) return AnnotationResult.empty();
    return AnnotationResult(
        messages: [AnnotationMessage(id: messageId, message: "Must be between %min% and %max% characters long.")]
    ).withVariables({
      "min": min.toString(),
      "max": max.toString(),
    });
  }
}
