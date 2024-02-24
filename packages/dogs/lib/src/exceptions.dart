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

/// General exception for dogs related errors.
abstract class DogException implements Exception {
  /// The message of this exception.
  String get message;

  /// Creates a new [DogException] with the given [message].
  factory DogException(String message) {
    return _DogExceptionImpl(message);
  }
}

class _DogExceptionImpl implements DogException {
  @override
  final String message;

  _DogExceptionImpl(this.message);

  @override
  String toString() {
    return "DogException: $message";
  }
}

/// Exception thrown when a [DogConverter] fails to convert a value.
abstract class DogSerializerException implements DogException {
  @override
  String get message;

  /// The [DogConverter] that failed the conversion. May be null if no converter
  /// was involved, for example when serializing native values.
  DogConverter? get converter;

  /// The [DogStructure] that failed the conversion.
  /// May be null if no structure was involved.
  DogStructure? get structure;

  /// The original exception that has been caught by the [DogConverter].
  /// May be null if no nested exception was involved.
  Object? get cause;

  /// The stacktrace of the original exception.
  /// May be null if no nested exception was involved.
  StackTrace? get innerStackTrace;

  /// Creates a new [DogSerializerException] with the given attributes.
  factory DogSerializerException({
    required String message,
    DogConverter? converter,
    DogStructure? structure,
    Object? cause,
    StackTrace? innerStackTrace,
  }) {
    return _DogSerializerExceptionImpl(
        message, converter, structure, cause, innerStackTrace);
  }

  @override
  String toString() {
    return _formatException("DogSerializerException", message, {
      if (cause != null) "cause": cause,
      if (converter != null) "converter": converter,
      if (structure != null) "structure": structure,
      if (innerStackTrace != null) "innerStackTrace": innerStackTrace,
    });
  }
}

class _DogSerializerExceptionImpl implements DogSerializerException {
  @override
  final String message;
  @override
  final DogConverter? converter;
  @override
  final DogStructure? structure;
  @override
  final Object? cause;
  @override
  final StackTrace? innerStackTrace;

  _DogSerializerExceptionImpl(this.message, this.converter, this.structure,
      this.cause, this.innerStackTrace);
}

/// Specific [DogSerializerException] thrown when a [DogConverter] fails to convert a field.
/// Contains the [DogStructureField] that failed the conversion.
class DogFieldSerializerException implements DogSerializerException {
  @override
  final String message;
  @override
  final DogConverter? converter;
  @override
  final DogStructure? structure;
  @override
  final Object? cause;
  @override
  final StackTrace? innerStackTrace;

  /// The [DogStructureField] that failed the conversion.
  final DogStructureField field;

  /// Creates a new [DogFieldSerializerException] with the given attributes.
  DogFieldSerializerException(this.message, this.converter, this.structure,
      this.field, this.cause, this.innerStackTrace);

  @override
  String toString() {
    return _formatException("DogFieldSerializerException", message, {
      if (cause != null) "cause": cause,
      if (converter != null) "converter": converter,
      if (structure != null) "structure": structure,
      "field": field,
      if (innerStackTrace != null) "innerStackTrace": innerStackTrace,
    });
  }
}

/// Exception thrown when the [DogEngine] fails to project a document.
class DogProjectionException implements DogException {
  @override
  final String message;

  /// The document that failed the projection.
  final Map<String, dynamic>? document;

  /// The object that failed the projection.
  final Object? object;

  /// The [ProjectionTransformer] that failed the projection (if any).
  final ProjectionTransformer? transformer;

  /// The original exception that has been caught by the [DogEngine].
  /// May be null if no nested exception was involved.
  final Object? cause;

  /// The stacktrace of the original exception.
  /// May be null if no nested exception was involved.
  final StackTrace? innerStackTrace;

  /// Creates a new [DogProjectionException] with the given attributes.
  const DogProjectionException({
    required this.message,
    this.document,
    this.object,
    this.transformer,
    this.cause,
    this.innerStackTrace,
  });

  @override
  String toString() {
    return _formatException("DogProjectionException", message, {
      if (document != null) "document": document,
      if (object != null) "object": object,
      if (transformer != null) "transformer": transformer,
      if (cause != null) "cause": cause,
      if (innerStackTrace != null) "innerStackTrace": innerStackTrace,
    });
  }
}

/// Formats an exception with attributes into a nicer looking message.
String _formatException(
    String name, String message, Map<String, dynamic> fields) {
  return "$name: $message\n${fields.entries.map((e) => "  ${e.key}: ${e.value}").join("\n")}";
}
