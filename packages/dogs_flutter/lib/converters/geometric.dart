import 'package:dogs_core/dogs_converter_utils.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:flutter/painting.dart';

List<double> _parseDoubleTuple4(dynamic value, DogEngine engine, DogConverter converter) {
  var list = converter.expects<List>(value, engine);
  if (list.length != 4) {
    throw DogSerializerException(
      message: "Expected list of 4 numeric values",
      converter: converter,
    );
  }
  return [
    converter.readAs<double>(list[0], engine),
    converter.readAs<double>(list[1], engine),
    converter.readAs<double>(list[2], engine),
    converter.readAs<double>(list[3], engine),
  ];
}

@linkSerializer
class FlutterOffsetConverter extends SimpleDogConverter<Offset> {
  FlutterOffsetConverter() : super(serialName: "FLOffset");

  @override
  Offset deserialize(value, DogEngine engine) {
    var map = readAsMap(value, engine);
    return Offset(map.read<double>("dx"), map.read<double>("dy"));
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
    var map = readAsMap(value, engine);
    return Size(map.read<double>("width"), map.read<double>("height"));
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
    final [left, top, right, bottom] = _parseDoubleTuple4(value, engine, this);
    return Rect.fromLTRB(left, top, right, bottom);
  }

  @override
  serialize(Rect value, DogEngine engine) {
    return [value.left, value.top, value.right, value.bottom];
  }
}

@linkSerializer
class FlutterEdgeInsetsConverter extends SimpleDogConverter<EdgeInsets> {
  FlutterEdgeInsetsConverter() : super(serialName: "FLEdgeInsets");

  @override
  EdgeInsets deserialize(value, DogEngine engine) {
    final [left, top, right, bottom] = _parseDoubleTuple4(value, engine, this);
    return EdgeInsets.fromLTRB(left, top, right, bottom);
  }

  @override
  serialize(EdgeInsets value, DogEngine engine) {
    return [value.left, value.top, value.right, value.bottom];
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
    throw DogSerializerException(message: "Invalid radius value", converter: this);
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
    final [topLeft, topRight, bottomLeft, bottomRight] = _parseDoubleTuple4(value, engine, this);
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomLeft: Radius.circular(bottomLeft),
      bottomRight: Radius.circular(bottomRight),
    );
  }

  @override
  serialize(BorderRadius value, DogEngine engine) {
    return [value.topLeft.x, value.topRight.x, value.bottomLeft.x, value.bottomRight.x];
  }
}

@linkSerializer
class FlutterRRectConverter extends SimpleDogConverter<RRect> {
  FlutterRRectConverter() : super(serialName: "FLRRect");

  @override
  RRect deserialize(value, DogEngine engine) {
    var map = readAsMap(value, engine);
    final rect = map.read<Rect>("dimensions");
    final borderRadius = map.read<BorderRadius>("radii");
    return RRect.fromRectAndCorners(
      rect,
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );
  }

  @override
  serialize(RRect value, DogEngine engine) {
    return <String, dynamic>{
      "dimensions": engine.toNative<Rect>(value.outerRect),
      "radii": engine.toNative<BorderRadius>(
        BorderRadius.only(
          topLeft: value.tlRadius,
          topRight: value.trRadius,
          bottomLeft: value.blRadius,
          bottomRight: value.brRadius,
        ),
      ),
    };
  }
}
