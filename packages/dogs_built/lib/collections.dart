// ignore_for_file: unused_import

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

import 'dart:convert';

import 'package:built_collection/built_collection.dart';
import 'package:dogs_core/dogs_core.dart';

class BuiltCollectionFactories {
  static final builtList = TreeBaseConverterFactory.createIterableFactory<BuiltList>(
    wrap: <T>(Iterable<T> entries) => BuiltList<T>.of(entries),
    unwrap: <T>(BuiltList value) => value,
  );

  static final builtSet = TreeBaseConverterFactory.createIterableFactory<BuiltSet>(
    wrap: <T>(Iterable<T> entries) => BuiltSet<T>.of(entries),
    unwrap: <T>(BuiltSet value) => value,
  );

  static final builtMap = TreeBaseConverterFactory.createNargsFactory<BuiltMap>(
      nargs: 2, consume: <K, V>() => BuiltMapNTreeArgConverter<K, V>());

  static final builtListMultimap = TreeBaseConverterFactory.createNargsFactory<BuiltListMultimap>(
      nargs: 2, consume: <K, V>() => BuiltListMultimapNTreeArgConverter<K, V>());

  static final builtSetMultimap = TreeBaseConverterFactory.createNargsFactory<BuiltSetMultimap>(
      nargs: 2, consume: <K, V>() => BuiltSetMultimapNTreeArgConverter<K, V>());
}

class BuiltMapNTreeArgConverter<K, V> extends NTreeArgConverter<BuiltMap> {
  @override
  BuiltMap deserialize(value, DogEngine engine) {
    return BuiltMap<K, V>((value as Map).map<K, V>((key, value) => MapEntry<K, V>(
          deserializeArg(key, 0, engine),
          deserializeArg(value, 1, engine),
        )));
  }

  @override
  serialize(BuiltMap value, DogEngine engine) {
    return value.map((key, value) => MapEntry(
          serializeArg(key, 0, engine),
          serializeArg(value, 1, engine),
        ));
  }
}

class BuiltListMultimapNTreeArgConverter<K, V> extends NTreeArgConverter<BuiltListMultimap> {
  @override
  BuiltListMultimap deserialize(value, DogEngine engine) {
    return BuiltListMultimap<K, V>((value as Map).map<K, Iterable<V>>((key, value) =>
        MapEntry<K, Iterable<V>>(deserializeArg(key, 0, engine),
            (value as Iterable).map((p0) => deserializeArg(p0, 1, engine) as V).toList())));
  }

  @override
  serialize(BuiltListMultimap value, DogEngine engine) {
    return value.toMap().map((key, value) => MapEntry(
        serializeArg(key, 0, engine), value.map((p0) => serializeArg(p0, 1, engine)).toList()));
  }
}

class BuiltSetMultimapNTreeArgConverter<K, V> extends NTreeArgConverter<BuiltSetMultimap> {
  @override
  BuiltSetMultimap deserialize(value, DogEngine engine) {
    return BuiltSetMultimap<K, V>((value as Map).map<K, Iterable<V>>((key, value) =>
        MapEntry<K, Iterable<V>>(deserializeArg(key, 0, engine),
            (value as Iterable).map((p0) => deserializeArg(p0, 1, engine) as V).toList())));
  }

  @override
  serialize(BuiltSetMultimap value, DogEngine engine) {
    return value.toMap().map((key, value) => MapEntry(
        serializeArg(key, 0, engine), value.map((p0) => serializeArg(p0, 1, engine)).toList()));
  }
}
