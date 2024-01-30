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

typedef EnumFromString<T> = T? Function(String);
typedef EnumToString<T> = String Function(T?);

abstract class GeneratedEnumDogConverter<T extends Enum> extends DogConverter<T>
    with OperationMapMixin<T>, EnumConverter<T> {
  EnumToString<T?> get toStr;
  EnumFromString<T?> get fromStr;
  @override
  List<String> get values;

  @override
  Map<Type, OperationMode<T> Function()> get modes => {
        NativeSerializerMode: () => NativeSerializerMode.create(
            serializer: (value, engine) => toStr(value),
            deserializer: (value, engine) => fromStr(value)!),
        GraphSerializerMode: () => GraphSerializerMode.auto(this)
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

mixin EnumConverter<T extends Enum> on DogConverter<T> {
  List<String> get values;
  T? valueFromString(String value);
  String valueToString(T? value);
}
