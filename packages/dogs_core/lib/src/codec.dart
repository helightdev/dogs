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

/// Defines the native object types for a [DogEngine] and
/// provides converters for them.
abstract class DogNativeCodec {
  /// Defines the native object types for a [DogEngine] and
  /// provides converters for them.
  const DogNativeCodec();

  /// Coercion for native types.
  CodecPrimitiveCoercion get primitiveCoercion => NumberPrimitiveCoercion();

  /// The prefix used for metadata keys.
  String get metaPrefix => "_";

  /// The full key used for type discrimination.
  String get typeDiscriminator => "${metaPrefix}type";

  /// The full key used for value discrimination.
  String get valueDiscriminator => "${metaPrefix}value";

  /// Post-processes a generated value before it is returned from toNative.
  /// This does not apply to any of the values defined in engine.dart since this
  /// could lead to the processing of the same value multiple times which could
  /// lead to unexpected results.
  dynamic postProcessNative(dynamic value) => value;

  /// Pre-processes a native value before it is passed to fromNative.
  /// This does not apply to any of the values defined in engine.dart since this
  /// could lead to the processing of the same value multiple times which could
  /// lead to unexpected results.
  dynamic preProcessNative(dynamic value) => value;

  /// Interop converters for native types.
  /// These converters are most commonly used by [TreeBaseConverterFactory]s
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

/// Mechanism for coercing specific native types to other native types.
abstract interface class CodecPrimitiveCoercion {
  /// Coerces [value] to the [expected] type. The [fieldName] can be used for
  /// error reporting.
  dynamic coerce(TypeCapture expected, dynamic value, String? fieldName);
}

/// Simple implementation of [CodecPrimitiveCoercion] that throws an error
/// when coercion is attempted.
class NoCodecPrimitiveCoercion implements CodecPrimitiveCoercion {
  @override
  dynamic coerce(TypeCapture expected, value, String? fieldName) {
    throw ArgumentError.value(value, fieldName,
        "Can't coerce $value(${value.runtimeType}) to expected ${expected.typeArgument}");
  }
}

/// [CodecPrimitiveCoercion] that allows coercion between [int] and [double].
/// Should be used as the default [CodecPrimitiveCoercion] for [DogEngine]s.
class NumberPrimitiveCoercion implements CodecPrimitiveCoercion {
  @override
  dynamic coerce(TypeCapture expected, value, String? fieldName) {
    if (value is num) {
      if (expected.typeArgument == int) {
        return value.toInt();
      } else if (expected.typeArgument == double) {
        return value.toDouble();
      }
    }

    throw ArgumentError.value(value, fieldName,
        "Can't coerce $value(${value.runtimeType}) to expected ${expected.typeArgument}");
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
  /// Default implementation of [DogNativeCodec].
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
  Map<Type, DogConverter> get bridgeConverters => {
        String:
            NativeRetentionConverter<String>(schema: () => SchemaType.string),
        int: NativeRetentionConverter<int>(schema: () => SchemaType.integer),
        double:
            NativeRetentionConverter<double>(schema: () => SchemaType.number),
        bool: NativeRetentionConverter<bool>(schema: () => SchemaType.boolean),
      };
}
