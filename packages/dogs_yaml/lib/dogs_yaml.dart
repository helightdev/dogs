library dogs_yaml;

import 'dart:collection';

import 'package:dogs_core/dogs_core.dart';
import 'package:json2yaml/json2yaml.dart';
import 'package:yaml/yaml.dart';

class DogYamlSerializer extends DogSerializer {

  final codec = DefaultNativeCodec();

  @override
  DogGraphValue deserialize(value) {
    var decoded = loadYaml(value);
    return codec.fromNative(decoded);
  }

  @override
  dynamic serialize(DogGraphValue value) {
    var map = value.asMap!;
    var visitor = StringKeyedMapVisitor();
    var skm = visitor.visitFinal(map);
    return json2yaml(skm);
  }
}

class StringMapImpl with MapMixin<String, dynamic> {
  final Map<dynamic, dynamic> delegate;
  StringMapImpl(this.delegate);

  @override
  operator [](Object? key) {
    return delegate[key];
  }

  @override
  void operator []=(String key, value) {
    delegate[key] = value;
  }

  @override
  void clear() {
    delegate.clear();
  }

  @override
  Iterable<String> get keys => delegate.keys.cast<String>();

  @override
  remove(Object? key) {
    delegate.remove(key);
  }
}

extension DogYamlExtension on DogEngine {
  static final _yamlSerializer = DogYamlSerializer();

  DogYamlSerializer get yamlSerializer => _yamlSerializer;

  /// Encodes this [value] to json, using the [DogConverter] associated with [T].
  String yamlEncode<T>(T value) {
    var graph = convertObjectToGraph(value, T);
    return _yamlSerializer.serialize(graph);
  }

  /// Decodes this [encoded] json to an [T] instance,
  /// using the [DogConverter] associated with [T].
  T yamlDecode<T>(String encoded) {
    var graph = _yamlSerializer.deserialize(encoded);
    return convertObjectFromGraph(graph, T);
  }
}
