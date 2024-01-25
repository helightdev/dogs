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
}
