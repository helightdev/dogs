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

import "package:dogs_core/dogs_core.dart";

/// A mixin that provides a simple way to add metadata to a class.
mixin MetadataMixin {
  final Map<Object, Object?> _metadata = {};

  /// Returns a read-only map of all metadata entries.
  Map<Object, Object?> get metadata => Map.unmodifiable(_metadata);

  /// Clears all metadata entries.
  void clearMeta() => _metadata.clear();

  /// Returns the metadata entry for the given key or type argument.
  /// If no metadata entry is found, throws an exception or automatically
  /// calls the [orElse] function to initialize the metadata entry and return it.
  T getMeta<T>({Object? key, T Function()? orElse}) {
    key ??= T;
    final data = _metadata[key] as T;
    if (data == null) {
      if (orElse != null) {
        final newValue = orElse();
        _metadata[key] = newValue;
        return newValue;
      }
      throw DogException("No data for key $key");
    }
    return data;
  }

  /// Returns the metadata entry for the given key or type argument.
  /// If no metadata entry is found, returns null.
  T? getMetaOrNull<T>([Object? key]) {
    key ??= T;
    return _metadata[key] as T?;
  }

  /// Sets the metadata entry for the given key or type argument.
  void setMeta<T>(T value, {Object? key}) => _metadata[key ?? T] = value;
}
