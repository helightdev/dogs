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

  static final page = TreeBaseConverterFactory.createNargsFactory<Page>(
      nargs: 1, consume: <T>() => PageNTreeArgConverter<T>());
}

/// [NTreeArgConverter] for [Map]s.
class MapNTreeArgConverter<K, V> extends NTreeArgConverter<Map> {
  @override
  Map deserialize(value, DogEngine engine) {
    if (value == null) return <K, V>{}; // Similar to primitive coercion
    return (value as Map).map<K, V>((key, value) => MapEntry<K, V>(
          deserializeArg(key, 0, engine),
          deserializeArg(value, 1, engine),
        ));
  }

  @override
  serialize(Map value, DogEngine engine) {
    return value.map((key, value) => MapEntry(
          serializeArg(key, 0, engine),
          serializeArg(value, 1, engine),
        ));
  }

  @override
  APISchemaObject get output => APISchemaObject.map(
        ofSchema: itemConverters[1].output,
      );

  @override
  bool get canSerializeNull => true;
}
