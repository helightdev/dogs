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

/// [DogConverter] that supports polymorphic serialization and deserialization.
/// Supports a maximum of one level of polymorphism because of the lack of
/// runtime type introspection available in Dart.
class PolymorphicConverter extends DogConverter with OperationMapMixin {
  /// [DogConverter] that supports polymorphic serialization and deserialization.
  PolymorphicConverter() : super(isAssociated: false);

  /// Whether native values should require type annotations for serialization.
  /// By default, this is true, meaning that primitive values will be serialized
  /// as is.
  bool serializeNativeValues = true;

  @override
  Map<Type, OperationMode Function()> get modes => {
        NativeSerializerMode: () => NativeSerializerMode.create(
            serializer: serialize, deserializer: deserialize),
      };

  /// Performs a native deserialization of [value].
  dynamic deserialize(value, DogEngine engine) {
    if (value == null) return null;
    final codec = engine.codec;
    // Keep native values as is if they serializeNativeValues is true
    if (value is! Map &&
        codec.isNative(value.runtimeType) &&
        serializeNativeValues) {
      return value;
    }

    /// Recursively try to deserialize the value
    if (value is Iterable) {
      return value.map((e) => deserialize(e, engine)).toList();
    }
    if (value is! Map) {
      throw DogSerializerException(
        message: "Expected an map but got $value",
        converter: this,
      );
    }

    final String? typeValue = value[codec.typeDiscriminator];

    // If no type value is specified, try to decode the value as a map
    if (typeValue == null) {
      return value.map(
          (key, value) => MapEntry(key as String, deserialize(value, engine)));
    }

    // Try to decode the value using the type specified by the type value
    final structure = engine.findStructureBySerialName(typeValue)!;
    final operation = engine.modeRegistry.nativeSerialization
        .forType(structure.typeArgument, engine);

    // Decide if the value is encoded using a value discriminator or not and
    // deserialize accordingly.
    if (value.length == 2 && value.containsKey(codec.valueDiscriminator)) {
      final simpleValue = value[codec.valueDiscriminator]!;
      return operation.deserialize(simpleValue, engine);
    } else {
      final clone = Map<String,dynamic>.from(value);
      clone.remove(codec.typeDiscriminator);
      return operation.deserialize(clone, engine);
    }
  }

  /// Performs a native serialization of [value].
  dynamic serialize(value, DogEngine engine) {
    if (value == null) return null;
    final codec = engine.codec;

    // Keep native values as is if they serializeNativeValues is true
    if (value is! Map &&
        codec.isNative(value.runtimeType) &&
        serializeNativeValues) {
      return value;
    }
    final type = value.runtimeType;
    final operation =
        engine.modeRegistry.nativeSerialization.forTypeNullable(type, engine);
    // Try to handle serialization of non serializable types
    if (operation == null) {
      if (value is Iterable) {
        // Try to serialize the value of a runtime iterable
        return value.map((e) => serialize(e, engine)).toList();
      } else if (value is Map<String, dynamic>) {
        // Try to serialize the value of a runtime map
        return value
            .map((key, value) => MapEntry(key, serialize(value, engine)));
      }
      throw DogSerializerException(
          message: "No operation mode found for type '$type'. "
              "Runtime serialization of map and iterables also failed.",
          converter: this);
    }
    final structure = engine.findStructureByType(type)!;
    final nativeValue = operation.serialize(value, engine);

    // If the value is a map, add the type discriminator field, otherwise wrap
    // the resulting data in a map using the value discriminator field.
    if (nativeValue is Map) {
      nativeValue[codec.typeDiscriminator] = structure.serialName;
      return nativeValue;
    } else {
      return {
        codec.typeDiscriminator: structure.serialName,
        codec.valueDiscriminator: nativeValue
      };
    }
  }
}
