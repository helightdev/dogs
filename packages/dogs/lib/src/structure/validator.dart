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

import 'package:collection/collection.dart';
import 'package:dogs_core/dogs_core.dart';

/// Property level validator for annotations of [DogStructureField]s.
abstract class FieldValidator {
  const FieldValidator();

  bool isApplicable(DogStructure structure, DogStructureField field) => true;

  dynamic getCachedValue(DogStructure structure, DogStructureField field);

  bool validate(dynamic cached, dynamic value, DogEngine engine);

  AnnotationResult annotate(dynamic cached, dynamic value, DogEngine engine) =>
      AnnotationResult.empty();
}

/// Class level validator for annotations of [ClassValidator]s.
abstract class ClassValidator {
  const ClassValidator();

  bool isApplicable(DogStructure structure) => true;

  dynamic getCachedValue(DogStructure structure);

  bool validate(dynamic cached, dynamic value, DogEngine engine);

  AnnotationResult annotate(dynamic cached, dynamic value, DogEngine engine) =>
      AnnotationResult.empty();
}

/// Container for validation results.
class AnnotationResult {
  /// List of messages produced by the validation.
  final List<AnnotationMessage> messages;

  AnnotationResult({
    required this.messages,
  });

  AnnotationResult translate(DogEngine engine) {
    return AnnotationResult(
        messages: messages.map((e) => e.translate(engine)).toList());
  }

  AnnotationResult withVariables(Map<String, String> variables) {
    return AnnotationResult(messages: messages.map((e) => e.withVariables(variables)).toList());
  }

  AnnotationResult withTarget(String target) {
    return AnnotationResult(messages: messages.map((e) => e.withTarget(target)).toList());
  }
  
  List<String> buildMessages() {
    return messages.map((e) => e.buildMessage()).toList();
  }
  
  /// Creates an empty [AnnotationResult].
  AnnotationResult.empty() : messages = const [];

  /// Combines multiple [AnnotationResult]s into one.
  AnnotationResult.combine(List<AnnotationResult> results)
      : messages = results.expand((e) => e.messages).toList();
}

/// A single message produced by a validator.
class AnnotationMessage {
  /// Unique identifier of the message.
  final String id;
  
  final String? target;

  /// The message itself.
  final String message;
  final Map<String, String> variables;

  AnnotationMessage({
    required this.id,
    required this.message,
    this.target,
    this.variables = const {},
  });

  AnnotationMessage translate(DogEngine engine) {
    var translation = engine.findAnnotationTranslation(id);
    translation ??= message;
    return AnnotationMessage(
        id: id, message: translation, variables: variables);
  }

  AnnotationMessage withVariables(Map<String, String> variables) {
    return AnnotationMessage(id: id, message: message, variables: variables);
  }

  AnnotationMessage withMessage(String message) {
    return AnnotationMessage(id: id, message: message, variables: variables);
  }
  
  AnnotationMessage withTarget(String target) {
    return AnnotationMessage(id: id, message: message, variables: variables, target: target);
  }

  String buildMessage() {
    var result = message;
    variables.forEach((key, value) {
      result = result.replaceAll("%$key%", value);
    });
    return result;
  }
}

class ValidationException implements Exception {}

class StructureValidation<T> extends ValidationMode<T>
    with TypeCaptureMixin<T> {
  DogStructure<T> structure;

  StructureValidation(this.structure);

  bool _hasValidation = false;
  late Map<ClassValidator, dynamic> _cachedClassValidators;
  late Map<int, List<MapEntry<FieldValidator, dynamic>>> _cachedFieldValidators;

  @override
  void initialise(DogEngine engine) {
    // Create and cache validators eagerly
    _cachedClassValidators =
        Map.fromEntries(structure.annotationsOf<ClassValidator>().where((e) {
      var applicable = e.isApplicable(structure);
      if (applicable) {
        _hasValidation = true;
      } else {
        print("$e is not applicable in $structure");
      }
      return applicable;
    }).map((e) => MapEntry(e, e.getCachedValue(structure))));

    _cachedFieldValidators =
        Map.fromEntries(structure.fields.mapIndexed((index, field) {
      var validators = field
          .annotationsOf<FieldValidator>()
          .where((e) {
            var applicable = e.isApplicable(structure, field);
            if (applicable) {
              _hasValidation = true;
            } else {
              print("$e is not applicable for $field in $structure");
            }
            return applicable;
          })
          .map((e) => MapEntry(e, e.getCachedValue(structure, field)))
          .toList();
      return MapEntry(index, validators);
    }));
  }

  @override
  bool validate(T value, DogEngine engine) {
    if (!_hasValidation) return true;
    return !_cachedFieldValidators.entries.any((pair) {
          var fieldValue = structure.proxy.getField(value, pair.key);
          return pair.value
              .any((e) => !e.key.validate(e.value, fieldValue, engine));
        }) &&
        !_cachedClassValidators.entries
            .any((e) => !e.key.validate(e.value, value, engine));
  }

  @override
  AnnotationResult annotate(T value, DogEngine engine) {
    if (!_hasValidation) return AnnotationResult.empty();
    var fieldAnnotations =
        AnnotationResult.combine(_cachedFieldValidators.entries.map((pair) {
      var fieldValue = structure.proxy.getField(value, pair.key);
      var fieldName = structure.fields[pair.key].name;
      return AnnotationResult.combine(pair.value
          .map((e) => e.key.annotate(e.value, fieldValue, engine))
          .toList()).withTarget(fieldName);
    }).toList());
    var classAnnotations = AnnotationResult.combine(_cachedClassValidators
        .entries
        .map((e) => e.key.annotate(e.value, value, engine))
        .toList());
    return AnnotationResult.combine([fieldAnnotations, classAnnotations])
        .translate(engine);
  }

  /// Annotates [value] at class level.

  AnnotationResult annotateClass(dynamic value, DogEngine engine) {
    if (!_hasValidation) return AnnotationResult.empty();
    return AnnotationResult.combine(_cachedClassValidators.entries
            .map((e) => e.key.annotate(e.value, value, engine))
            .toList())
        .translate(engine);
  }

  /// Annotates the field at [index] in [value].
  AnnotationResult annotateField(int index, dynamic value, DogEngine engine) {
    if (!_hasValidation) return AnnotationResult.empty();
    var fieldValue = structure.proxy.getField(value, index);
    var fieldName = structure.fields[index].name;
    return AnnotationResult.combine(_cachedFieldValidators[index]!
            .map((e) => e.key.annotate(e.value, fieldValue, engine))
            .toList())
        .withTarget(fieldName).translate(engine);
  }

  /// Annotates the field at [index] with [fieldValue].
  AnnotationResult annotateFieldValue(int index, dynamic fieldValue, DogEngine engine) {
    if (!_hasValidation) return AnnotationResult.empty();
    var fieldName = structure.fields[index].name;
    return AnnotationResult.combine(_cachedFieldValidators[index]!
            .map((e) => e.key.annotate(e.value, fieldValue, engine))
            .toList())
        .withTarget(fieldName).translate(engine);
  }
}