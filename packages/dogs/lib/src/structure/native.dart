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

typedef _FieldSerializer = void Function(
    dynamic v, Map<String, dynamic> map, DogEngine engine);
typedef _FieldDeserializer = void Function(
    dynamic v, List<dynamic> args, DogEngine engine);

/// A [NativeSerializerMode] that supplies native serialization for [DogStructure]s.
class StructureNativeSerialization<T> extends NativeSerializerMode<T>
    with TypeCaptureMixin<T> {
  
  /// The structure this serializer is for.
  final DogStructure<T> structure;

  /// Creates a new [StructureNativeSerialization] for the supplied [structure].
  StructureNativeSerialization(this.structure);

  late final DogStructureProxy _proxy = structure.proxy;
  late List<_FieldSerializer> _serializers;
  late List<_FieldDeserializer> _deserializers;
  late List<SerializationHook> _hooks;
  bool _hasHooks = false;

  @override
  void initialise(DogEngine engine) {
    _hooks = structure.annotationsOf<SerializationHook>().toList();
    _hasHooks = _hooks.isNotEmpty;
    final harbinger = StructureHarbinger.create(structure, engine);
    final List<({_FieldSerializer serialize, _FieldDeserializer deserialize})>
        functions = harbinger.fieldConverters.mapIndexed((i, e) {
      final field = e.field;
      final fieldName = field.name;
      final isOptional = field.optional;
      final proxy = structure.proxy;
      final iterableKind = field.iterableKind;
      final fieldType = field.type;
      final serialType = field.serial;
      if (e.converter == null) {
        return (
          serialize: (dynamic v, Map<String, dynamic> map, DogEngine engine) {
            try {
              final fieldValue = proxy.getField(v, i);
              if (fieldValue is Iterable) {
                if (fieldValue is List) {
                  map[fieldName] = fieldValue;
                } else {
                  map[fieldName] = fieldValue.toList();
                }
              } else {
                map[fieldName] = fieldValue;
              }
            } on DogFieldSerializerException {
              rethrow;
            } catch (e, stacktrace) {
              throw DogFieldSerializerException(
                  "Error while serializing native field in native serialization",
                  null,
                  structure,
                  field,
                  e,
                  stacktrace);
            }
          },
          deserialize: (dynamic v, List args, DogEngine engine) {
            try {
              final mapValue = v[fieldName];
              if (mapValue == null) {
                if (isOptional) {
                  args.add(null);
                } else if (iterableKind != IterableKind.none) {
                  args.add(adjustWithCoercion([], iterableKind, serialType,
                      engine.codec.primitiveCoercion, fieldName));
                } else {
                  args.add(engine.codec.primitiveCoercion
                      .coerce(serialType, null, fieldName));
                }
              } else {
                if (fieldType.isAssignable(mapValue)) {
                  args.add(mapValue);
                } else {
                  args.add(adjustWithCoercion(mapValue, iterableKind, serialType,
                      engine.codec.primitiveCoercion, fieldName));
                }
              }
            } on DogFieldSerializerException {
              rethrow;
            } catch (e, stacktrace) {
              throw DogFieldSerializerException(
                  "Error while deserializing native field in native serialization",
                  null,
                  structure,
                  field,
                  e,
                  stacktrace);
            }
          },
        );
      } else {
        final converter = e.converter!;
        final operation = engine.modeRegistry.nativeSerialization
            .forConverter(converter, engine);
        final isKeepIterables = converter.keepIterables;
        return (
          serialize: (dynamic v, Map<String, dynamic> map, DogEngine engine) {
            try {
              final fieldValue = proxy.getField(v, i);
              if (fieldValue == null) {
                map[fieldName] = null;
              } else if (isKeepIterables) {
                map[fieldName] = operation.serialize(fieldValue, engine);
              } else {
                map[fieldName] = operation.serializeIterable(
                    fieldValue, engine, iterableKind);
              }
            } on DogFieldSerializerException {
              rethrow;
            } catch (e, stacktrace) {
              throw DogFieldSerializerException(
                  "Error while serialization field in native serialization",
                  converter,
                  structure,
                  field,
                  e,
                  stacktrace);
            }
          },
          deserialize: (dynamic v, List args, DogEngine engine) {
            try {
              final mapValue = v[fieldName];
              if (mapValue == null) {
                if (isOptional) {
                  args.add(null);
                } else if (iterableKind != IterableKind.none) {
                  args.add(adjustIterable([], iterableKind));
                } else {
                  throw DogException("Expected a value of serial type ${field.serial.typeArgument} at ${field.name} but got $mapValue");
                }
              } else {
                if (isKeepIterables) {
                  args.add(operation.deserialize(mapValue, engine));
                } else {
                  args.add(operation.deserializeIterable(
                      mapValue, engine, iterableKind));
                }
              }
            } on DogFieldSerializerException {
              rethrow;
            } catch (e, stacktrace) {
              throw DogFieldSerializerException(
                  "Error while deserializing field in native serialization",
                  converter,
                  structure,
                  field,
                  e,
                  stacktrace);
            }
          }
        );
      }
    }).toList();
    _deserializers = functions.map((e) => e.deserialize).toList();
    _serializers = functions.map((e) => e.serialize).toList();
  }

  @override
  T deserialize(value, DogEngine engine) {
    if (value is! Map) {
      throw DogSerializerException(
        message: "Expected a map but got ${value.runtimeType}",
        structure: structure,
      );
    }
    final args = <dynamic>[];
    if (_hasHooks) {
      final clonedMap = Map<String, dynamic>.from(value);
      for (var hook in _hooks) {
        hook.beforeDeserialization(clonedMap, structure, engine);
      }
      value = clonedMap;
    }
    for (var deserializer in _deserializers) {
      deserializer(value, args, engine);
    }
    try {
      return _proxy.instantiate(args);
    } catch (e, stacktrace) {
      throw DogSerializerException(
        message: "Failed to instantiate ${structure.typeArgument}",
        structure: structure,
        cause: e,
        innerStackTrace: stacktrace,
      );
    }
  }

  @override
  serialize(T value, DogEngine engine) {
    final data = <String, dynamic>{};
    for (var serializer in _serializers) {
      serializer(value, data, engine);
    }
    if (_hasHooks) {
      for (var hook in _hooks) {
        hook.postSerialization(value, data, structure, engine);
      }
    }
    return data;
  }
}
