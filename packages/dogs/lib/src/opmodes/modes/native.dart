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

abstract class NativeSerializerMode<T> implements OperationMode<T> {
  /// Aggressively converts [T] to a "primitive" dart type.
  dynamic serialize(T value, DogEngine engine);

  /// Aggressively converts a "primitive" dart type to [T].
  T deserialize(dynamic value, DogEngine engine);

  dynamic serializeIterable(
      dynamic value, DogEngine engine, IterableKind kind) {
    if (kind == IterableKind.none) {
      return serialize(value, engine);
    } else {
      if (value is! Iterable) throw Exception("value is not iterable");
      return value.map((e) => serialize(e, engine)).toList();
    }
  }

  dynamic deserializeIterable(
      dynamic value, DogEngine engine, IterableKind kind) {
    if (kind == IterableKind.none) {
      return deserialize(value, engine);
    } else {
      if (value is! Iterable) throw Exception("value is not iterable");
      return adjustIterable(value.map((e) => deserialize(e, engine)), kind);
    }
  }

  static NativeSerializerMode<T> create<T>(
          {required dynamic Function(T value, DogEngine engine) serializer,
          required T Function(dynamic value, DogEngine engine) deserializer}) =>
      _InlineNativeSerializer(
          serializer: serializer, deserializer: deserializer);
}

class _InlineNativeSerializer<T> extends NativeSerializerMode<T>
    with TypeCaptureMixin<T> {
  dynamic Function(T value, DogEngine engine) serializer;
  T Function(dynamic value, DogEngine engine) deserializer;

  _InlineNativeSerializer({
    required this.serializer,
    required this.deserializer,
  });

  @override
  void initialise(DogEngine engine) {}

  @override
  T deserialize(value, DogEngine engine) => deserializer(value, engine);

  @override
  serialize(T value, DogEngine engine) => serializer(value, engine);
}
