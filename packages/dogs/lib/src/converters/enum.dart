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

import "package:conduit_open_api/v3.dart";
import "package:dogs_core/dogs_core.dart";

/// Decodes a enum value from a string.
typedef EnumFromString<T> = T? Function(String);

/// Encodes a enum value to a string.
typedef EnumToString<T> = String Function(T?);

/// A [DogConverter] that allows for the conversion of enum values to and from strings.
abstract class GeneratedEnumDogConverter<T extends Enum> extends DogConverter<T>
    with OperationMapMixin<T>, EnumConverter<T> {
  /// Function that converts a enum value to a string.
  EnumToString<T?> get toStr;

  /// Function that converts a string to a enum value.
  EnumFromString<T?> get fromStr;

  @override
  List<String> get values;

  @override
  Map<Type, OperationMode<T> Function()> get modes => {
        NativeSerializerMode: () => NativeSerializerMode.create(
            serializer: (value, engine) => toStr(value),
            deserializer: (value, engine) => fromStr(value)!),
      };

  @override
  APISchemaObject get output {
    return APISchemaObject.string()
      ..title = T.toString()
      ..enumerated = values;
  }

  @override
  T? valueFromString(String value) => fromStr(value)!;

  @override
  String valueToString(T? value) => toStr(value);
}

/// Mixin that exposes a public api surface for enum converters.
/// Primarily intended to be used by opmode factories for converter tree
/// introspection.
mixin EnumConverter<T extends Enum> on DogConverter<T> {
  /// All possible enum values.
  List<String> get values;

  /// Converts a string to a enum value.
  T? valueFromString(String value);

  /// Converts a enum value to a string.
  String valueToString(T? value);
}
