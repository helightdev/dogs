library dogs_toml;

import 'package:dogs_core/dogs_core.dart';
import 'package:toml/toml.dart';

class DogTomlSerializer extends DogSerializer {

  final codec = DefaultNativeCodec();

  @override
  DogGraphValue deserialize(value) {
    var decoded = TomlDocument.parse(value).toMap();
    return codec.fromNative(decoded);
  }

  @override
  dynamic serialize(DogGraphValue value) {
    var nullExclude = NullExclusionVisitor();
    var native = nullExclude.visit(value).coerceNative();
    return TomlDocument.fromMap(native).toString();
  }
}

extension DogTomlExtension on DogEngine {
  static final _tomlSerializer = DogTomlSerializer();

  DogTomlSerializer get tomlSerializer => _tomlSerializer;

  DogEngine get cborEngine => getChildOrFork(#cbor);

  /// Encodes this [value] to json, using the [DogConverter] associated with [T].
  String tomlEncode<T>(T value) {
    var graph = convertObjectToGraph(value, T);
    return _tomlSerializer.serialize(graph);
  }

  /// Decodes this [encoded] json to an [T] instance,
  /// using the [DogConverter] associated with [T].
  T tomlDecode<T>(String encoded) {
    var graph = _tomlSerializer.deserialize(encoded);
    return convertObjectFromGraph(graph, T);
  }

  /// Converts a [value] to its YAML representation using the
  /// converter associated with [T], [type] or [tree].
  String toToml<T>(T value,
      {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    var native =
        cborEngine.toNative<T>(value, kind: kind, type: type, tree: tree);
    native = tomlEscape(native);
    return TomlDocument.fromMap(native).toString();
  }

  /// Converts YAML supplied via [encoded] to its normal representation
  /// by using the converter associated with [T], [type] or [tree].
  T fromToml<T>(String encoded,
      {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    dynamic native = TomlDocument.parse(encoded).toMap();
    native = tomlUnescape(native);
    return cborEngine.fromNative<T>(native, kind: kind, type: type, tree: tree);
  }
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
      Map() => obj.map<String, dynamic>(
          (k, v) => MapEntry(k.toString(), _baselineEncodeRec(v))),
      _ => obj
    };

dynamic _baselineDecodeRec(dynamic obj) => switch (obj) {
      r"$null$" => null,
      Iterable() => obj.map((e) => _baselineDecodeRec(e)).toList(),
      Map() =>
        obj.map<String, dynamic>((k, v) => MapEntry(k, _baselineDecodeRec(v))),
      _ => obj
    };