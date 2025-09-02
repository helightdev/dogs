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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogs_core/dogs_core.dart';

class FirebaseNativeCodec extends DogNativeCodec {
  @override
  DogGraphValue fromNative(value) {
    if (value == null) return const DogNull();
    if (value is String) return DogString(value);
    if (value is int) return DogInt(value);
    if (value is double) return DogDouble(value);
    if (value is bool) return DogBool(value);
    if (value is Timestamp) return DogNative(value, "Timestamp");
    if (value is GeoPoint) return DogNative(value, "GeoPoint");
    if (value is Blob) return DogNative(value, "Blob");
    if (value is Iterable) {
      return DogList(value.map((e) => fromNative(e)).toList());
    }
    if (value is Map) {
      return DogMap(value.map((key, value) => MapEntry(fromNative(key), fromNative(value))));
    }

    throw ArgumentError.value(value, null, "Can't coerce native value to dart object graph");
  }

  @override
  bool isNative(Type serial) {
    return serial == String ||
        serial == int ||
        serial == double ||
        serial == bool ||
        serial == Timestamp ||
        serial == GeoPoint ||
        serial == Blob;
  }

  @override
  Map<Type, DogConverter> get bridgeConverters => const {
        String: NativeRetentionConverter<String>(),
        int: NativeRetentionConverter<int>(),
        double: NativeRetentionConverter<double>(),
        bool: NativeRetentionConverter<bool>(),
        Timestamp: NativeRetentionConverter<Timestamp>(),
        GeoPoint: NativeRetentionConverter<GeoPoint>(),
        Blob: NativeRetentionConverter<Blob>(),
      };
}
