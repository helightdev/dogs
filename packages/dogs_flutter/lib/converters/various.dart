import 'package:dogs_core/dogs_converter_utils.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_core/dogs_schema.dart';
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
    var map = readAsMap(value, engine);
    var keyId = map.read<int>("id");
    var keyLabel = map.read<String>("label");

    var resolved = LogicalKeyboardKey.findKeyByKeyId(keyId);
    if (resolved != null && resolved.keyLabel == keyLabel) {
      return resolved;
    }
    throw DogSerializerException(message: "Invalid logical key value", converter: this);
  }

  @override
  serialize(LogicalKeyboardKey value, DogEngine engine) => {
    "id": value.keyId,
    "label": value.keyLabel,
  };

  @override
  SchemaType describeOutput(DogEngine engine, SchemaConfig config) =>
      object({"id": integer(), "label": string()});
}

@linkSerializer
class FlutterSingleActivatorConverter extends SimpleDogConverter<SingleActivator> {
  FlutterSingleActivatorConverter() : super(serialName: "FLSingleActivator");

  @override
  SingleActivator deserialize(value, DogEngine engine) {
    var map = readAsMap(value, engine);
    return SingleActivator(
      map.read<LogicalKeyboardKey>("k"),
      control: map.read<bool>("c", false),
      shift: map.read<bool>("s", false),
      alt: map.read<bool>("a", false),
      meta: map.read<bool>("m", false),
      numLock: LockState.values[map.read<int>("n", 0)],
      includeRepeats: map.read<bool>("r", false),
    );
  }

  @override
  serialize(SingleActivator value, DogEngine engine) => {
    "k": engine.toNative<LogicalKeyboardKey>(value.trigger),
    "c": value.control,
    "s": value.shift,
    "a": value.alt,
    "m": value.meta,
    "r": value.includeRepeats,
    "n": value.numLock.index,
  };

  @override
  SchemaType describeOutput(DogEngine engine, SchemaConfig config) => object({
    "k": engine.describe<LogicalKeyboardKey>(),
    "c": boolean(),
    "s": boolean(),
    "a": boolean(),
    "m": boolean(),
    "r": boolean(),
    "n": integer(),
  });
}
