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

/// A repository for a specific entity type.
abstract class Repository<T extends Object, ID extends Object> {
  const Repository();

  /// Returns the entity with the given [id] or `null` if none was found.
  Future<T?> findById(ID id);

  /// Returns all entities.
  Future<List<T>> findAll();

  /// Returns `true` if an entity with the given [id] exists.
  Future<bool> existsById(ID id);

  /// Returns the number of entities.
  Future<int> count();

  /// Saves the given [value] to the database using an upsert operation.
  Future<T> save(T value);

  /// Saves all [values] to the database using an upsert operation.
  Future<List<T>> saveAll(Iterable<T> values);

  /// Deletes the entity with the given [id].
  Future<void> deleteById(ID id);

  /// Deletes the given [value].
  Future<void> delete(T value);

  /// Deletes all entities with the given [ids].
  Future<void> deleteAllById(Iterable<ID> ids);

  /// Deletes all [values].
  Future<void> deleteAll(Iterable<T> values);

  /// Deletes all entities.
  Future<void> clear();
}

/// Adds query support to a [Repository].
abstract class QueryableRepository<T extends Object, ID extends Object> {

  /// Returns all entities that match the given [query] sorted by the given
  Future<List<T>> findAllByQuery(QueryLike query,
      [Sorted sort = const Sorted.empty()]);

  /// Returns the first entity that matches the given [query] sorted by the
  Future<T?> findOneByQuery(QueryLike query,
      [Sorted sort = const Sorted.empty()]);

  /// Returns the number of entities that match the given [query].
  Future<int> countByQuery(QueryLike query);

  /// Returns `true` if an entity that matches the given [query] exists.
  Future<bool> existsByQuery(QueryLike query);

  /// Deletes the first entity that matches the given [query].
  Future<void> deleteOneByQuery(QueryLike query);

  /// Deletes all entities that match the given [query].
  Future<void> deleteAllByQuery(QueryLike query);
}

/// Adds pagination support to a [QueryableRepository].
abstract class PageableRepository<ENTITY extends Object, ID extends Object> {

  /// Returns a page of all entities for the given [request].
  Future<Page<ENTITY>> findPaginated(PageRequest request);

  /// Returns a page of all entities that match the [query] for the given
  /// [request] sorted by [sort] if specified.
  Future<Page<ENTITY>> findPaginatedByQuery(
      QueryLike query, PageRequest request,
      [Sorted sort]);
}

/// Reference Hub for a [Repository] that is meant to be mixed in using [RepositoryMixin].
abstract class DatabaseReferences<
    ENTITY extends Object,
    ID extends Object,
    SYS extends OdmSystem,
    SYS_DB_BASE extends CrudDatabase,
    SYS_DB extends CrudDatabase<ENTITY, SYS_ID>,
    SYS_ID extends Object> {

  /// Returns the backing system of this repository.
  OdmSystem<SYS_DB_BASE, SYS_ID> get system;

  /// Returns the backing database of this repository.
  SYS_DB get database;
}

//<editor-fold desc="Mixins">
mixin RepositoryMixin<
        ENTITY extends Object,
        ID extends Object,
        SYS extends OdmSystem,
        SYS_DB_BASE extends CrudDatabase,
        SYS_DB extends CrudDatabase<ENTITY, SYS_ID>,
        SYS_ID extends Object> on Repository<ENTITY, ID>
    implements
        DatabaseReferences<ENTITY, ID, SYS, SYS_DB_BASE, SYS_DB, SYS_ID> {
  SYS_DB? _cachedDatabase;
  OdmSystem<SYS_DB_BASE, SYS_ID>? _cachedSystem;

  @override
  OdmSystem<SYS_DB_BASE, SYS_ID> get system {
    _cachedSystem ??= OdmSystem.get<SYS>() as OdmSystem<SYS_DB_BASE, SYS_ID>;
    return _cachedSystem!;
  }

  @override
  SYS_DB get database {
    _cachedDatabase ??= system.getDatabase<ENTITY>(this) as SYS_DB;
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

mixin QueryableRepositoryMixin<
        T extends Object,
        ID extends Object,
        SYS extends OdmSystem,
        SYS_DB_BASE extends QueryableDatabase,
        SYS_DB extends QueryableDatabase<T, SYS_ID>,
        SYS_ID extends Object>
    on DatabaseReferences<T, ID, SYS, SYS_DB_BASE, SYS_DB, SYS_ID>
    implements QueryableRepository<T, ID> {
  @override
  Future<List<T>> findAllByQuery(QueryLike query,
      [Sorted sort = const Sorted.empty()]) {
    return database.findAllByQuery(query.asQuery, sort);
  }

  @override
  Future<T?> findOneByQuery(QueryLike query,
      [Sorted sort = const Sorted.empty()]) {
    return database.findOneByQuery(query.asQuery, sort);
  }

  @override
  Future<int> countByQuery(QueryLike query) {
    return database.countByQuery(query.asQuery);
  }

  @override
  Future<bool> existsByQuery(QueryLike query) {
    return database.existsByQuery(query.asQuery);
  }

  @override
  Future<void> deleteOneByQuery(QueryLike query) {
    return database.deleteOneByQuery(query.asQuery);
  }

  @override
  Future<void> deleteAllByQuery(QueryLike query) {
    return database.deleteAllByQuery(query.asQuery);
  }
}

mixin PageableRepositoryMixin<
        ENTITY extends Object,
        ID extends Object,
        SYS extends OdmSystem,
        SYS_DB_BASE extends PageableDatabase,
        SYS_DB extends PageableDatabase<ENTITY, SYS_ID>,
        SYS_ID extends Object>
    on DatabaseReferences<ENTITY, ID, SYS, SYS_DB_BASE, SYS_DB, SYS_ID>
    implements PageableRepository<ENTITY, ID> {
  @override
  Future<Page<ENTITY>> findPaginated(PageRequest request) {
    return database.findPaginatedByQuery(Query.empty(), Sorted.empty(),
        skip: request.skip, limit: request.size);
  }

  @override
  Future<Page<ENTITY>> findPaginatedByQuery(
      QueryLike query, PageRequest request,
      [Sorted sort = const Sorted.empty()]) {
    return database.findPaginatedByQuery(query.asQuery, sort,
        skip: request.skip, limit: request.size);
  }
}
//</editor-fold>
