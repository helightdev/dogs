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

/// Operation mode that converters a value to a native representation as
/// defined by the [DogNativeCodec] of the current [DogEngine]. For most
/// implementations, this means converting the value to a "primitive" dart type,
/// that could also be encoded using [jsonEncode].
///
/// Consider using [SimpleDogConverter] since this base class already implements
/// this operation mode for you.
abstract class NativeSerializerMode<T> implements OperationMode<T> {
  /// Aggressively converts [T] to a "primitive" dart type.
  dynamic serialize(T value, DogEngine engine);

  /// Aggressively converts a "primitive" dart type to [T].
  T deserialize(dynamic value, DogEngine engine);

  /// Returns true if the serializer can handle null values and create [T]
  /// instances from them.
  bool get canSerializeNull => false;

  /// Creates a new [NativeSerializerMode] instance using the provided
  /// [serializer] and [deserializer] functions without needing to create a
  /// new class.
  static NativeSerializerMode<T> create<T>(
          {required dynamic Function(T value, DogEngine engine) serializer,
          required T Function(dynamic value, DogEngine engine) deserializer,
          bool canSerializeNull = false}) =>
      _InlineNativeSerializer(
          serializer: serializer,
          deserializer: deserializer,
          canSerializeNull: canSerializeNull);
}

class _InlineNativeSerializer<T> extends NativeSerializerMode<T>
    with TypeCaptureMixin<T> {
  dynamic Function(T value, DogEngine engine) serializer;
  T Function(dynamic value, DogEngine engine) deserializer;
  @override
  final bool canSerializeNull;

  _InlineNativeSerializer({
    required this.serializer,
    required this.deserializer,
    required this.canSerializeNull,
  });

  @override
  void initialise(DogEngine engine) {}

  @override
  T deserialize(value, DogEngine engine) => deserializer(value, engine);

  @override
  serialize(T value, DogEngine engine) => serializer(value, engine);
}
