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

import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_odm/dogs_odm.dart';
import 'package:dogs_odm/memory_db.dart';

class MemoryDatabase<T extends Object> extends CrudDatabase<T, String>
    implements QueryableDatabase<T, String>, PageableDatabase<T, String> {
  final LinkedHashMap<String, Map<String, dynamic>> _data =
      LinkedHashMap<String, Map<String, dynamic>>();
  MemoryOdmSystem system;

  MemoryDatabase(this.system);

  late EntityAnalysis<T, MemoryDatabase, String> analysis =
      system.getAnalysis<T>();

  String createJsonDump() {
    return jsonEncode(_data);
  }

  void loadJsonDump(String json) {
    _data.clear();
    var data = jsonDecode(json) as Map<String, dynamic>;
    _data.addAll(data.map((key, value) => MapEntry(key, value as Map<String, dynamic>)));
  }

  @override
  Future<void> clear() {
    _data.clear();
    return Future.value();
  }

  @override
  Future<int> count() {
    return Future.value(_data.length);
  }

  @override
  Future<void> delete(T value) {
    var id = system.resolveId(value);
    _data.remove(id);
    return Future.value();
  }

  @override
  Future<void> deleteAll(Iterable<T> values) async {
    await Future.wait(values.map((e) => delete(e)));
  }

  @override
  Future<void> deleteAllById(Iterable<String> ids) async {
    await Future.wait(ids.map((e) => deleteById(e)));
  }

  @override
  Future<void> deleteById(String id) {
    _data.remove(id);
    return Future.value();
  }

  @override
  Future<bool> existsById(String id) {
    return Future.value(_data.containsKey(id));
  }

  @override
  Future<List<T>> findAll() {
    var values = _data.entries
        .map((e) => EntityIntermediate(e.key, e.value))
        .map((e) => analysis.decode(e))
        .toList();
    return Future.value(values);
  }

  @override
  Future<T?> findById(String id) {
    if (!_data.containsKey(id)) {
      return Future.value(null);
    }
    var value = _data[id]!;
    return Future.value(analysis.decode(EntityIntermediate(id, value)));
  }

  @override
  Future<T> save(T value) {
    var intermediate = analysis.encode(value);
    _data[intermediate.id!] = intermediate.native;
    return Future.value(analysis.decode(intermediate));
  }

  @override
  Future<List<T>> saveAll(Iterable<T> values) async {
    return await Future.wait(values.map((e) => save(e)));
  }

  @override
  Future<int> countByQuery(Query query) async {
    var values = _data.entries
        .where((element) =>
            MapMatcher.evaluate(query.filter, element.value, system))
        .map((e) => EntityIntermediate(e.key, e.value))
        .map((e) => analysis.decode(e));
    return Future.value(values.length);
  }

  @override
  Future<void> deleteAllByQuery(Query query) async {
    var values = _data.entries
        .where((element) =>
            MapMatcher.evaluate(query.filter, element.value, system))
        .map((e) => EntityIntermediate(e.key, e.value))
        .map((e) => analysis.decode(e));
    await Future.wait(values.map((e) => delete(e)));
  }

  @override
  Future<void> deleteOneByQuery(Query query) {
    var values = _data.entries
        .where((element) =>
            MapMatcher.evaluate(query.filter, element.value, system))
        .map((e) => EntityIntermediate(e.key, e.value))
        .map((e) => analysis.decode(e));
    return delete(values.first);
  }

  @override
  Future<bool> existsByQuery(Query query) {
    var values = _data.entries
        .where((element) =>
            MapMatcher.evaluate(query.filter, element.value, system))
        .map((e) => EntityIntermediate(e.key, e.value))
        .map((e) => analysis.decode(e));
    return Future.value(values.isNotEmpty);
  }

  @override
  Future<List<T>> findAllByQuery(Query query, Sorted sort) {
    var comparator = MapSorting.parse(sort.sort);
    var values = _data.entries
        .where((element) =>
            MapMatcher.evaluate(query.filter, element.value, system))
        .sorted((a, b) => comparator.compare(a.value, b.value))
        .map((e) => EntityIntermediate(e.key, e.value))
        .map((e) => analysis.decode(e));
    return Future.value(values.toList());
  }

  @override
  Future<T?> findOneByQuery(Query query, Sorted sort) {
    var comparator = MapSorting.parse(sort.sort);
    var values = _data.entries
        .where((element) =>
            MapMatcher.evaluate(query.filter, element.value, system))
        .sorted((a, b) => comparator.compare(a.value, b.value))
        .map((e) => EntityIntermediate(e.key, e.value))
        .map((e) => analysis.decode(e));
    return Future.value(values.firstOrNull);
  }

  @override
  Future<Page<T>> findPaginatedByQuery(Query query, Sorted sort,
      {required int skip, required int limit}) {
    var comparator = MapSorting.parse(sort.sort);
    var totalElements = 0;
    var values = _data.entries
        .where((element) =>
            MapMatcher.evaluate(query.filter, element.value, system))
        .sorted((a, b) => comparator.compare(a.value, b.value))
        .map((e) {
          totalElements++;
          return e;
        })
        .toList() // Get all so the totalElements can be calculated
        .skip(skip)
        .take(limit)
        .map((e) => EntityIntermediate(e.key, e.value))
        .map((e) => analysis.decode(e))
        .toList();

    var page = Page<T>.fromData(values, skip, limit, totalElements);
    return Future.value(page);
  }
}
