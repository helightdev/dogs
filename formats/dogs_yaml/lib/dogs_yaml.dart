library dogs_yaml;

import 'dart:collection';

import 'package:dogs_core/dogs_core.dart';
import 'package:json2yaml/json2yaml.dart';
import 'package:yaml/yaml.dart';

class YamlCoercion implements CodecPrimitiveCoercion {
  @override
  dynamic coerce(TypeCapture expected,value, String? fieldName) {
    if (expected.typeArgument == String && value == null) return "";
    if (expected.typeArgument == double && value is int) return value.toDouble();

    throw ArgumentError.value(value, fieldName, "Can't coerce $value to expected $expected");
  }

}

class YamlCodec extends DefaultNativeCodec {
  const YamlCodec();

  @override
  CodecPrimitiveCoercion get primitiveCoercion => YamlCoercion();
}

class YamlSerializer {

  late DogEngine engine;

  void init(DogEngine engine) {
    this.engine = engine.fork(codec: YamlCodec());
  }

  dynamic deserialize(value, Type type) {
    var decoded = loadYaml(value);
    return engine.convertObjectFromNative(decoded, type);
  }

  dynamic serialize(value, Type type) {
    var map = engine.convertObjectToNative(value, type);
    return json2yaml(map, yamlStyle: YamlStyle.generic);
  }
}

extension DogYamlExtension on DogEngine {
  static YamlSerializer? _yamlSerializer;

  YamlSerializer get yamlSerializer {
    _yamlSerializer ??= YamlSerializer()..init(this);
    return _yamlSerializer!;
  }

  /// Encodes this [value] to json, using the [DogConverter] associated with [T].
  String yamlEncode<T>(T value) => yamlSerializer.serialize(value, T);

  /// Decodes this [encoded] json to an [T] instance,
  /// using the [DogConverter] associated with [T].
  T yamlDecode<T>(String encoded) => yamlSerializer.deserialize(encoded, T);
}
