library dogs_yaml;

import 'dart:collection';

import 'package:dogs_core/dogs_core.dart';
import 'package:json2yaml/json2yaml.dart';
import 'package:yaml/yaml.dart';

class YamlCoercion implements CodecPrimitiveCoercion {
  @override
  dynamic coerce(TypeCapture expected, value, String? fieldName) {
    if (expected.typeArgument == String && value == null) return "";
    if (expected.typeArgument == double && value is int) {
      return value.toDouble();
    }

    throw ArgumentError.value(
        value, fieldName, "Can't coerce $value to expected $expected");
  }
}

class YamlCodec extends DefaultNativeCodec {
  const YamlCodec();

  @override
  CodecPrimitiveCoercion get primitiveCoercion => YamlCoercion();

  @override
  dynamic postProcessNative(dynamic value) {
    return yamlEscape(value);
  }

  @override
  dynamic preProcessNative(dynamic value) {
    return yamlUnescape(value);
  }

  Map<String, dynamic> yamlEscape(dynamic obj) {
    final root = _baselineEncodeRec(obj);
    return mapifyValue(root) as Map<String, dynamic>;
  }

  dynamic yamlUnescape(MapBase<dynamic, dynamic> obj) {
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
        Map() => obj.map<String, dynamic>(
            (k, v) => MapEntry(k.toString(), _baselineDecodeRec(v))),
        _ => obj
      };
}

extension DogYamlExtension on DogEngine {
  DogEngine get yamlEngine => codec is YamlCodec
      ? this
      : getChildOrFork(#yaml, codec: const YamlCodec());

  /// Converts a [value] to its YAML representation using the
  /// converter associated with [T], [type] or [tree].
  String toYaml<T>(T value,
      {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    final native =
        yamlEngine.toNative<T>(value, kind: kind, type: type, tree: tree);
    return json2yaml(native, yamlStyle: YamlStyle.generic);
  }

  /// Converts YAML supplied via [encoded] to its normal representation
  /// by using the converter associated with [T], [type] or [tree].
  T fromYaml<T>(String encoded,
      {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    dynamic native = loadYaml(encoded);
    return yamlEngine.fromNative<T>(native, kind: kind, type: type, tree: tree);
  }
}
