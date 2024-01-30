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

abstract class DogException implements Exception {
  String get message;

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

abstract class DogSerializerException implements DogException {
  @override
  String get message;
  DogConverter? get converter;
  DogStructure? get structure;
  Object? get cause;
  StackTrace? get innerStackTrace;

  factory DogSerializerException({
    required String message,
    DogConverter? converter,
    DogStructure? structure,
    Object? cause,
    StackTrace? innerStackTrace,
  }) {
    return _DogSerializerExceptionImpl(message, converter, structure, cause, innerStackTrace);
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

  _DogSerializerExceptionImpl(
      this.message, this.converter, this.structure, this.cause, this.innerStackTrace);
}

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
  final DogStructureField field;
  
  DogFieldSerializerException(this.message, this.converter, this.structure, this.field, this.cause, this.innerStackTrace);

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

String _formatException(String name, String message, Map<String,dynamic> fields) {
  return "$name: $message\n${fields.entries.map((e) => "  ${e.key}: ${e.value}").join("\n")}";
}