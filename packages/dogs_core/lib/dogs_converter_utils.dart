library;

import "package:dogs_core/dogs_core.dart";

/// Utility class for converters to access dogs deserialization capabilities when decoding custom
/// map structures.
class DogNativeMapReader {
  final DogEngine _engine;
  final Map<String, dynamic> _backing;
  final DogConverter _converter;

  /// Utility class for converters to access dogs deserialization capabilities when decoding custom
  /// map structures.
  const DogNativeMapReader(this._engine, this._backing, this._converter);

  /// Reads a value of type [T] from the backing map by [key].
  /// The type parameter [T] must be specified explicitly and cannot be nullable.
  ///
  /// Strategy:
  /// 1. If the key is not found and [defaultValue] is provided, returns [defaultValue]. Otherwise,
  /// throws [DogSerializerException].
  /// 2. If the value is already of type [T], returns it.
  /// 3. If [T] is a native type (as per the engine's codec), attempts to coerce the value to [T].
  /// 4. Otherwise, uses the engine to deserialize the value into type [T].
  T read<T>(String key, [T? defaultValue]) {
    final value = _backing[key];
    if (value == null) {
      if (defaultValue != null) return defaultValue;
      throw DogSerializerException(message: "Missing required field '$key'", converter: _converter);
    }
    if (value is T) return value;
    if (_engine.codec.isNative(T)) {
      try {
        return _engine.codec.primitiveCoercion.coerce(TypeToken<T>(), value, key);
      } catch (e) {
        throw DogSerializerException(
          message: "Failed to coerce field '$key' to type $T: $e",
          converter: _converter,
          cause: e,
        );
      }
    }
    try {
      return _engine.fromNative<T>(value);
    } catch (e) {
      throw DogSerializerException(
        message: "Failed to deserialize field '$key' to type $T: $e",
        converter: _converter,
        cause: e,
      );
    }
  }

  /// Reads a value of type [T] from the backing map by [key], expecting it to be exactly of type [T].
  T expects<T>(String key, [String? message]) {
    final value = _backing[key];
    if (value is T) return value;
    throw DogSerializerException(
        message: message ?? "Expected type $T for field '$key' but got ${value.runtimeType}");
  }

  /// Direct access to the underlying map to retrieve raw values.
  dynamic operator [](String key) => _backing[key];
}

/// Extension methods for [DogConverter] to simplify common deserialization tasks.
extension ConverterHelperExtensions on DogConverter {
  /// Converts this object to a [DogNativeMapReader] if it is a [Map<String, dynamic>],
  /// otherwise throws a [DogSerializerException].
  DogNativeMapReader readAsMap(dynamic input, DogEngine engine) {
    if (input is Map<String, dynamic>) {
      return DogNativeMapReader(engine, input, this);
    }
    throw DogSerializerException(message: "Expected a map but got $runtimeType", converter: this);
  }

  /// Reads a value of type [T] from [value].
  T readAs<T>(dynamic value, DogEngine engine, [T? defaultValue]) {
    if (value == null) {
      if (defaultValue != null) return defaultValue;
      throw DogSerializerException(message: "Value is null", converter: this);
    }
    if (value is T) return value;
    if (engine.codec.isNative(T)) {
      try {
        return engine.codec.primitiveCoercion.coerce(TypeToken<T>(), value, null);
      } catch (e) {
        throw DogSerializerException(
          message: "Failed to coerce value to type $T: $e",
          converter: this,
          cause: e,
        );
      }
    }
    try {
      return engine.fromNative<T>(value);
    } catch (e) {
      throw DogSerializerException(
        message: "Failed to deserialize value to type $T: $e",
        converter: this,
        cause: e,
      );
    }
  }

  /// Casts this object to type [T] if possible, otherwise throws a [DogSerializerException].
  T expects<T>(dynamic input, DogEngine engine, [String? message]) {
    if (input is T) return input;
    throw DogSerializerException(
        message: message ?? "Expected type $T but got $runtimeType", converter: this);
  }

  /// Casts this object to type [T] if possible, otherwise returns [defaultValue].
  T expectsOr<T>(dynamic input, T defaultValue, DogEngine engine) {
    if (input is T) return input;
    return defaultValue;
  }
}
