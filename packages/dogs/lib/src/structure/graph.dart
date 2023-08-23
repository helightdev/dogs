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

import 'package:collection/collection.dart';
import 'package:dogs_core/dogs_core.dart';

class StructureGraphSerialization<T> extends GraphSerializerMode<T> with TypeCaptureMixin<T> {
  DogStructure<T> structure;

  StructureGraphSerialization(this.structure);

  late DogStructureProxy proxy = structure.proxy;
  late List<void Function(dynamic v, Map<DogGraphValue,DogGraphValue> map, DogEngine engine)> serializers;
  late List<void Function (Map<DogGraphValue,DogGraphValue> v, List<dynamic> args, DogEngine engine)> deserializers;
  
  @override
  void initialise(DogEngine engine) {
    final harbinger = StructureHarbinger.create(structure, engine);
    final List<({
      void Function(dynamic v, Map<DogGraphValue,DogGraphValue> map, DogEngine engine) serialize,
      void Function (Map<DogGraphValue,DogGraphValue> v, List<dynamic> args, DogEngine engine) deserialize
    })> functions = harbinger.fieldConverters.mapIndexed((i,e) {
      final field = e.field;
      final fieldName = DogString(field.name);
      final isOptional = field.optional;
      final proxy = structure.proxy;
      final iterableKind = field.iterableKind;
      if (e.converter == null) {
        return (
          serialize: (dynamic v, Map<DogGraphValue,DogGraphValue> map, DogEngine engine) {
            final fieldValue = proxy.getField(v, i);
            map[fieldName] = engine.codec.fromNative(fieldValue);
          },
          deserialize: (Map<DogGraphValue,DogGraphValue> v, List<dynamic> args, DogEngine engine) {
            final mapValue = v[fieldName]??DogNull();
            if (mapValue.isNull) {
              if (isOptional) {
                args.add(null);
              } else if (iterableKind != IterableKind.none) {
                args.add(adjustIterable([], field.iterableKind));
              } else {
                throw Exception("Expected a value of serial type ${field.serial.typeArgument} at ${field.name} but got $mapValue");
              }
            } else {
              args.add(adjustIterable(mapValue.coerceNative(), iterableKind));
            }
          },
        );
      } else {
        final converter = e.converter!;
        final operation = engine.modeRegistry.graphSerialization.forConverter(converter, engine);
        final isKeepIterables = converter.keepIterables;
        return (
            serialize: (dynamic v, Map<DogGraphValue,DogGraphValue> map, DogEngine engine) {
              final fieldValue = proxy.getField(v, i);
              if (fieldValue == null) {
                map[fieldName] = DogNull();
              } else if (isKeepIterables) {
                map[fieldName] = operation.serialize(fieldValue, engine);
              } else {
                map[fieldName] = operation.serializeIterable(fieldValue, engine, iterableKind);
              }
            },
            deserialize: (Map<DogGraphValue,DogGraphValue> v, List<dynamic> args, DogEngine engine) {
              final mapValue = v[fieldName]??DogNull();
              if (mapValue.isNull) {
                if (isOptional) {
                  args.add(null);
                } else if (iterableKind != IterableKind.none) {
                  args.add(adjustIterable([], iterableKind));
                } else {
                  throw Exception("Expected a value of serial type ${field.serial.typeArgument} at ${field.name} but got $mapValue");
                }
              } else {
                if (isKeepIterables) {
                  args.add(operation.deserialize(mapValue, engine));
                } else {
                  args.add(operation.deserializeIterable(mapValue, engine, iterableKind));
                }
              }
            });
      }
    }).toList();
    deserializers = functions.map((e) => e.deserialize).toList();
    serializers = functions.map((e) => e.serialize).toList();
  }

  @override
  T deserialize(value, DogEngine engine) {
    if (value is! DogMap) throw Exception("Expected a map");
    var internalMap = value.asMap!.value;
    var args = <dynamic>[];
    for (var deserializer in deserializers) {
      deserializer(internalMap, args, engine);
    }
    return proxy.instantiate(args);
  }

  @override
  serialize(T value, DogEngine engine) {
    var data = <DogGraphValue,DogGraphValue>{};
    for (var serializer in serializers) {
      serializer(value, data, engine);
    }
    return DogMap(data);
  }
}
