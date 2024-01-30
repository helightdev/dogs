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
    with TypeCaptureMixin<T> {
  const OperationModeFactory();

  /// Creates a new instance of [T] for the given [converter] and [engine].
  /// See [OperationModeCacheEntry.forConverter] for details.
  T? forConverter(DogConverter converter, DogEngine engine);

  /// A [OperationModeFactory] that returns a single [OperationMode] for a [DogConverter] of [type].
  static OperationModeFactory<T>
      converterSingleton<TARGET extends DogConverter, T extends OperationMode>(
              T mode) =>
          SingletonConverterOperationModeFactory(TARGET, mode);

  /// A [OperationModeFactory] that returns a singleton [OperationMode] for a specific type.
  static OperationModeFactory<T> typeSingleton<TARGET, T extends OperationMode>(
          T mode) =>
      SingletonTypeOperationModeFactory(TARGET, mode);

  /// A [OperationModeFactory] that composes multiple other factories.
  static OperationModeFactory<T> compose<T extends OperationMode>(
          List<OperationModeFactory> factories) =>
      ComposableOperationModeFactory<T>(factories);
}

/// A [OperationModeFactory] that returns a single [OperationMode] for a [DogConverter] of [type].
class SingletonConverterOperationModeFactory<T extends OperationMode>
    extends OperationModeFactory<T> {
  final Type targetType;
  final T mode;

  const SingletonConverterOperationModeFactory(this.targetType, this.mode);

  @override
  T? forConverter(DogConverter converter, DogEngine engine) {
    if (converter.runtimeType == targetType) return mode;
    return null;
  }
}

/// A [OperationModeFactory] that returns a singleton [OperationMode] for a specific type.
class SingletonTypeOperationModeFactory<T extends OperationMode>
    extends OperationModeFactory<T> {
  final Type targetType;
  final T mode;

  const SingletonTypeOperationModeFactory(this.targetType, this.mode);

  @override
  T? forConverter(DogConverter converter, DogEngine engine) {
    if (converter.struct?.typeArgument == targetType) return mode;
    return null;
  }
}

/// A [OperationModeFactory] that composes multiple other factories.
class ComposableOperationModeFactory<T extends OperationMode>
    extends OperationModeFactory<T> {
  final List<OperationModeFactory> _factories;

  const ComposableOperationModeFactory(this._factories);

  @override
  T? forConverter(DogConverter converter, DogEngine engine) {
    for (var factory in _factories) {
      var result = factory.forConverter(converter, engine);
      if (result != null) return result as T;
    }
    return null;
  }
}
