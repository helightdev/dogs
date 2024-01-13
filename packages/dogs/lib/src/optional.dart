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

import 'package:dogs_core/dogs_core.dart';

/// Port of Java's Optional (https://docs.oracle.com/javase/8/docs/api/java/util/Optional.html)
class Optional<T> {
  final T? value;

  const Optional([this.value]);
  const Optional.empty() : this(null);
  const Optional.of(T value) : this(value);
  const Optional.nullable(T? value) : this(value);

  bool get isPresent => value != null;
  T get() => value!;

  void ifPresent(Function(T) consumer) {
    var current = value;
    if (current != null) consumer(current);
  }

  Optional<R> map<R>(R? Function(T) mapper) {
    var current = value;
    if (current == null) return Optional<R>.empty();
    return Optional(mapper(current));
  }

  T orElse(T other) => value ?? other;

  T? orElseGet(T Function() supplier) {
    var current = value;
    if (current == null) {
      return supplier();
    }
    return current;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Optional &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class OptionalTreeBaseConverter extends DogConverter with OperationMapMixin {
  DogConverter converter;
  TypeCapture capture;
  OptionalTreeBaseConverter(this.converter, this.capture);

  @override
  Map<Type, OperationMode Function()> get modes => {
        NativeSerializerMode: () =>
            OptionalTreeBaseNativeOperation(converter, capture),
        GraphSerializerMode: () => GraphSerializerMode.auto(this)
      };
}

class OptionalTreeBaseNativeOperation extends NativeSerializerMode<Optional>
    with TypeCaptureMixin<Optional> {
  DogConverter converter;
  TypeCapture capture;
  OptionalTreeBaseNativeOperation(this.converter, this.capture);

  late NativeSerializerMode mode;

  @override
  void initialise(DogEngine engine) {
    mode =
        engine.modeRegistry.nativeSerialization.forConverter(converter, engine);
  }

  Optional createOptional<T>(dynamic value) => Optional<T>(value);

  @override
  Optional deserialize(value, DogEngine engine) {
    if (value == null) {
      return capture.consumeTypeArg(createOptional, null);
    } else {
      return capture.consumeTypeArg(
          createOptional, mode.deserialize(value, engine));
    }
  }

  @override
  serialize(Optional value, DogEngine engine) {
    var v = value.value;
    if (v != null) {
      return mode.serialize(v, engine);
    } else {
      return null;
    }
  }
}

class OptionalTreeBaseConverterFactory extends TreeBaseConverterFactory {
  @override
  DogConverter getConverter(
      TypeTree tree, DogEngine engine, bool allowPolymorphic) {
    var argumentConverter = TreeBaseConverterFactory.argumentConverters(
            tree, engine, allowPolymorphic)
        .first;
    return OptionalTreeBaseConverter(
        argumentConverter, tree.arguments.first.qualified);
  }
}
