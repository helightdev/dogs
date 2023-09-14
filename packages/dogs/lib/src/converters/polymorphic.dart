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

import 'package:conduit_open_api/v3.dart';
import 'package:dogs_core/dogs_core.dart';

/// Polymorphic converter for simple polymorphic datastructures.
/// Currently only supports a maximum depth of 1.
class PolymorphicConverter extends DogConverter with OperationMapMixin {
  PolymorphicConverter() : super(isAssociated: false);

  static const typePropertyKey = DogString("_type");
  static const valuePropertyKey = DogString("_value");
  static const typePropertyKeyStr = "_type";
  static const valuePropertyKeyStr = "_value";
  bool serializeNativeValues = true;

  @override
  Map<Type, OperationMode Function()> get modes =>
      {NativeSerializerMode: () => NativeSerializerMode.create(serializer: serialize, deserializer: deserialize), GraphSerializerMode: () => GraphSerializerMode.auto(this)};

  deserialize(value, DogEngine engine) {
    if (value is! Map && engine.codec.isNative(value.runtimeType) && serializeNativeValues) return value;
    if (value is Iterable) {
      return value.map((e) => deserialize(e, engine)).toList();
    }
    if (value is! Map) throw Exception("Expected an map");
    String? typeValue = value[typePropertyKeyStr];
    if (typeValue == null) {
      return value.map((key, value) => MapEntry(key as String, deserialize(value, engine)));
    }
    var structure = engine.findSerialName(typeValue)!;
    var operation = engine.modeRegistry.nativeSerialization.forType(structure.typeArgument, engine);
    if (value.length == 2 && value.containsKey(valuePropertyKeyStr)) {
      var simpleValue = value[valuePropertyKeyStr]!;
      return operation.deserialize(simpleValue, engine);
    } else {
      var clone = Map.of(value);
      clone.remove(typePropertyKeyStr);
      return operation.deserialize(clone, engine);
    }
  }

  serialize(value, DogEngine engine) {
    if (value is! Map && engine.codec.isNative(value.runtimeType) && serializeNativeValues) return value;
    var type = value.runtimeType;
    var operation = engine.modeRegistry.nativeSerialization.forTypeNullable(type, engine);
    if (operation == null) {
      if (value is Iterable) {
        return value.map((e) => serialize(e, engine)).toList();
      } else if (value is Map<String,dynamic>) {
        return value.map((key, value) => MapEntry(key, serialize(value, engine)));
      }
      throw Exception("No operation found for type $type");
    }
    var structure = engine.structures[type]!;
    var nativeValue = operation.serialize(value, engine);
    if (nativeValue is Map) {
      nativeValue[typePropertyKeyStr] = structure.serialName;
      return nativeValue;
    } else {
      return {typePropertyKeyStr: structure.serialName, valuePropertyKeyStr: nativeValue};
    }
  }

  @override
  APISchemaObject get output => APISchemaObject.object({
        "_type": APISchemaObject.string(),
      })
        ..title = "Any"
        ..description = "A polymorphic object discriminated using the _type field.";
}

class DefaultListConverter extends DogConverter<List> with OperationMapMixin<List> {
  PolymorphicConverter polymorphicConverter = PolymorphicConverter();

  final TypeCapture? cast;

  DefaultListConverter([this.cast]) : super(isAssociated: false, keepIterables: true);

  @override
  Map<Type, OperationMode<List> Function()> get modes => {
        NativeSerializerMode: () => NativeSerializerMode.create(
              serializer: (value, engine) => engine.modeRegistry.nativeSerialization.forConverter(polymorphicConverter, engine).serializeIterable(value, engine, IterableKind.list),
              deserializer: (value, engine) =>
                  engine.modeRegistry.nativeSerialization.forConverter(polymorphicConverter, engine).deserializeIterable(value, engine, IterableKind.list),
            ),
        GraphSerializerMode: () => GraphSerializerMode.auto(this)
      };

  @override
  APISchemaObject get output => APISchemaObject.array(ofSchema: polymorphicConverter.output)..title = cast == null ? "Dynamic List" : "${cast!.typeArgument.toString()} List";
}

class DefaultSetConverter extends DogConverter<Set> with OperationMapMixin<Set> {
  PolymorphicConverter polymorphicConverter = PolymorphicConverter();

  final TypeCapture? cast;

  DefaultSetConverter([this.cast]) : super(isAssociated: false, keepIterables: true);

  @override
  Map<Type, OperationMode<Set> Function()> get modes => {
        NativeSerializerMode: () => NativeSerializerMode.create(
              serializer: (value, engine) => engine.modeRegistry.nativeSerialization.forConverter(polymorphicConverter, engine).serializeIterable(value, engine, IterableKind.set),
              deserializer: (value, engine) =>
                  engine.modeRegistry.nativeSerialization.forConverter(polymorphicConverter, engine).deserializeIterable(value, engine, IterableKind.set),
            ),
        GraphSerializerMode: () => GraphSerializerMode.auto(this)
      };

  @override
  APISchemaObject get output => APISchemaObject.array(ofSchema: polymorphicConverter.output)..title = cast == null ? "Dynamic Set" : "${cast!.typeArgument.toString()} Set";
}

class DefaultIterableConverter extends DogConverter<Iterable> with OperationMapMixin<Iterable> {
  PolymorphicConverter polymorphicConverter = PolymorphicConverter();

  final TypeCapture? cast;

  DefaultIterableConverter([this.cast]) : super(isAssociated: false, keepIterables: true);

  @override
  Map<Type, OperationMode<Iterable> Function()> get modes => {
        NativeSerializerMode: () => NativeSerializerMode.create(
              serializer: (value, engine) => engine.modeRegistry.nativeSerialization.forConverter(polymorphicConverter, engine).serializeIterable(value, engine, IterableKind.list),
              deserializer: (value, engine) =>
                  engine.modeRegistry.nativeSerialization.forConverter(polymorphicConverter, engine).deserializeIterable(value, engine, IterableKind.list),
            ),
        GraphSerializerMode: () => GraphSerializerMode.auto(this)
      };

  @override
  APISchemaObject get output => APISchemaObject.array(ofSchema: polymorphicConverter.output)..title = cast == null ? "Dynamic List" : "${cast!.typeArgument.toString()} List";
}

class DefaultMapConverter extends DogConverter<Map> {
  PolymorphicConverter polymorphicConverter = PolymorphicConverter();

  DefaultMapConverter() : super(isAssociated: false);
}
