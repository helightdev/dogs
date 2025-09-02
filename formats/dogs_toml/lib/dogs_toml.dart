library;

import 'package:dogs_core/dogs_core.dart';
import 'package:toml/toml.dart';

class TomlCodec extends DefaultNativeCodec {
  @override
  dynamic postProcessNative(dynamic value) {
    return tomlEscape(value);
  }

  @override
  dynamic preProcessNative(dynamic value) {
    return tomlUnescape(value);
  }

  Map<String, dynamic> tomlEscape(dynamic obj) {
    final root = _baselineEncodeRec(obj);
    return mapifyValue(root) as Map<String, dynamic>;
  }

  dynamic tomlUnescape(Map<String, dynamic> obj) {
    final root = unmapifyValue(obj);
    return _baselineDecodeRec(root);
  }

  dynamic _baselineEncodeRec(dynamic obj) => switch (obj) {
        null => r"$null$",
        Iterable() => obj.map((e) => _baselineEncodeRec(e)).toList(),
        Map() => obj.map<String, dynamic>((k, v) => MapEntry(k.toString(), _baselineEncodeRec(v))),
        _ => obj
      };

  dynamic _baselineDecodeRec(dynamic obj) => switch (obj) {
        r"$null$" => null,
        Iterable() => obj.map((e) => _baselineDecodeRec(e)).toList(),
        Map() => obj.map<String, dynamic>((k, v) => MapEntry(k, _baselineDecodeRec(v))),
        _ => obj
      };
}

extension DogTomlExtension on DogEngine {
  DogEngine get tomlEngine => codec is TomlCodec ? this : getChildOrFork(#toml, codec: TomlCodec());

  /// Converts a [value] to its YAML representation using the
  /// converter associated with [T], [type] or [tree].
  String toToml<T>(T value, {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    var native = tomlEngine.toNative<T>(value, kind: kind, type: type, tree: tree);
    return TomlDocument.fromMap(native).toString();
  }

  /// Converts YAML supplied via [encoded] to its normal representation
  /// by using the converter associated with [T], [type] or [tree].
  T fromToml<T>(String encoded,
      {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    dynamic native = TomlDocument.parse(encoded).toMap();
    return tomlEngine.fromNative<T>(native, kind: kind, type: type, tree: tree);
  }
}
