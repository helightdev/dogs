import 'dart:ui';

import 'package:dogs_core/dogs_core.dart';

@linkSerializer
class FlutterColorConverter extends SimpleDogConverter<Color> {
  FlutterColorConverter() : super(serialName: "FLColor");

  @override
  Color deserialize(value, DogEngine engine) {
    if (value is String) {
      final v = fromHex(value);
      if (v == null) {
        throw DogSerializerException(
          message: "Invalid color value",
          converter: this,
        );
      }
      return v;
    } else if (value is int) {
      return Color(value);
    }
    throw DogSerializerException(
      message: "Invalid color value",
      converter: this,
    );
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
