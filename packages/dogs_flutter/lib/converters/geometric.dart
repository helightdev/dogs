import 'package:dogs_core/dogs_converter_utils.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_core/dogs_schema.dart';
import 'package:flutter/material.dart';

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

  @override
  SchemaType describeOutput(DogEngine engine, SchemaConfig config) =>
      object({"dx": number(), "dy": number()});
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

  @override
  SchemaType describeOutput(DogEngine engine, SchemaConfig config) =>
      object({"width": number(), "height": number()});
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

  @override
  SchemaType describeOutput(DogEngine engine, SchemaConfig config) => number().array().length(4);
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

  @override
  SchemaType describeOutput(DogEngine engine, SchemaConfig config) => number().array().length(4);
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

  @override
  SchemaType describeOutput(DogEngine engine, SchemaConfig config) => number();
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

  @override
  SchemaType describeOutput(DogEngine engine, SchemaConfig config) => number().array().length(4);
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

  @override
  SchemaType describeOutput(DogEngine engine, SchemaConfig config) =>
      object({"dimensions": engine.describe<Rect>(), "radii": engine.describe<BorderRadius>()});
}

@linkSerializer
class FlutterBoxConstraintsConverter extends SimpleDogConverter<BoxConstraints> {
  FlutterBoxConstraintsConverter() : super(serialName: "FLBoxConstraints");

  @override
  BoxConstraints deserialize(value, DogEngine engine) {
    final [minWidth, maxWidth, minHeight, maxHeight] = _parseDoubleTuple4(value, engine, this);
    return BoxConstraints(
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
    );
  }

  @override
  serialize(BoxConstraints value, DogEngine engine) {
    return [value.minWidth, value.maxWidth, value.minHeight, value.maxHeight];
  }

  @override
  SchemaType describeOutput(DogEngine engine, SchemaConfig config) => number().array().length(4);
}

@linkSerializer
class FlutterAlignmentConverter extends SimpleDogConverter<Alignment> {
  FlutterAlignmentConverter() : super(serialName: "FLAlignment");

  @override
  Alignment deserialize(value, DogEngine engine) {
    var map = readAsMap(value, engine);
    return Alignment(map.read<double>("x"), map.read<double>("y"));
  }

  @override
  serialize(Alignment value, DogEngine engine) {
    return <String, dynamic>{"x": value.x, "y": value.y};
  }

  @override
  SchemaType describeOutput(DogEngine engine, SchemaConfig config) =>
      object({"x": number(), "y": number()});
}

@linkSerializer
class FlutterMatrix4Converter extends SimpleDogConverter<Matrix4> {
  FlutterMatrix4Converter() : super(serialName: "FLMatrix4");

  @override
  Matrix4 deserialize(value, DogEngine engine) {
    var list = expects<List>(value, engine);
    if (list.length != 16) {
      throw DogSerializerException(message: "Expected list of 16 numeric values", converter: this);
    }
    return Matrix4.fromList(list.map((e) => readAs<double>(e, engine)).toList());
  }

  @override
  serialize(Matrix4 value, DogEngine engine) {
    return value.storage;
  }

  @override
  SchemaType describeOutput(DogEngine engine, SchemaConfig config) => number().array().length(16);
}
