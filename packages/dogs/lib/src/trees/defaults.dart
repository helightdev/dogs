/*
 *    Copyright 2022, the DOGs authors
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

part of "../trees.dart";

/// Collection of default [TreeBaseConverterFactory]s.
class DefaultTreeBaseFactories {
  DefaultTreeBaseFactories._();

  /// Factory for [List]s.
  static final list = TreeBaseConverterFactory.createIterableFactory<List>(
    wrap: <T>(Iterable<T> entries) => entries.toList(),
    unwrap: <T>(List value) => value,
  );

  /// Factory for [Set]s.
  static final set = TreeBaseConverterFactory.createIterableFactory<Set>(
    wrap: <T>(Iterable<T> entries) => entries.toSet(),
    unwrap: <T>(Set value) => value,
  );

  /// Factory for [Iterable]s.
  static final iterable =
      TreeBaseConverterFactory.createIterableFactory<Iterable>(
    wrap: <T>(Iterable<T> entries) => entries,
    unwrap: <T>(Iterable value) => value,
  );

  /// Factory for [Map]s.
  static final map = TreeBaseConverterFactory.createNargsFactory<Map>(
      nargs: 2, consume: <K, V>() => MapNTreeArgConverter<K, V>());

  /// Factory for [Optional]s.
  static final optional = TreeBaseConverterFactory.createNargsFactory<Optional>(
      nargs: 1, consume: <T>() => OptionalNTreeArgConverter<T>());

  /// Factory for [Page]s.
  static final page = TreeBaseConverterFactory.createNargsFactory<Page>(
      nargs: 1, consume: <T>() => PageNTreeArgConverter<T>());
}

/// [NTreeArgConverter] for [Map]s.
class MapNTreeArgConverter<K, V> extends NTreeArgConverter<Map> {
  @override
  Map deserialize(value, DogEngine engine) {
    if (value == null) return <K, V>{}; // Similar to primitive coercion
    if (value is Map) {
      return value.map<K, V>((key, value) => MapEntry<K, V>(
        deserializeArg(key, 0, engine),
        deserializeArg(value, 1, engine),
      ));
    } else if (value is List) {
      final Map<K, V> map = {};
      for (var entry in value) {
        if (entry is Map) {
          map[deserializeArg(entry["key"], 0, engine)] =
              deserializeArg(entry["value"], 1, engine);
        } else {
          throw ArgumentError("Expected map entry");
        }
      }
      return map;
    }
    throw ArgumentError("Expected map or entry list");
  }

  @override
  serialize(Map value, DogEngine engine) {
    final data = value.map((key, value) => MapEntry(
          serializeArg(key, 0, engine),
          serializeArg(value, 1, engine),
        ));

    // Encode to entry list instead of map
    if (data.keys.any((key) => key is! String)) {
      final entries = <Map<String, dynamic>>[];
      for (var entry in data.entries) {
        entries.add({
          "key": entry.key,
          "value": entry.value,
        });
      }
      return entries;
    }

    return data;
  }

  @override
  SchemaType inferSchemaType(DogEngine engine, SchemaConfig config) {
    final keyOutput = itemConverters[0].describeOutput(engine, config);
    final valueOutput = itemConverters[1].describeOutput(engine, config);
    if (keyOutput.type == SchemaCoreType.string) {
      return SchemaType.map(valueOutput);
    } else {
      return SchemaArray(SchemaObject(
          fields: [
            SchemaField("key", keyOutput),
            SchemaField("value", valueOutput),
          ]
      ));
    }
  }

  @override
  Iterable<(dynamic, int)> traverse(dynamic value, DogEngine engine) sync* {
    if (value == null || value is! Map) return;
    for (var entry in value.entries) {
      yield (entry.key, 0);
      yield (entry.value, 1);
    }
  }

  @override
  bool get canSerializeNull => true;
}
