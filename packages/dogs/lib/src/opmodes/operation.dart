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

import "dart:collection";

import "package:dogs_core/dogs_core.dart";

export "modes/native.dart";
export "modes/validation.dart";

/// An operation mode exposed by a [DogConverter].
///
/// Operation modes are used to provide a specific functionality to a [DogConverter],
/// for example, a [NativeSerializerMode] provides a way to serialize and deserialize
/// a value to a dart map while a [ValidationMode] provides a way to validate a value.
abstract interface class OperationMode<T> implements TypeCapture<T> {
  /// Initialises the operation mode with the given [engine].
  /// This allows for the operation mode to possibly precache some data that would
  /// need to be lookup on every invocation otherwise.
  void initialise(DogEngine engine) {}
}

/// Provides a more convenient way to resolve [OperationMode]s for [DogConverter]s.
mixin OperationMapMixin<T> on DogConverter<T> {
  /// Returns a map of [Type]s to [OperationMode] factories.
  Map<Type, OperationMode<T> Function()> get modes;

  @override
  OperationMode<T>? resolveOperationMode(DogEngine engine, Type opmodeType) =>
      modes[opmodeType]?.call();
}

/// The registry for [OperationMode]s.
/// Serves as the central point for resolving [OperationMode]s for [DogConverter]s
/// and [Type]s. Also functions as a cache for the resolved [OperationMode]s.
class OperationModeRegistry {
  final Map<Type, OperationModeCacheEntry> _cache = HashMap();

  /// Fast access to the [entry] for [NativeSerializerMode].
  late OperationModeCacheEntry<NativeSerializerMode> nativeSerialization;

  /// Fast access to the [entry] for [ValidationMode].
  late OperationModeCacheEntry<ValidationMode> validation;

  /// Creates a new [OperationModeRegistry] and initializes the fast access fields.
  /// The cache is empty at this point and will be lazily populated.
  OperationModeRegistry() {
    nativeSerialization = entry<NativeSerializerMode>();
    validation = entry<ValidationMode>();
  }

  /// Returns the [OperationModeCacheEntry] for the given [T].
  OperationModeCacheEntry<T> entry<T extends OperationMode>() {
    final OperationModeCacheEntry? cachedValue = _cache[T];
    if (cachedValue == null) {
      final entry = OperationModeCacheEntry<T>(T);
      _cache[T] = entry;
      return entry;
    } else {
      return cachedValue as OperationModeCacheEntry<T>;
    }
  }

  /// Returns the [OperationMode] for the given [type] and [engine].
  T getType<T extends OperationMode>(Type type, DogEngine engine) =>
      entry<T>().forType(type, engine);

  /// Returns the [OperationMode] for the given [converter] and [engine].
  T getConverter<T extends OperationMode>(
          DogConverter converter, DogEngine engine) =>
      entry<T>().forConverter(converter, engine);
}

/// A cache entry for [OperationMode]s.
/// Holds all resolved [OperationMode]s for the specified [OperationModeCacheEntry.modeType].
class OperationModeCacheEntry<T extends OperationMode> {
  /// The [Type] of the [OperationMode]s that are cached in this entry.
  final Type modeType;

  /// Creates a new [OperationModeCacheEntry] for the given [modeType].
  OperationModeCacheEntry(this.modeType);

  /// The cached [OperationMode]s for [DogConverter]s.
  final Map<DogConverter, OperationMode> converterMapping = {};

  /// The cached [OperationMode]s for [Type]s.
  final Map<Type, OperationMode> typeMapping = {};

  /// Returns the [OperationMode] for the given [converter] and [engine].
  T forConverter(DogConverter converter, DogEngine engine) {
    final cached = converterMapping[converter];
    if (cached != null) return cached as T;
    var resolved = converter.resolveOperationMode(engine, modeType);
    resolved ??= engine.findModeFactory(T)?.forConverter(converter, engine);

    if (resolved == null) {
      throw DogException(
          "DogConverter $converter doesn't support opmode $modeType");
    }
    converterMapping[converter] = resolved;
    resolved.initialise(engine);
    return resolved as T;
  }

  /// Returns the [OperationMode] for the given [converter] and [engine] but allows null.
  T? forConverterNullable(DogConverter converter, DogEngine engine) {
    final cached = converterMapping[converter];
    if (cached != null) return cached as T;
    var resolved = converter.resolveOperationMode(engine, modeType);
    resolved ??= engine.findModeFactory(T)?.forConverter(converter, engine);

    if (resolved == null) return null;
    converterMapping[converter] = resolved;
    resolved.initialise(engine);
    return resolved as T;
  }

  /// Returns the [OperationMode] for the given [type] and [engine].
  T forType(Type type, DogEngine engine) {
    final cached = typeMapping[type];
    if (cached != null) return cached as T;
    final converter = engine.findAssociatedConverter(type);
    if (converter == null) throw Exception("No converter found for type $type");
    final mode = forConverter(converter, engine);
    typeMapping[type] = mode;
    return mode;
  }

  /// Returns the [OperationMode] for the given [type] and [engine] but allows null.
  T? forTypeNullable(Type type, DogEngine engine) {
    final cached = typeMapping[type];
    if (cached != null) return cached as T;
    final converter = engine.findAssociatedConverter(type);
    if (converter == null) return null;
    final mode = forConverter(converter, engine);
    typeMapping[type] = mode;
    return mode;
  }
}
