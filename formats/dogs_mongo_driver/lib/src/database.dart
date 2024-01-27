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

import 'package:dogs_mongo_driver/dogs_mongo_driver.dart';
import 'package:dogs_odm/dogs_odm.dart';

class MongoDatabase<T extends Object> extends CrudDatabase<T, ObjectId>
    implements QueryableDatabase<T, ObjectId>, PageableDatabase<T, ObjectId> {
  final DbCollection collection;
  MongoOdmSystem system;

  MongoDatabase(this.system, this.collection);

  late EntityAnalysis<T, MongoDatabase, ObjectId> analysis =
      system.getAnalysis<T>();

  @override
  Future<void> clear() async {
    await collection.drop();
  }

  @override
  Future<int> count() async {
    return await collection.count();
  }

  @override
  Future<void> delete(T value) {
    var id = system.resolveId(value)!;
    return collection.remove(where.id(id));
  }

  @override
  Future<void> deleteAll(Iterable<T> values) async {
    var ids = values.map((e) => system.resolveId(e)!);
    await deleteAllById(ids);
  }

  @override
  Future<void> deleteAllById(Iterable<ObjectId> ids) async {
    for (var element in ids) {
      await deleteById(element);
    }
  }

  @override
  Future<void> deleteById(ObjectId id) async {
    await collection.remove(where.id(id));
  }

  @override
  Future<bool> existsById(ObjectId id) async {
    return await collection.count(where.id(id)) > 0;
  }

  @override
  Future<List<T>> findAll() async {
    var documents =
        collection.find().map(_toIntermediate).map(analysis.decode).toList();
    return documents;
  }

  @override
  Future<T?> findById(ObjectId id) async {
    var result = await collection.findOne(where.id(id));
    if (result == null) return null;
    return analysis.decode(_toIntermediate(result));
  }

  @override
  Future<T> save(T value) async {
    var intermediate = analysis.encode(value);
    var native = _toNative(intermediate);
    var result = await collection.replaceOne(where.id(intermediate.id!), native,
        upsert: true);
    if (result.isSuccess) {
      return analysis.decode(intermediate);
    }
    throw Exception("Failed to save entity: ${result.errmsg}");
  }

  @override
  Future<List<T>> saveAll(Iterable<T> values) async {
    return await Future.wait(values.map((e) => save(e)));
  }

  @override
  Future<int> countByQuery(Query query) async {
    var selector = _toSelector(query);
    return await collection.count(selector);
  }

  @override
  Future<void> deleteAllByQuery(Query query) async {
    var selector = _toSelector(query);
    await collection.remove(selector);
  }

  @override
  Future<void> deleteOneByQuery(Query query) async {
    query = query.copyWith(limit: 1, skip: 0);
    await deleteAllByQuery(query);
  }

  @override
  Future<bool> existsByQuery(Query query) async {
    return await countByQuery(query) > 0;
  }

  @override
  Future<List<T>> findAllByQuery(Query query, Sorted sort) async {
    var builder = _sorted(_toSelector(query), sort);
    var documents = await collection
        .find(builder)
        .map(_toIntermediate)
        .map(analysis.decode)
        .toList();
    return documents;
  }

  @override
  Future<T?> findOneByQuery(Query query, Sorted sort) async {
    query = query.copyWith(limit: 1, skip: 0);
    var result = await findAllByQuery(query, sort);
    if (result.isEmpty) return null;
    return result.first;
  }

  @override
  Future<Page<T>> findPaginatedByQuery(Query query, Sorted sort,
      {required int skip, required int limit}) async {
    var builder = _sorted(_toSelector(query), sort);
    var hasSort = builder.map.containsKey("orderby");
    var aggregationQuery = [
      <String,Object>{
        r"$match": builder.map[r"$query"] ?? {},
      },
      <String,Object>{
        r"$facet": {
          "content": [
            if (hasSort) {r"$sort": builder.map["orderby"]},
            {r"$skip": skip},
            {r"$limit": limit}
          ],
          "meta": [
            {r"$count": "count"}
          ]
        }
      }
    ];
    var data = await collection.modernAggregate(aggregationQuery).first;
    if (data.isEmpty) return Page<T>.empty();
    var metaArr = data["meta"] as List?;
    if (metaArr == null || metaArr.isEmpty) return Page<T>.empty();
    var totalElements = metaArr[0]!["count"];
    if (totalElements == null) return Page<T>.empty();
    var content = (data["content"] as List)
        .cast<Map<String, dynamic>>()
        .map(_toIntermediate)
        .map(analysis.decode)
        .toList(growable: false);
    return Page<T>.fromData(content, skip, limit, totalElements);
  }

  static Map<String, dynamic> _toNative(EntityIntermediate<ObjectId> e) {
    var map = Map<String, dynamic>.of(e.native);
    map["_id"] = e.id;
    return map;
  }

  static EntityIntermediate<ObjectId> _toIntermediate(Map<String, dynamic> e) {
    var map = Map<String, dynamic>.of(e);
    ObjectId id = map.remove("_id");
    return EntityIntermediate(id, map);
  }

  SelectorBuilder _toSelector(Query query) {
    var selector = where;
    if (query.filter != null) {
      selector = MongoFilterParser.parse(query.filter!, system);
    }
    if (query.limit != null) {
      selector = selector.limit(query.limit!);
    }
    if (query.skip != null) {
      selector = selector.skip(query.skip!);
    }
    return selector;
  }

  static SelectorBuilder _sorted(SelectorBuilder builder, Sorted? sort) {
    if (sort?.sort != null) {
      var expr = sort!.sort!;
      if (expr is SortCombine) {
        for (var sort in expr.sorts) {
          if (sort is SortScalar) {
            builder = builder.sortBy(sort.field, descending: sort.descending);
          } else {
            throw Exception("Mongodb doesn't support grouped sorting.");
          }
        }
      } else if (expr is SortScalar) {
        builder = builder.sortBy(expr.field, descending: expr.descending);
      }
    }
    return builder;
  }
}
