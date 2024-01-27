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

import '../dogs_odm.dart';

abstract class CrudDatabase<ENTITY extends Object, ID extends Object> {
  const CrudDatabase();

  /// Returns the entity with the given [id] from the database.
  Future<ENTITY?> findById(ID id);

  /// Returns all entities in the database.
  Future<List<ENTITY>> findAll();

  /// Returns `true` if an entity with the given [id] exists in the database.
  Future<bool> existsById(ID id);

  /// Returns the number of entities in the database.
  Future<int> count();

  /// Saves the given [value] to the database using an upsert operation.
  Future<ENTITY> save(ENTITY value);

  /// Saves all [values] to the database using an upsert operation.
  Future<List<ENTITY>> saveAll(Iterable<ENTITY> values);

  /// Deletes the entity with the given [id] from the database.
  Future<void> deleteById(ID id);

  /// Deletes the given [value] from the database.
  Future<void> delete(ENTITY value);

  /// Deletes all entities with the given [ids] from the database.
  Future<void> deleteAllById(Iterable<ID> ids);

  /// Deletes all [values] from the database.
  Future<void> deleteAll(Iterable<ENTITY> values);

  /// Deletes all entities from the database.
  Future<void> clear();
}

/// Adds query support to a [CrudDatabase].
abstract class QueryableDatabase<T extends Object, ID extends Object>
    implements CrudDatabase<T, ID> {

  /// Returns all entities that match the given [query] sorted by the given
  Future<List<T>> findAllByQuery(Query query, Sorted sort);

  /// Returns the first entity that matches the given [query].
  Future<T?> findOneByQuery(Query query, Sorted sort);

  /// Returns the number of entities that match the given [query].
  Future<int> countByQuery(Query query);

  /// Returns `true` if any entity exists that matches the given [query].
  Future<bool> existsByQuery(Query query);

  /// Deletes the first entity that matches the given [query].
  /// [Query.limit] and [Query.skip] are ignored.
  Future<void> deleteOneByQuery(Query query);

  /// Deletes all entities that match the given [query].
  Future<void> deleteAllByQuery(Query query);
}


/// Adds pagination support to a [QueryableDatabase].
abstract class PageableDatabase<ENTITY extends Object, ID extends Object>
    implements QueryableDatabase<ENTITY, ID> {

  /// Retrieves a page of entities from the database that match the given [query]
  /// sorted by the given [sort]. [skip] and [limit] are used to determine the
  /// offset and size of the page.
  ///
  /// Returns a [Future] that completes with a [Page] of entities.
  Future<Page<ENTITY>> findPaginatedByQuery(Query query, Sorted sort,
      {required int skip, required int limit});
}