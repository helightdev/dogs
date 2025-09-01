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

// ignore: public_member_api_docs
typedef StructureFieldNativeSerializerFunc = void Function(
    dynamic v, Map<String, dynamic> map, DogEngine engine);

// ignore: public_member_api_docs
typedef StructureFieldNativeDeserializerFunc = void Function(
    dynamic v, List<dynamic> args, DogEngine engine);

/// The structure context used by [StructureNativeSerialization] passes.
class NativeStructureContext {
  /// The engine this context was created in.
  final DogEngine engine;

  /// The structure this context is for.
  final DogStructure structure;

  NativeStructureContext._(this.engine, this.structure);
}

/// The field context used by [StructureNativeSerialization] passes.
class NativeStructureFieldContext {
  /// The index of the field in the structure.
  final int index;

  /// The field this context is for.
  final DogStructureField field;

  /// The converter for this field.
  final DogConverter? converter;

  /// The native serializer mode for this field.
  final NativeSerializerMode? nativeSerializerMode;

  /// Whether to keep iterables as is.
  final bool keepIterables;

  /// The key/name of the field.
  String get key => field.name;

  NativeStructureFieldContext._(
    this.index,
    this.field, {
    this.converter,
    this.nativeSerializerMode,
    this.keepIterables = false,
  });

  /// Encodes [value] like [StructureFieldNativeSerializerFunc] would for this field.
  dynamic encodeValue(dynamic value, DogEngine engine) {
    if (converter == null) {
      if (value is Iterable) {
        if (value is List) {
          return value;
        } else {
          return value.toList();
        }
      } else {
        return value;
      }
    }

    if (value == null) {
      if (nativeSerializerMode!.canSerializeNull) {
        return nativeSerializerMode!.serialize(null, engine);
      } else {
        return null;
      }
    }

    return nativeSerializerMode!.serialize(value, engine);
  }

  /// Decodes [value] like [StructureFieldNativeDeserializerFunc] would for this field.
  /// NOTE: Not yet implemented.
  dynamic decodeValue(dynamic value, DogEngine engine) {
    throw UnimplementedError("Not yet implemented");
  }
}

/// A [NativeSerializerMode] that supplies native serialization for [DogStructure]s.
class StructureNativeSerialization<T> extends NativeSerializerMode<T>
    with TypeCaptureMixin<T> {
  /// The structure this serializer is for.
  final DogStructure<T> structure;

  /// Creates a new [StructureNativeSerialization] for the supplied [structure].
  StructureNativeSerialization(this.structure);

  late final DogStructureProxy _proxy = structure.proxy;
  late List<StructureFieldNativeSerializerFunc> _serializers;
  late List<StructureFieldNativeDeserializerFunc> _deserializers;
  late List<SerializationHook> _hooks;
  bool _hasHooks = false;

  @override
  void initialise(DogEngine engine) {
    // Validate the structure for serializability
    final structureAnnotation = structure.firstAnnotationOf<Structure>();
    if (structureAnnotation != null) {
      if (!structureAnnotation.serializable) {
        throw DogSerializerException(
          message: "Structure is not serializable",
          structure: structure,
        );
      }
    }

    _hooks = structure.annotationsOf<SerializationHook>().toList();
    _hasHooks = _hooks.isNotEmpty;
    final harbinger = StructureHarbinger.create(structure, engine);
    final snContext = NativeStructureContext._(engine, structure);
    final List<
        ({
          StructureFieldNativeSerializerFunc serialize,
          StructureFieldNativeDeserializerFunc deserialize
        })> functions = harbinger.fieldConverters.mapIndexed((i, e) {
      final field = e.field;
      final fieldName = field.name;
      final isOptional = field.optional;
      final proxy = structure.proxy;
      final fieldType = field.type.qualifiedOrBase;
      final fieldSerializerHooks =
          field.annotationsOf<FieldSerializationHook>().toList();
      final NativeStructureFieldContext snFieldContext;

      // Partially evaluate the serialization and deserialization and create
      // "baked" and cached closures for every field.
      if (e.converter == null) {
        snFieldContext = NativeStructureFieldContext._(i, field);
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
              for (var hook in fieldSerializerHooks) {
                hook.postFieldSerialization(
                    snContext, snFieldContext, map, engine);
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
                stacktrace,
              );
            }
          },
          deserialize: (dynamic v, List args, DogEngine engine) {
            try {
              for (var hook in fieldSerializerHooks) {
                hook.beforeFieldDeserialization(
                  snContext,
                  snFieldContext,
                  v,
                  engine,
                );
              }
              final mapValue = v[fieldName];
              if (mapValue == null) {
                if (isOptional) {
                  args.add(null);
                } else {
                  args.add(engine.codec.primitiveCoercion
                      .coerce(fieldType, null, fieldName));
                }
              } else {
                if (fieldType.isAssignable(mapValue)) {
                  args.add(mapValue);
                } else {
                  if (fieldType.isAssignable(mapValue)) return fieldType;
                  return engine.codec.primitiveCoercion
                      .coerce(fieldType, fieldType, fieldName);
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
                stacktrace,
              );
            }
          },
        );
      } else {
        final converter = e.converter!;
        final operation = engine.modeRegistry.nativeSerialization
            .forConverter(converter, engine);
        final isKeepIterables = converter.keepIterables;
        snFieldContext = NativeStructureFieldContext._(
          i,
          field,
          converter: converter,
          nativeSerializerMode: operation,
          keepIterables: isKeepIterables,
        );
        return (
          serialize: (dynamic v, Map<String, dynamic> map, DogEngine engine) {
            try {
              final fieldValue = proxy.getField(v, i);
              if (fieldValue == null) {
                map[fieldName] = null;
              } else {
                map[fieldName] = operation.serialize(fieldValue, engine);
              }
              for (var hook in fieldSerializerHooks) {
                hook.postFieldSerialization(
                    snContext, snFieldContext, map, engine);
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
              for (var hook in fieldSerializerHooks) {
                hook.beforeFieldDeserialization(
                  snContext,
                  snFieldContext,
                  v,
                  engine,
                );
              }
              final mapValue = v[fieldName];
              if (mapValue == null) {
                if (isOptional) {
                  args.add(null);
                } else if (operation.canSerializeNull) {
                  args.add(operation.deserialize(null, engine));
                } else {
                  throw DogException(
                      "Expected a value at ${field.name} but got $mapValue");
                }
              } else {
                args.add(operation.deserialize(mapValue, engine));
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
                stacktrace,
              );
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
