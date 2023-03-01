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

import 'package:aqueduct_isolates/aqueduct_isolates.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:meta/meta.dart';

/// Registry and interface for [DogConverter]s, [DogStructure]s and [Copyable]s.
class DogEngine {
  @internal
  static DogEngine? internalSingleton;

  /// Checks if a valid instance of [DogEngine] is statically available.
  static bool get hasValidInstance => internalSingleton != null;

  /// Returns the current statically linked [DogEngine].
  static DogEngine get instance => internalSingleton!;

  @internal
  List<DogConverter> converters = [];
  @internal
  Map<Type, DogConverter> associatedConverters = {};
  @internal
  Map<Type, DogStructure> structures = {};
  @internal
  Map<Type, Copyable> copyable = {};
  @internal
  Map<Type, Validatable> validatables = {};
  @internal
  AqueductPool<DogsSerializerAqueduct>? pool;

  bool _asyncEnabled = false;

  bool get asyncEnabled => _asyncEnabled;

  /// Enables/Disables the async capability. (Experimental)
  set asyncEnabled(bool asyncEnabled) {
    _asyncEnabled = asyncEnabled;
    if (asyncEnabled) {
      rebuildAsyncPool();
    } else {
      pool?.stop();
    }
  }

  /// Creates a new [DogEngine] with optional async capabilities which can
  /// be enabled via [enableAsync]. (Experimental)
  DogEngine([bool enableAsync = false]) {
    if (enableAsync) {
      asyncEnabled = true;
    }
    // Register polymorphic converters
    registerConverter(PolymorphicConverter());
    registerConverter(DefaultMapConverter());
    registerConverter(DefaultIterableConverter());
    registerConverter(DefaultListConverter());
    registerConverter(DefaultSetConverter());

    // Register common converters
    registerConverter(DateTimeConverter());
    registerConverter(DurationConverter());
    registerConverter(UriConverter());
    registerConverter(Uint8ListConverter());
  }

  /// Sets this current instance as [internalSingleton].
  void setSingleton() => internalSingleton = this;

  /// Rebuilds the isolate pool to reflect changes to the engine,
  /// if [asyncEnabled] is set to true. Otherwise throws an exception.
  void rebuildAsyncPool() {
    if (!asyncEnabled) throw Exception("Async is not currently enabled!");
    pool?.stop();
    pool = AqueductPool<DogsSerializerAqueduct>(
        1, () => DogsSerializerAqueduct(this));
    pool?.start();
  }

  /// Shuts down this [DogEngine] instance and isolates spawned by it.
  void shutdown() {
    pool?.stop();
  }

  /// Returns the [DogStructure] that is associated with the serial name [name]
  /// or null if not present.
  DogStructure? findSerialName(String name) => structures.entries
      .firstWhereOrNull((element) => element.value.serialName == name)
      ?.value;

  /// Returns the [DogStructure] that is associated with the serial name [name]
  /// or throws an exception if not present.
  DogStructure findSerialNameOrThrow(String name) {
    var structure = findSerialName(name);
    if (structure == null) {
      throw ArgumentError.value(
          name, "name", "No structure for given serial name found");
    }
    return structure;
  }

  /// Returns the [DogConverter] that is associated with [type] or
  /// null if not present.
  DogConverter? findAssociatedConverter(Type type) {
    return associatedConverters[type];
  }

  /// Returns the first registered [DogConverter] of the given [type].
  DogConverter? findConverter(Type type) =>
      converters.firstWhereOrNull((element) => element.runtimeType == type);

  /// Returns the [DogConverter] that is associated with [type] or
  /// throws an exception if not present.
  DogConverter findAssociatedConverterOrThrow(Type type) {
    var converter = findAssociatedConverter(type);
    if (converter == null) {
      throw ArgumentError.value(
          type, "type", "No converter for given type found");
    }
    return converter;
  }

  /// Registers a [converter] in this [DogEngine] instance and rebuilds the
  /// pool if [asyncEnabled] and [rebuildPool] is true. If this converter also
  /// has the [StructureEmitter] mixin, the supplied structure will be linked.
  /// If this converter also has the [Copyable] mixin, it will also be linked.
  void registerConverter(DogConverter converter, [bool rebuildPool = true]) {
    if (converter.isAssociated) {
      if (converter is StructureEmitter) {
        structures[converter.structure.typeArgument] = converter.structure;
      }
      if (converter is Copyable) {
        copyable[converter.typeArgument] = converter as Copyable;
      }
      if (converter is Validatable) {
        validatables[converter.typeArgument] = converter as Validatable;
      }
      associatedConverters[converter.typeArgument] = converter;
    }
    converters.add(converter);
    if (rebuildPool && _asyncEnabled) rebuildAsyncPool();
  }

  /// Registers multiple converters using [registerConverter].
  /// For more details see [DogEngine.registerConverter].
  void registerAllConverters(Iterable<DogConverter> converters,
      [bool rebuildPool = true]) {
    for (var x in converters) {
      registerConverter(x, false);
    }
    if (rebuildPool && _asyncEnabled) rebuildAsyncPool();
  }

  /// Creates a copy of the supplied [value] using the [Copyable] associated
  /// with [type] or the [runtimeType] of value. All given [overrides] will
  /// be applied on the resulting object.
  dynamic copyObject(dynamic value,
      [Map<String, dynamic>? overrides, Type? type]) {
    var queryType = type ?? value;
    var cloneable = copyable[queryType]!;
    return cloneable.copy(value, this, overrides);
  }

  /// Validates the supplied [value] using the [Validatable] mapped to the
  /// [value]s runtime type or [type] if specified.
  bool validateObject(dynamic value, [Type? type]) {
    var queryType = type ?? value.runtimeType;
    var validatable = validatables[queryType]!;
    return validatable.validate(value, this);
  }

  /// Converts a [value] to its [DogGraphValue] representation using the
  /// converter associated with [serialType].
  DogGraphValue convertObjectToGraph(dynamic value, Type serialType) {
    var converter = associatedConverters[serialType];
    if (converter == null) {
      throw Exception("Couldn't find an converter for $serialType");
    }
    return converter.convertToGraph(value, this);
  }

  /// Converts a [value] to its [DogGraphValue] representation using the
  /// converter associated with [serialType].
  dynamic convertIterableToGraph(dynamic value, Type type, IterableKind kind) {
    if (kind == IterableKind.none) {
      return convertObjectToGraph(value, type);
    } else {
      if (value is! Iterable) throw Exception("Expected an iterable");
      return DogList(value.map((e) => convertObjectToGraph(e, type)).toList());
    }
  }

  /// Async version of [convertObjectToGraph].
  Future<DogGraphValue> convertObjectToGraphAsync(
      dynamic value, Type serialType) {
    if (!asyncEnabled) {
      return Future.value(convertObjectToGraph(value, serialType));
    }
    return pool!.task((p0) async => await p0.convertToGraph(value, serialType));
  }

  /// Converts [DogGraphValue] supplied via [value] to its normal representation
  /// by using the converter associated with [serialType].
  dynamic convertObjectFromGraph(DogGraphValue value, Type serialType) {
    var converter = associatedConverters[serialType]!;
    return converter.convertFromGraph(value, this);
  }

  /// Converts [DogGraphValue] supplied via [value] to its normal representation
  /// by using the converter associated with [serialType].
  dynamic convertIterableFromGraph(
      DogGraphValue value, Type type, IterableKind kind) {
    if (kind == IterableKind.none) {
      return convertObjectFromGraph(value, type);
    } else {
      if (value is! DogList) throw Exception("Expected a list");
      var items = value.value.map((e) => convertObjectFromGraph(e, type));
      return adjustIterable(items, kind);
    }
  }

  /// Async version of [convertObjectFromGraph].
  Future<dynamic> convertObjectFromGraphAsync(
      DogGraphValue value, Type serialType) {
    if (!asyncEnabled) {
      return Future.value(convertObjectFromGraph(value, serialType));
    }
    return pool!
        .task((p0) async => await p0.convertFromGraph(value, serialType));
  }
}

/// Converts a [value] to the given [IterableKind]. If the value is a [Iterable]
/// implementation, it will converted to the desired [IterableKind]. Trying to
/// convert singular values to a iterable will result in an exception.
dynamic adjustIterable<T>(dynamic value, IterableKind kind) {
  if (kind == IterableKind.list) return (value as Iterable).toList();
  if (kind == IterableKind.set) return (value as Iterable).toSet();
  return value;
}
