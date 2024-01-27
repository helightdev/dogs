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

import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_mongo_driver/dogs_mongo_driver.dart';
import 'package:dogs_odm/dogs_odm.dart';
import 'dart:core';
import 'dart:core' as core;

class MongoOdmSystem extends OdmSystem<MongoDatabase, ObjectId> {

  final Map<core.Type, MongoDatabase> _databases = <core.Type, MongoDatabase>{};

  final Db db;

  MongoOdmSystem._(this.db);

  MongoDatabase<T> getMongoDatabase<T extends Object>(String? collectionName) {
    collectionName ??= engine.findStructureByType(T)!.serialName;
    return MongoDatabase<T>(this,db.collection(collectionName));
  }

  @override
  MongoDatabase<T> getDatabase<T extends Object>([Repository? repository]) {
    var collectionName = repository is MongoRepository ? repository.collectionName : null;
    return _databases.putIfAbsent(T, () => getMongoDatabase<T>(collectionName)) as MongoDatabase<T>;
  }

  @override
  DogEngine engine = DogEngine.instance.fork(
    codec: MongoDbCodec()
  );

  @override
  ObjectId generateId<T extends Object>(T entity) {
    return ObjectId();
  }

  @override
  ObjectId? transformId<FOREIGN>(FOREIGN? id) {
    switch (id) {
      case null:
        return null;
      case String():
        return ObjectId.fromHexString(id);
      case ObjectId():
        return id;
      default:
        throw Exception('Unsupported type: ${id.runtimeType}');
    }
  }

  @override
  FOREIGN inverseTransformId<FOREIGN>(ObjectId id) {
    switch (FOREIGN) {
      case const (String):
        return id.oid as FOREIGN;
      case const (ObjectId):
        return id as FOREIGN;
      default:
        throw Exception('Unsupported type: $FOREIGN');
    }
  }

  static Future<MongoOdmSystem> connect(String uri) async {
    var db = await Db.create(uri);
    await db.open();
    var system = MongoOdmSystem._(db);
    OdmSystem.register(system);
    return system;
  }

  static MongoOdmSystem fromDb(Db db) {
    var system = MongoOdmSystem._(db);
    OdmSystem.register(system);
    return system;
  }
}