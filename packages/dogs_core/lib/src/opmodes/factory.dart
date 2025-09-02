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

/// Factory for [OperationMode]s.
abstract class OperationModeFactory<T extends OperationMode>
    with TypeCaptureMixin<T>
    implements DogLinkable {
  /// Factory for [OperationMode]s.
  const OperationModeFactory();

  /// Creates a new instance of [T] for the given [converter] and [engine].
  /// See [OperationModeCacheEntry.forConverter] for details.
  T? forConverter(DogConverter converter, DogEngine engine);

  /// A [OperationModeFactory] that returns a single [OperationMode] for a [DogConverter] of [schema].
  static OperationModeFactory<T>
      converterSingleton<TARGET extends DogConverter, T extends OperationMode>(T mode) =>
          SingletonConverterOperationModeFactory(TARGET, mode);

  /// A [OperationModeFactory] that returns a singleton [OperationMode] for a specific type.
  static OperationModeFactory<T> typeSingleton<TARGET, T extends OperationMode>(T mode) =>
      SingletonTypeOperationModeFactory(TARGET, mode);

  /// A [OperationModeFactory] that composes multiple other factories.
  static OperationModeFactory<T> compose<T extends OperationMode>(
      List<OperationModeFactory> factories) {
    final flattened = <OperationModeFactory>[];
    for (var factory in factories) {
      if (factory is ComposableOperationModeFactory<T>) {
        flattened.addAll(factory._factories);
      } else {
        flattened.add(factory);
      }
    }
    return ComposableOperationModeFactory<T>(flattened);
  }

  /// Composes this factory with another [insertion] factory, placing [insertion] in the specified [slot].
  OperationModeFactory<T> insert(
    OperationModeFactory<T> insertion,
    ModeFactoryInsertionSlot slot,
  ) =>
      compose<T>([
        if (slot == ModeFactoryInsertionSlot.first) insertion,
        this,
        if (slot == ModeFactoryInsertionSlot.last) insertion,
      ]);

  @override
  void link(DogEngine engine, bool emitChanges) {
    engine.insertModeFactory(this, emitChangeToStream: false);
  }
}

/// A [OperationModeFactory] that returns a single [OperationMode] for a [DogConverter] of [schema].
class SingletonConverterOperationModeFactory<T extends OperationMode>
    extends OperationModeFactory<T> {
  /// The type of the [DogConverter] to return the [mode] for.
  final Type targetType;

  /// The [OperationMode] to return for [targetType].
  final T mode;

  /// A [OperationModeFactory] that returns a single [OperationMode] for a [DogConverter] of [schema].
  const SingletonConverterOperationModeFactory(this.targetType, this.mode);

  @override
  T? forConverter(DogConverter converter, DogEngine engine) {
    if (converter.runtimeType == targetType) return mode;
    return null;
  }
}

/// A [OperationModeFactory] that returns a singleton [OperationMode] for a specific type.
class SingletonTypeOperationModeFactory<T extends OperationMode> extends OperationModeFactory<T> {
  /// The type of the object to return the [mode] for.
  final Type targetType;

  /// The [OperationMode] to return for [targetType].
  final T mode;

  /// A [OperationModeFactory] that returns a singleton [OperationMode] for a specific type.
  const SingletonTypeOperationModeFactory(this.targetType, this.mode);

  @override
  T? forConverter(DogConverter converter, DogEngine engine) {
    if (converter.struct?.typeArgument == targetType) return mode;
    if (converter.typeArgument != dynamic && converter.typeArgument == targetType) {
      return mode;
    }
    return null;
  }
}

/// A [OperationModeFactory] that composes multiple other factories.
class ComposableOperationModeFactory<T extends OperationMode> extends OperationModeFactory<T> {
  final List<OperationModeFactory> _factories;

  /// A [OperationModeFactory] that composes multiple other factories.
  const ComposableOperationModeFactory(this._factories);

  @override
  T? forConverter(DogConverter converter, DogEngine engine) {
    for (var factory in _factories) {
      final result = factory.forConverter(converter, engine);
      if (result != null) return result as T;
    }
    return null;
  }
}

/// Specifies where to insert a [OperationModeFactory] when composing with another factory.
enum ModeFactoryInsertionSlot {
  /// Insert the factory at the beginning of the composition.
  first,

  /// Insert the factory at the end of the composition.
  last
}
