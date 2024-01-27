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
import 'package:dogs_mongo_driver/dogs_mongo_driver.dart';
import 'package:fixnum/fixnum.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

void installMongoConverters([DogEngine? engine]) {
  engine ??= DogEngine.instance;
  engine.registerAutomatic(ObjectIdConverter());
  engine.registerAutomatic(TimestampConverter());
  engine.registerAutomatic(JsCodeConverter());
  engine.registerAutomatic(DbRefConverter());
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

class ObjectIdConverter extends SimpleDogConverter<mongo.ObjectId> {
  ObjectIdConverter() : super(serialName: "ObjectId");

  @override
  mongo.ObjectId deserialize(value, DogEngine engine) {
    return ObjectId.parse(value);
  }

  @override
  serialize(mongo.ObjectId value, DogEngine engine) {
    return value.oid;
  }
}

class TimestampConverter extends SimpleDogConverter<mongo.Timestamp> {
  TimestampConverter() : super(serialName: "Timestamp");

  @override
  mongo.Timestamp deserialize(value, DogEngine engine) {
    return mongo.Timestamp(value["t"], value["i"]);
  }

  @override
  serialize(mongo.Timestamp value, DogEngine engine) {
    return <String,Object?>{
      "t": value.seconds,
      "i": value.increment,
    };
  }
}

class JsCodeConverter extends SimpleDogConverter<mongo.JsCode> {
  JsCodeConverter() : super(serialName: "JsCode");

  @override
  mongo.JsCode deserialize(value, DogEngine engine) {
    return mongo.JsCode(value);
  }

  @override
  serialize(mongo.JsCode value, DogEngine engine) {
    return value.code;
  }
}

class DbRefConverter extends SimpleDogConverter<mongo.DbRef> {
  DbRefConverter() : super(serialName: "DbRef");

  @override
  mongo.DbRef deserialize(value, DogEngine engine) {
    return mongo.DbRef(value["collection"], ObjectId.parse(value["id"]), db: value["db"]);
  }

  @override
  serialize(mongo.DbRef value, DogEngine engine) {
    return <String,Object?>{
      "collection": value.collection,
      "id": (value.id as ObjectId).oid,
      "db": value.db,
    };
  }
}