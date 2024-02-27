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

import "dart:convert" as conv;

import "package:dogs_core/dogs_core.dart";

/// Extension on [DogEngine] that provides JSON serialization and deserialization.
extension DogJsonExtension on DogEngine {
  /// Converts a [value] to its JSON representation using the
  /// converter associated with [T] or [tree].
  String toJson<T>(T value,
      {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    final native = toNative<T>(value, kind: kind, type: type, tree: tree);
    return conv.jsonEncode(native);
  }

  /// Converts JSON supplied via [encoded] to its normal representation
  /// by using the converter associated with [T] or [tree].
  T fromJson<T>(String encoded,
      {IterableKind kind = IterableKind.none, Type? type, TypeTree? tree}) {
    final native = conv.jsonDecode(encoded);
    return fromNative<T>(native, kind: kind, type: type, tree: tree);
  }
}
