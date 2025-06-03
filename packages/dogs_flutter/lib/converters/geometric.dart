import 'package:dogs_core/dogs_core.dart';
import 'package:flutter/painting.dart';

List<double> _parseDoubleTuple4(dynamic value, {required String typeName}) {
  if (value is! List) {
    throw DogSerializerException(
      message: "Invalid $typeName value, expected a list",
    );
  }
  if (value.length != 4) {
    throw DogSerializerException(
      message: "Invalid $typeName value, expected 4 values",
    );
  }
  final [a, b, c, d] = value;
  if (a is num && b is num && c is num && d is num) {
    return [a.toDouble(), b.toDouble(), c.toDouble(), d.toDouble()];
  }
  throw DogSerializerException(
    message: "Invalid $typeName value, expected numeric values",
  );
}

@linkSerializer
class FlutterOffsetConverter extends SimpleDogConverter<Offset> {
  FlutterOffsetConverter() : super(serialName: "FLOffset");

  @override
  Offset deserialize(value, DogEngine engine) {
    if (value is Map<String, dynamic>) {
      var dx = value["dx"];
      var dy = value["dy"];
      if (dx is num && dy is num) {
        return Offset(dx.toDouble(), dy.toDouble());
      }
    }
    throw DogSerializerException(
      message: "Invalid offset value",
      converter: this,
    );
  }

  @override
  serialize(Offset value, DogEngine engine) {
    return <String, dynamic>{"dx": value.dx, "dy": value.dy};
  }
}

@linkSerializer
class FlutterSizeConverter extends SimpleDogConverter<Size> {
  FlutterSizeConverter() : super(serialName: "FLSize");

  @override
  Size deserialize(value, DogEngine engine) {
    if (value is Map<String, dynamic>) {
      var width = value["width"];
      var height = value["height"];
      if (width is num && height is num) {
        return Size(width.toDouble(), height.toDouble());
      }
    }
    throw DogSerializerException(
      message: "Invalid size value",
      converter: this,
    );
  }

  @override
  serialize(Size value, DogEngine engine) {
    return <String, dynamic>{"width": value.width, "height": value.height};
  }
}

@linkSerializer
class FlutterRectConverter extends SimpleDogConverter<Rect> {
  FlutterRectConverter() : super(serialName: "FLRect");

  @override
  Rect deserialize(value, DogEngine engine) {
    return fromValue(value);
  }

  @override
  serialize(Rect value, DogEngine engine) {
    return [value.left, value.top, value.right, value.bottom];
  }

  static Rect fromValue(dynamic fieldValue) {
    final [left, top, right, bottom] = _parseDoubleTuple4(
      fieldValue,
      typeName: "rect",
    );
    return Rect.fromLTRB(left, top, right, bottom);
  }
}

@linkSerializer
class FlutterEdgeInsetsConverter extends SimpleDogConverter<EdgeInsets> {
  FlutterEdgeInsetsConverter() : super(serialName: "FLEdgeInsets");

  @override
  EdgeInsets deserialize(value, DogEngine engine) {
    return fromValue(value);
  }

  @override
  serialize(EdgeInsets value, DogEngine engine) {
    return [value.left, value.top, value.right, value.bottom];
  }

  static EdgeInsets fromValue(dynamic fieldValue) {
    final [left, top, right, bottom] = _parseDoubleTuple4(
      fieldValue,
      typeName: "edge insets",
    );
    return EdgeInsets.fromLTRB(left, top, right, bottom);
  }
}

@linkSerializer
class FlutterRadiusConverter extends SimpleDogConverter<Radius> {
  FlutterRadiusConverter() : super(serialName: "FLRadius");

  @override
  Radius deserialize(value, DogEngine engine) {
    if (value is num) {
      return Radius.circular(value.toDouble());
    }
    throw DogSerializerException(
      message: "Invalid radius value",
      converter: this,
    );
  }

  @override
  serialize(Radius value, DogEngine engine) {
    return value.x;
  }

  static Radius fromValue(dynamic fieldValue) {
    if (fieldValue is num) {
      return Radius.circular(fieldValue.toDouble());
    }
    throw DogSerializerException(message: "Invalid radius value");
  }
}

@linkSerializer
class FlutterBorderRadiusConverter extends SimpleDogConverter<BorderRadius> {
  FlutterBorderRadiusConverter() : super(serialName: "FLBorderRadius");

  @override
  BorderRadius deserialize(value, DogEngine engine) {
    return fromValue(value);
  }

  @override
  serialize(BorderRadius value, DogEngine engine) {
    return [
      value.topLeft.x,
      value.topRight.x,
      value.bottomLeft.x,
      value.bottomRight.x,
    ];
  }

  static BorderRadius fromValue(dynamic fieldValue) {
    final [topLeft, topRight, bottomLeft, bottomRight] = _parseDoubleTuple4(
      fieldValue,
      typeName: "border radius",
    );
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }
}

@linkSerializer
class FlutterRRectConverter extends SimpleDogConverter<RRect> {
  FlutterRRectConverter() : super(serialName: "FLRRect");

  @override
  RRect deserialize(value, DogEngine engine) {
    if (value is Map<String, dynamic>) {
      final rect = FlutterRectConverter.fromValue(value["dimensions"]);
      final borderRadius = FlutterBorderRadiusConverter.fromValue(
        value["radii"],
      );
      return RRect.fromRectAndCorners(
        rect,
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      );
    }
    throw DogSerializerException(
      message: "Invalid RRect value",
      converter: this,
    );
  }

  @override
  serialize(RRect value, DogEngine engine) {
    return <String, dynamic>{
      "dimensions": [value.left, value.top, value.right, value.bottom],
      "radii": [
        value.tlRadius.x,
        value.trRadius.x,
        value.blRadius.x,
        value.brRadius.x,
      ],
    };
  }
}