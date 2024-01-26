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

import 'package:decimal/decimal.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:fixnum/fixnum.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

void main() {
}

class MongoDbCodec extends DogNativeCodec {

  @override
  DogGraphValue fromNative(value) {
    if (value == null) return DogNull();
    if (value is String) return DogString(value);
    if (value is int) return DogInt(value);
    if (value is double) return DogDouble(value);
    if (value is bool) return DogBool(value);
    if (value is DateTime) return DogNative(value, "DateTime");
    if (value is RegExp) return DogNative(value, "RegExp");
    if (value is mongo.ObjectId) return DogNative(value, "ObjectId");
    if (value is mongo.DbRef) return DogNative(value, "DbRef");
    if (value is mongo.JsCode) return DogNative(value, "JsCode");
    if (value is mongo.Timestamp) return DogNative(value, "Timestamp");
    if (value is Int64) return DogNative(value, "Int64");
    if (value is Decimal) return DogNative(value, "Decimal");

    if (value is Iterable) {
      return DogList(value.map((e) => fromNative(e)).toList());
    }
    if (value is Map) {
      return DogMap(value
          .map((key, value) => MapEntry(fromNative(key), fromNative(value))));
    }

    throw ArgumentError.value(
        value, null, "Can't coerce native value to dart object graph");
  }

  @override
  bool isNative(Type serial) {
    return serial == String ||
        serial == int ||
        serial == double ||
        serial == bool ||
        serial == DateTime ||
        serial == RegExp ||
        serial == mongo.ObjectId ||
        serial == mongo.DbRef ||
        serial == mongo.JsCode ||
        serial == mongo.Timestamp ||
        serial == Int64 ||
        serial == Decimal;
  }

  @override
  Map<Type, DogConverter> get bridgeConverters => const {
    String: NativeRetentionConverter<String>(),
    int: NativeRetentionConverter<int>(),
    double: NativeRetentionConverter<double>(),
    bool: NativeRetentionConverter<bool>(),
    DateTime: NativeRetentionConverter<DateTime>(),
    RegExp: NativeRetentionConverter<RegExp>(),
    mongo.ObjectId: NativeRetentionConverter<mongo.ObjectId>(),
    mongo.DbRef: NativeRetentionConverter<mongo.DbRef>(),
    mongo.JsCode: NativeRetentionConverter<mongo.JsCode>(),
    mongo.Timestamp: NativeRetentionConverter<mongo.Timestamp>(),
    Int64: NativeRetentionConverter<Int64>(),
    Decimal: NativeRetentionConverter<Decimal>(),
  };

}