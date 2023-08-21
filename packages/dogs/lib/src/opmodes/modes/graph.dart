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

abstract class GraphSerializerMode<T> implements OperationMode<T> {

  /// Converts [T] to a [DogGraphValue].
  DogGraphValue serialize(T value, DogEngine engine);

  /// Converts a [DogGraphValue] to [T].
  T deserialize(DogGraphValue value, DogEngine engine);

  DogGraphValue serializeIterable(
      dynamic value, DogEngine engine, IterableKind kind) {
    if (kind == IterableKind.none) {
      return serialize(value, engine);
    } else {
      if (value is! Iterable) throw Exception("Expected an iterable");
      return DogList(value.map((e) => serialize(e, engine)).toList());
    }
  }

  dynamic deserializeIterable(
      DogGraphValue value, DogEngine engine, IterableKind kind) {
    if (kind == IterableKind.none) {
      return deserialize(value, engine);
    } else {
      if (value is! DogList) throw Exception("Expected a list");
      var items = value.value.map((e) => deserialize(e, engine));
      return adjustIterable(items, kind);
    }
  }

  static GraphSerializerMode<T> create<T>({
    required DogGraphValue Function(T value, DogEngine engine) serializer,
    required T Function(DogGraphValue value, DogEngine engine) deserializer
  }) => _InlineGraphSerializer(serializer: serializer, deserializer: deserializer);

  static GraphSerializerMode<T> auto<T>(DogConverter<T> converter) => _NativeBridgeSerializer(
    converter.resolveOperationMode(NativeSerializerMode) as NativeSerializerMode<T>
  );
}

class _NativeBridgeSerializer<T> extends GraphSerializerMode<T> with TypeCaptureMixin<T> {
  NativeSerializerMode<T> nativeMode;
  
  _NativeBridgeSerializer(this.nativeMode);

  @override
  void initialise(DogEngine engine) {
    nativeMode.initialise(engine);
  }

  @override
  T deserialize(DogGraphValue value, DogEngine engine) => nativeMode.deserialize(value.coerceNative(),engine);

  @override
  DogGraphValue serialize(T value, DogEngine engine) => engine.codec.fromNative(nativeMode.serialize(value,engine));

}

class _InlineGraphSerializer<T> extends GraphSerializerMode<T> with TypeCaptureMixin<T>{

  DogGraphValue Function(T value, DogEngine engine) serializer;
  T Function(DogGraphValue value, DogEngine engine) deserializer;

  _InlineGraphSerializer({
    required this.serializer,
    required this.deserializer,
  });

  @override
  void initialise(DogEngine engine) {}

  @override
  T deserialize(DogGraphValue value, DogEngine engine) => deserializer(value,engine);

  @override
  DogGraphValue serialize(T value, DogEngine engine) => serializer(value,engine);
}