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

import "package:collection/collection.dart";
import "package:dogs_core/dogs_core.dart";

/// Property level validator for annotations of [DogStructureField]s.
abstract class FieldValidator {
  /// Property level validator for annotations of [DogStructureField]s.
  const FieldValidator();

  /// Returns true if this validator is applicable for [field].
  bool isApplicable(DogStructure structure, DogStructureField field) => true;

  /// Returns a cached value for this validator. Will be passed to [validate]
  /// on every validation.
  dynamic getCachedValue(DogStructure structure, DogStructureField field);

  /// Validates [value] against this validator.
  bool validate(dynamic cached, dynamic value, DogEngine engine);

  /// Annotates [value] with this validator returning an [AnnotationResult].
  /// This mechanic is used to provide more information about the validation
  /// error.
  AnnotationResult annotate(dynamic cached, dynamic value, DogEngine engine) =>
      AnnotationResult.empty();
}

/// Class level validator for annotations of [ClassValidator]s.
abstract class ClassValidator {
  /// Class level validator for annotations of [ClassValidator]s.
  const ClassValidator();

  /// Returns true if this validator is applicable for [structure].
  bool isApplicable(DogStructure structure) => true;

  /// Returns a cached value for this validator. Will be passed to [validate]
  dynamic getCachedValue(DogStructure structure);

  /// Validates [value] against this validator.
  bool validate(dynamic cached, dynamic value, DogEngine engine);

  /// Annotates [value] with this validator returning an [AnnotationResult].
  /// This mechanic is used to provide more information about the validation
  /// error.
  AnnotationResult annotate(dynamic cached, dynamic value, DogEngine engine) =>
      AnnotationResult.empty();
}

/// Container for validation results.
class AnnotationResult {
  /// List of messages produced by the validation.
  final List<AnnotationMessage> messages;

  /// Creates a new [AnnotationResult].
  AnnotationResult({
    required this.messages,
  });

  /// Translates all messages in this result using [engine].
  AnnotationResult translate(DogEngine engine) {
    return AnnotationResult(
        messages: messages.map((e) => e.translate(engine)).toList());
  }

  /// Replaces all variables in this result with [variables].
  AnnotationResult withVariables(Map<String, String> variables) {
    return AnnotationResult(
        messages: messages.map((e) => e.withVariables(variables)).toList());
  }

  /// Replaces the target of all messages in this result with [target].
  AnnotationResult withTarget(String target) {
    return AnnotationResult(
        messages: messages.map((e) => e.withTarget(target)).toList());
  }

  /// Resolves all message into a list of strings.
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

  /// The place where this annotation was produced.
  /// May be the name of a field or the name of a class.
  final String? target;

  /// The message itself.
  final String message;

  /// Variables used in the message.
  final Map<String, String> variables;

  /// Creates a new [AnnotationMessage].
  AnnotationMessage({
    required this.id,
    required this.message,
    this.target,
    this.variables = const {},
  });

  /// Translates this message using [engine].
  AnnotationMessage translate(DogEngine engine) {
    var translation = engine.findAnnotationTranslation(id);
    translation ??= message;
    return AnnotationMessage(
        id: id, message: translation, variables: variables);
  }

  /// Replaces all variables in this message with [variables].
  AnnotationMessage withVariables(Map<String, String> variables) {
    return AnnotationMessage(id: id, message: message, variables: variables);
  }

  /// Replaces the string message with [message].
  AnnotationMessage withMessage(String message) {
    return AnnotationMessage(id: id, message: message, variables: variables);
  }

  /// Replaces the target of this message with [target].
  AnnotationMessage withTarget(String target) {
    return AnnotationMessage(
        id: id, message: message, variables: variables, target: target);
  }

  /// Builds the message.
  String buildMessage() {
    var result = message;
    variables.forEach((key, value) {
      result = result.replaceAll("%$key%", value);
    });
    return result;
  }
}

/// An exception thrown when validation fails.
class ValidationException implements DogException {
  @override
  String get message => "Validation failed!";
}

/// A [ValidationMode] that provides validation for [DogStructure]s.
class StructureValidation<T> extends ValidationMode<T>
    with TypeCaptureMixin<T> {
  /// The structure this validator is for.
  DogStructure<T> structure;

  /// Creates a new [StructureValidation] for the supplied [structure].
  StructureValidation(this.structure);

  bool _hasValidation = false;
  late Map<ClassValidator, dynamic> _cachedClassValidators;
  late Map<int, List<MapEntry<FieldValidator, dynamic>>> _cachedFieldValidators;

  @override
  void initialise(DogEngine engine) {
    // Create and cache validators eagerly
    _cachedClassValidators =
        Map.fromEntries(structure.annotationsOf<ClassValidator>().where((e) {
      final applicable = e.isApplicable(structure);
      if (applicable) {
        _hasValidation = true;
      } else {
        throw DogException("$e is not applicable in $structure");
      }
      return applicable;
    }).map((e) => MapEntry(e, e.getCachedValue(structure))));

    _cachedFieldValidators =
        Map.fromEntries(structure.fields.mapIndexed((index, field) {
      final validators = field
          .annotationsOf<FieldValidator>()
          .where((e) {
            final applicable = e.isApplicable(structure, field);
            if (applicable) {
              _hasValidation = true;
            } else {
              throw DogException(
                  "$e is not for field $field applicable in $structure");
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
          final fieldValue = structure.proxy.getField(value, pair.key);
          return pair.value
              .any((e) => !e.key.validate(e.value, fieldValue, engine));
        }) &&
        !_cachedClassValidators.entries
            .any((e) => !e.key.validate(e.value, value, engine));
  }

  @override
  AnnotationResult annotate(T value, DogEngine engine) {
    if (!_hasValidation) return AnnotationResult.empty();
    final fieldAnnotations =
        AnnotationResult.combine(_cachedFieldValidators.entries.map((pair) {
      final fieldValue = structure.proxy.getField(value, pair.key);
      final fieldName = structure.fields[pair.key].name;
      return AnnotationResult.combine(pair.value
              .map((e) => e.key.annotate(e.value, fieldValue, engine))
              .toList())
          .withTarget(fieldName);
    }).toList());
    final classAnnotations = AnnotationResult.combine(_cachedClassValidators
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
    final fieldValue = structure.proxy.getField(value, index);
    final fieldName = structure.fields[index].name;
    return AnnotationResult.combine(_cachedFieldValidators[index]!
            .map((e) => e.key.annotate(e.value, fieldValue, engine))
            .toList())
        .withTarget(fieldName)
        .translate(engine);
  }

  /// Annotates the field at [index] with [fieldValue].
  AnnotationResult annotateFieldValue(
      int index, dynamic fieldValue, DogEngine engine) {
    if (!_hasValidation) return AnnotationResult.empty();
    final fieldName = structure.fields[index].name;
    return AnnotationResult.combine(_cachedFieldValidators[index]!
            .map((e) => e.key.annotate(e.value, fieldValue, engine))
            .toList())
        .withTarget(fieldName)
        .translate(engine);
  }
}
