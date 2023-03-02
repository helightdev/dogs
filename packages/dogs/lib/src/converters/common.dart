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

import 'dart:convert';
import 'dart:typed_data';

import 'package:conduit_open_api/v3.dart';
import 'package:dogs_core/dogs_core.dart';

/// [DogConverter] for [DateTime] instances which encodes the timestamp as a
/// Iso8601 string.
class DateTimeConverter extends DogConverter<DateTime>
    with StructureEmitter<DateTime> {
  @override
  DateTime convertFromGraph(DogGraphValue value, DogEngine engine) {
    var stringValue = value.asString!;
    var datetime = DateTime.parse(stringValue);
    return datetime;
  }

  @override
  DogGraphValue convertToGraph(DateTime value, DogEngine engine) {
    var stringValue = value.toIso8601String();
    return DogString(stringValue);
  }

  @override
  APISchemaObject get output => APISchemaObject.string(format: "date-time");

  @override
  DogStructure get structure => DogStructure<DateTime>.synthetic("DateTime");
}

/// [DogConverter] for [Duration] instances which encode the time difference
/// in milliseconds as an integer
class DurationConverter extends DogConverter<Duration>
    with StructureEmitter<Duration> {
  @override
  Duration convertFromGraph(DogGraphValue value, DogEngine engine) {
    var intValue = value.asInt!;
    return Duration(milliseconds: intValue);
  }

  @override
  DogGraphValue convertToGraph(Duration value, DogEngine engine) {
    return DogInt(value.inMilliseconds);
  }

  @override
  APISchemaObject get output => APISchemaObject.integer();
  @override
  DogStructure get structure => DogStructure<Duration>.synthetic("Duration");
}

/// [DogConverter] for [Uri] instances which encodes the uri into a string.
class UriConverter extends DogConverter<Uri> with StructureEmitter<Uri> {
  @override
  Uri convertFromGraph(DogGraphValue value, DogEngine engine) {
    var stringValue = value.asString!;
    return Uri.parse(stringValue);
  }

  @override
  DogGraphValue convertToGraph(Uri value, DogEngine engine) {
    return DogString(value.toString());
  }

  @override
  APISchemaObject get output => APISchemaObject.string(format: "uri");

  @override
  DogStructure get structure => DogStructure<Uri>.synthetic("Uri");
}

/// [DogConverter] for [Uint8List] instances which encodes the binary data
/// as a base64 string using [base64Encode].
class Uint8ListConverter extends DogConverter<Uint8List>
    with StructureEmitter<Uint8List> {
  @override
  Uint8List convertFromGraph(DogGraphValue value, DogEngine engine) {
    var stringValue = value.asString!;
    return base64Decode(stringValue);
  }

  @override
  DogGraphValue convertToGraph(Uint8List value, DogEngine engine) {
    var stringValue = base64Encode(value);
    return DogString(stringValue);
  }

  @override
  APISchemaObject get output => APISchemaObject.string(format: "byte");

  @override
  DogStructure get structure => DogStructure<Uint8List>.synthetic("Uint8List");
}
