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

import 'package:dogs_odm/dogs_odm.dart';

abstract class Repository<T extends Object, ID extends Object> {
  const Repository();

  Future<T?> findById(ID id);

  Future<List<T>> findAll();

  Future<bool> existsById(ID id);

  Future<int> count();

  Future<T> save(T value);

  Future<List<T>> saveAll(Iterable<T> values);

  Future<void> deleteById(ID id);

  Future<void> delete(T value);

  Future<void> deleteAllById(Iterable<ID> ids);

  Future<void> deleteAll(Iterable<T> values);

  Future<void> clear();
}

abstract class DatabaseReferences<
    ENTITY extends Object,
    ID extends Object,
    SYS extends OdmSystem,
    SYS_DB_BASE extends CrudDatabase,
    SYS_DB extends CrudDatabase<ENTITY, SYS_ID>,
    SYS_ID extends Object> {
  OdmSystem<SYS_DB_BASE, SYS_ID> get system;

  SYS_DB get database;
}

mixin RepositoryMixin<
        ENTITY extends Object,
        ID extends Object,
        SYS extends OdmSystem,
        SYS_DB_BASE extends CrudDatabase,
        SYS_DB extends CrudDatabase<ENTITY, SYS_ID>,
        SYS_ID extends Object> on Repository<ENTITY, ID>
    implements DatabaseReferences<ENTITY, ID, SYS, SYS_DB_BASE, SYS_DB, SYS_ID> {
  SYS_DB? _cachedDatabase;
  OdmSystem<SYS_DB_BASE, SYS_ID>? _cachedSystem;

  @override
  OdmSystem<SYS_DB_BASE, SYS_ID> get system {
    _cachedSystem ??= OdmSystem.get<SYS>() as OdmSystem<SYS_DB_BASE, SYS_ID>;
    return _cachedSystem!;
  }

  @override
  SYS_DB get database {
    _cachedDatabase ??= system.getDatabase<ENTITY>() as SYS_DB;
    return _cachedDatabase!;
  }

  @override
  Future<ENTITY?> findById(ID id) {
    var actualId = system.transformId(id)!;
    return database.findById(actualId);
  }

  @override
  Future<List<ENTITY>> findAll() {
    return database.findAll();
  }

  @override
  Future<bool> existsById(ID id) {
    var actualId = system.transformId(id)!;
    return Future.value(database.existsById(actualId));
  }

  @override
  Future<int> count() {
    return database.count();
  }

  @override
  Future<ENTITY> save(ENTITY value) {
    return database.save(value);
  }

  @override
  Future<List<ENTITY>> saveAll(Iterable<ENTITY> values) {
    return database.saveAll(values);
  }

  @override
  Future<void> deleteById(ID id) {
    var actualId = system.transformId(id)!;
    return database.deleteById(actualId);
  }

  @override
  Future<void> delete(ENTITY value) {
    return database.delete(value);
  }

  @override
  Future<void> deleteAllById(Iterable<ID> ids) {
    return database.deleteAllById(ids.map(system.transformId).nonNulls);
  }

  @override
  Future<void> deleteAll(Iterable<ENTITY> values) {
    return database.deleteAll(values);
  }

  @override
  Future<void> clear() {
    return database.clear();
  }
}
