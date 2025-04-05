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
import "package:meta/meta.dart";

/// Operation mode that provides a way to validate objects and return
/// validation related error messages as annotations.
abstract class ValidationMode<T> implements OperationMode<T> {
  /// Validates the given [value] and returns true if the value is valid.
  bool validate(T value, DogEngine engine);

  /// Annotates the given [value] and returns the result as an [AnnotationResult].
  AnnotationResult annotate(T value, DogEngine engine);

  /// Creates a new [ValidationMode] with the given [initializer], [validator]
  /// and [annotator].
  static ValidationMode<T> create<T, IR>(
      {IR? Function(DogEngine engine)? initializer,
      AnnotationResult Function(T value, DogEngine engine, IR? cached)?
          annotator,
      required bool Function(T value, DogEngine engine, IR? cached)
          validator}) {
    final IR? Function(DogEngine) initializerFunc =
        initializer ?? _InlineValidationMode._noInit;
    final AnnotationResult Function(T, DogEngine, IR?) annotatorFunc =
        annotator ?? _InlineValidationMode._noAnnotate;
    return _InlineValidationMode(initializerFunc, validator, annotatorFunc);
  }
}

class _InlineValidationMode<T, IR> extends ValidationMode<T>
    with TypeCaptureMixin<T> {
  static IR? _noInit<IR>(DogEngine engine) => null;

  static AnnotationResult _noAnnotate<T, IR>(
          T value, DogEngine engine, IR? cached) =>
      AnnotationResult.empty();

  IR? Function(DogEngine engine) initializer;
  bool Function(T value, DogEngine engine, IR? cached) validator;
  AnnotationResult Function(T value, DogEngine engine, IR? cached) annotator;

  IR? _ir;

  _InlineValidationMode(this.initializer, this.validator, this.annotator);

  @override
  void initialise(DogEngine engine) {
    _ir = initializer(engine);
  }

  @override
  bool validate(T value, DogEngine engine) => validator(value, engine, _ir);

  @override
  AnnotationResult annotate(T value, DogEngine engine) =>
      annotator(value, engine, _ir);
}


abstract interface class AnnotationResultLike {
  AnnotationResult asAnnotationResult();
  AnnotationResult operator +(AnnotationResultLike? other);
}

/// Container for validation results.
class AnnotationResult implements AnnotationResultLike {
  /// List of messages produced by the validation.
  final List<AnnotationMessage> messages;

  /// Creates a new [AnnotationResult].
  AnnotationResult({
    required this.messages,
  });

  bool get hasErrors => messages.isNotEmpty;

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

  @override
  AnnotationResult asAnnotationResult() => this;

  @override
  AnnotationResult operator +(AnnotationResultLike? other) {
    return AnnotationResult(
        messages: [...messages, ...?other?.asAnnotationResult().messages]);
  }
}

/// A single message produced by a validator.
@immutable
class AnnotationMessage implements AnnotationResultLike {
  /// Identifier for the type of the message, like "missing-field".
  /// Multiple messages in a result set may have the same id.
  final String id;

  /// Defines where the message is targeted at.
  /// This must confront to a field name of the referenced structure or may be
  /// null if not applicable to any individual field or if applicable to the
  /// whole structure.
  final String? target;

  /// The message itself.
  /// The engine may translate this message using the [id].
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
        id: id, message: translation, variables: variables, target: target);
  }

  /// Replaces all variables in this message with [variables].
  AnnotationMessage withVariables(Map<String, String> variables) {
    return AnnotationMessage(
        id: id, message: message, variables: variables, target: target);
  }

  /// Replaces the string message with [message].
  AnnotationMessage withMessage(String message) {
    return AnnotationMessage(
        id: id, message: message, variables: variables, target: target);
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AnnotationMessage &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              target == other.target &&
              message == other.message &&
              deepEquality.equals(variables, other.variables);

  @override
  int get hashCode =>
      id.hashCode ^
      target.hashCode ^
      message.hashCode ^
      deepEquality.hash(variables);

  @override
  AnnotationResult operator +(AnnotationResultLike? other) {
    return AnnotationResult(
        messages: [this, ...?other?.asAnnotationResult().messages]);
  }

  @override
  AnnotationResult asAnnotationResult() => AnnotationResult(messages: [this]);
}

/// An exception thrown when validation fails.
class ValidationException implements DogException {
  /// The result of the validation.
  AnnotationResult result;

  /// Creates a new [ValidationException] with the supplied [result].
  ValidationException(this.result);

  @override
  String get message => result.messages.map((e) => e.buildMessage()).join(", ");
}