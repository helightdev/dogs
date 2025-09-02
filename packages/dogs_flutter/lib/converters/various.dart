import 'package:dogs_core/dogs_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@linkSerializer
class FlutterColorConverter extends SimpleDogConverter<Color> {
  FlutterColorConverter() : super(serialName: "FLColor");

  @override
  Color deserialize(value, DogEngine engine) {
    if (value is String) {
      final v = fromHex(value);
      if (v == null) {
        throw DogSerializerException(message: "Invalid color value", converter: this);
      }
      return v;
    } else if (value is int) {
      return Color(value);
    }
    throw DogSerializerException(message: "Invalid color value", converter: this);
  }

  @override
  serialize(Color value, DogEngine engine) {
    return "#${value.toARGB32().toRadixString(16).toUpperCase().padLeft(8, "0")}";
  }

  static Color? fromHex(String? value) {
    if (value == null) return null;
    if (value.startsWith("#")) {
      value = value.substring(1);
    }
    if (value.length == 6) {
      value = "FF$value";
    } else if (value.length != 8) {
      return null;
    }
    var parsed = int.tryParse(value, radix: 16);
    if (parsed == null) {
      return null;
    }
    return Color(parsed);
  }

  static String toHex(Color color) {
    return "#${color.toARGB32().toRadixString(16).toUpperCase().padLeft(8, "0")}";
  }
}

@linkSerializer
class FlutterLogicalKeyConverter extends SimpleDogConverter<LogicalKeyboardKey> {
  FlutterLogicalKeyConverter() : super(serialName: "FLLogicalKey");

  @override
  LogicalKeyboardKey deserialize(value, DogEngine engine) {
    if (value is Map) {
      var keyId = value["id"];
      var keyLabel = value["label"];
      var resolved = LogicalKeyboardKey.findKeyByKeyId(keyId);
      if (resolved != null && resolved.keyLabel == keyLabel) {
        return resolved;
      }
    }
    throw DogSerializerException(message: "Invalid logical key value", converter: this);
  }

  @override
  serialize(LogicalKeyboardKey value, DogEngine engine) {
    return {"id": value.keyId, "label": value.keyLabel};
  }
}

@linkSerializer
class FlutterSingleActivatorConverter extends SimpleDogConverter<SingleActivator> {
  FlutterSingleActivatorConverter() : super(serialName: "FLSingleActivator");

  @override
  SingleActivator deserialize(value, DogEngine engine) {
    if (value is Map) {
      var key = value["k"];
      var control = value["c"] ?? false;
      var shift = value["s"] ?? false;
      var alt = value["a"] ?? false;
      var meta = value["m"] ?? false;
      var repeats = value["r"] ?? false;
      var numLock = value["n"] ?? 0;

      if (key is Map) {
        return SingleActivator(
          dogs.fromNative<LogicalKeyboardKey>(key),
          control: control == true,
          shift: shift == true,
          alt: alt == true,
          meta: meta == true,
          numLock: LockState.values[numLock as int],
          includeRepeats: repeats == true,
        );
      }
    }
    throw DogSerializerException(message: "Invalid single activator value", converter: this);
  }

  @override
  serialize(SingleActivator value, DogEngine engine) {
    return {
      "k": engine.toNative<LogicalKeyboardKey>(value.trigger),
      "c": value.control,
      "s": value.shift,
      "a": value.alt,
      "m": value.meta,
      "r": value.includeRepeats,
      "n": value.numLock.index,
    };
  }
}
