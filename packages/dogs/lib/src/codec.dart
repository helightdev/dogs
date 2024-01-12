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

/// Defines the native object types for a [DogEngine] and
/// provides converters for them.
abstract class DogNativeCodec {
  const DogNativeCodec();

  CodecPrimitiveCoercion get primitiveCoercion => NoCodecPrimitiveCoercion();

  /// Interop converters for native types.
  /// These converters are most commonly used by [TreeBaseConverterFactory]s to
  /// since they require a [DogConverter] for every type.
  ///
  /// Since the values of the mapped types are native, this map should only
  /// contain [NativeRetentionConverter]s or similar converters.
  Map<Type, DogConverter> get bridgeConverters;

  /// Returns true if the given [serial] is a native type.
  bool isNative(Type serial);

  /// Converts a native value to a [DogGraphValue].
  DogGraphValue fromNative(dynamic value);
}

abstract interface class CodecPrimitiveCoercion {
  dynamic coerce(TypeCapture expected, dynamic value, String? fieldName);
}

class NoCodecPrimitiveCoercion implements CodecPrimitiveCoercion {
  @override
  dynamic coerce(TypeCapture expected,value, String? fieldName) {
    throw ArgumentError.value(value, fieldName, "Can't coerce $value to expected ${expected.typeArgument}");
  }
}

/// Default implementation of [DogNativeCodec].
/// Defines the following native types:
/// - String
/// - int
/// - double
/// - bool
///
/// Can also convert [Iterable]s and [Map]s of native types.
class DefaultNativeCodec extends DogNativeCodec {
  const DefaultNativeCodec();

  @override
  DogGraphValue fromNative(value) {
    if (value == null) return DogNull();
    if (value is String) return DogString(value);
    if (value is int) return DogInt(value);
    if (value is double) return DogDouble(value);
    if (value is bool) return DogBool(value);
    if (value is Iterable) {
      return DogList(value.map((e) => fromNative(e)).toList());
    }
    if (value is Map) {
      return DogMap(value
          .map((key, value) => MapEntry(fromNative(key), fromNative(value))));
    }

    throw ArgumentError.value(
        value, null, "Can't coerce native value to dart object graph");
  }

  @override
  bool isNative(Type serial) {
    return serial == String ||
        serial == int ||
        serial == double ||
        serial == bool;
  }

  @override
  Map<Type, DogConverter> get bridgeConverters => const {
    String: NativeRetentionConverter<String>(),
    int: NativeRetentionConverter<int>(),
    double: NativeRetentionConverter<double>(),
    bool: NativeRetentionConverter<bool>()
  };
}