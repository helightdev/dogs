library dogs_yaml;

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
    map = stringKeyedMapFrom(map);
    return json2yaml(map, yamlStyle: YamlStyle.generic);
  }
}

extension DogYamlExtension on DogEngine {
  static YamlSerializer? _yamlSerializer;

  YamlSerializer get yamlSerializer {
    _yamlSerializer ??= YamlSerializer()..init(this);
    return _yamlSerializer!;
  }

  DogEngine get yamlEngine => getChildOrFork(#yaml, codec: const YamlCodec());

  /// Converts a [value] to its YAML representation using the
  /// converter associated with [T], [type] or [tree].
  String toYaml<T>(T value,
      {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    final native =
        yamlEngine.toNative<T>(value, kind: kind, type: type, tree: tree);
    var escapedMap = yamlEscape(native);
    return json2yaml(escapedMap, yamlStyle: YamlStyle.generic);
  }

  /// Converts YAML supplied via [encoded] to its normal representation
  /// by using the converter associated with [T], [type] or [tree].
  T fromYaml<T>(String encoded,
      {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    dynamic native = stringKeyedMapFrom(loadYaml(encoded));
    native = yamlUnescape(native);
    return yamlEngine.fromNative<T>(native, kind: kind, type: type, tree: tree);
  }

  @Deprecated("Use toYaml instead")

  /// Encodes this [value] to json, using the [DogConverter] associated with [T].
  String yamlEncode<T>(T value) => yamlSerializer.serialize(value, T);

  @Deprecated("Use fromYaml instead")

  /// Decodes this [encoded] json to an [T] instance,
  /// using the [DogConverter] associated with [T].
  T yamlDecode<T>(String encoded) => yamlSerializer.deserialize(encoded, T);
}

Map<String, dynamic> yamlEscape(dynamic obj) {
  final root = _baselineEncodeRec(obj);
  return mapifyValue(root) as Map<String, dynamic>;
}

dynamic yamlUnescape(Map<String, dynamic> obj) {
  final root = unmapifyValue(obj);
  return _baselineDecodeRec(root);
}

dynamic _baselineEncodeRec(dynamic obj) => switch (obj) {
      Iterable() => obj.map((e) => _baselineEncodeRec(e)).toList(),
      Map() => obj.map<String, dynamic>(
          (k, v) => MapEntry(k.toString(), _baselineEncodeRec(v))),
      _ => obj
    };

dynamic _baselineDecodeRec(dynamic obj) => switch (obj) {
      Iterable() => obj.map((e) => _baselineDecodeRec(e)).toList(),
      Map() =>
        obj.map<String, dynamic>((k, v) => MapEntry(k, _baselineDecodeRec(v))),
      _ => obj
    };