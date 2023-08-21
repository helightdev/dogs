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
import 'package:dogs_core/src/opmodes/operation.dart';


class StringConverter extends DogConverter<String> with OperationMapMixin<String> {

  StringConverter() : super();

  @override
  Map<Type, OperationMode<String> Function()> get modes => {
    NativeSerializerMode: () => NativeSerializerMode.create(
        serializer: (value, engine) => value,
        deserializer: (value, engine) => value
    ),
    GraphSerializerMode: () => GraphSerializerMode.auto(this)
  };

  @override
  String convertFromGraph(DogGraphValue value, DogEngine engine) {
    return (value as DogString).value;
  }

  @override
  DogGraphValue convertToGraph(String value, DogEngine engine) {
    return DogString(value);
  }

  @override
  String convertFromNative(dynamic value, DogEngine engine) {
    return value;
  }

  @override
  dynamic convertToNative(String value, DogEngine engine) {
    return value;
  }
}

class IntConverter extends DogConverter<int> with OperationMapMixin<int> {

  IntConverter() : super();

  @override
  Map<Type, OperationMode<int> Function()> get modes => {
    NativeSerializerMode: () => NativeSerializerMode.create(
        serializer: (value, engine) => value,
        deserializer: (value, engine) => value
    ),
    GraphSerializerMode: () => GraphSerializerMode.auto(this)
  };

  @override
  int convertFromGraph(DogGraphValue value, DogEngine engine) {
    return (value as DogInt).value;
  }

  @override
  DogGraphValue convertToGraph(int value, DogEngine engine) {
    return DogInt(value);
  }

  @override
  int convertFromNative(dynamic value, DogEngine engine) {
    return value;
  }

  @override
  dynamic convertToNative(int value, DogEngine engine) {
    return value;
  }
}

class DoubleConverter extends DogConverter<double> with OperationMapMixin<double> {

  DoubleConverter() : super();

  @override
  Map<Type, OperationMode<double> Function()> get modes => {
    NativeSerializerMode: () => NativeSerializerMode.create(
        serializer: (value, engine) => value,
        deserializer: (value, engine) => value
    ),
    GraphSerializerMode: () => GraphSerializerMode.auto(this)
  };

  @override
  double convertFromGraph(DogGraphValue value, DogEngine engine) {
    return (value as DogDouble).value;
  }

  @override
  DogGraphValue convertToGraph(double value, DogEngine engine) {
    return DogDouble(value);
  }

  @override
  double convertFromNative(dynamic value, DogEngine engine) {
    return value;
  }

  @override
  dynamic convertToNative(double value, DogEngine engine) {
    return value;
  }
}

class BoolConverter extends DogConverter<bool> with OperationMapMixin<bool> {

  BoolConverter() : super();

  @override
  Map<Type, OperationMode<bool> Function()> get modes => {
    NativeSerializerMode: () => NativeSerializerMode.create(
        serializer: (value, engine) => value,
        deserializer: (value, engine) => value
    ),
    GraphSerializerMode: () => GraphSerializerMode.auto(this)
  };

  @override
  bool convertFromGraph(DogGraphValue value, DogEngine engine) {
    return (value as DogBool).value;
  }

  @override
  DogGraphValue convertToGraph(bool value, DogEngine engine) {
    return DogBool(value);
  }

  @override
  bool convertFromNative(dynamic value, DogEngine engine) {
    return value;
  }

  @override
  dynamic convertToNative(bool value, DogEngine engine) {
    return value;
  }
}

/// [DogConverter] for [DateTime] instances which encodes the timestamp as a
/// Iso8601 string.
class DateTimeConverter extends DogConverter<DateTime> with OperationMapMixin<DateTime> {

  DateTimeConverter() : super(
      struct: DogStructure<DateTime>.synthetic("DateTime")
  );

  @override
  Map<Type, OperationMode<DateTime> Function()> get modes => {
    NativeSerializerMode: () => NativeSerializerMode.create(
        serializer: (value, engine) => value.toIso8601String(),
        deserializer: (value, engine) => DateTime.parse(value)
    ),
    GraphSerializerMode: () => GraphSerializerMode.auto(this)
  };

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

}

/// [DogConverter] for [Duration] instances which encode the time difference
/// in milliseconds as an integer
class DurationConverter extends DogConverter<Duration> with OperationMapMixin<Duration> {

  DurationConverter() : super(
      struct: DogStructure<Duration>.synthetic("Duration")
  );

  @override
  Map<Type, OperationMode<Duration> Function()> get modes => {
    NativeSerializerMode: () => NativeSerializerMode.create(
        serializer: (value, engine) => value.inMilliseconds,
        deserializer: (value, engine) => Duration(milliseconds: value)
    ),
    GraphSerializerMode: () => GraphSerializerMode.auto(this)
  };

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
}

/// [DogConverter] for [Uri] instances which encodes the uri into a string.
class UriConverter extends DogConverter<Uri> with OperationMapMixin<Uri> {

  UriConverter() : super(
      struct: DogStructure<Uri>.synthetic("Uri")
  );
  
  @override
  Map<Type, OperationMode<Uri> Function()> get modes => {
    NativeSerializerMode: () => NativeSerializerMode.create(
        serializer: (value, engine) => value.toString(),
        deserializer: (value, engine) => Uri.parse(value)
    ),
    GraphSerializerMode: () => GraphSerializerMode.auto(this)
  };
  
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
}

/// [DogConverter] for [Uint8List] instances which encodes the binary data
/// as a base64 string using [base64Encode].
class Uint8ListConverter extends DogConverter<Uint8List> with OperationMapMixin<Uint8List> {

  Uint8ListConverter() : super(
      struct: DogStructure<Uint8List>.synthetic("Uint8List")
  );

  @override
  Map<Type, OperationMode<Uint8List> Function()> get modes => {
    NativeSerializerMode: () => NativeSerializerMode.create(
        serializer: (value, engine) => base64Encode(value),
        deserializer: (value, engine) => base64Decode(value)
    ),
    GraphSerializerMode: () => GraphSerializerMode.auto(this)
  };
  
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
}
