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

import 'package:dogs_core/dogs_core.dart';

import '../dogs_odm.dart';

class Page<T> with ListMixin<T> {
  final PageMeta meta;
  final List<T> content;

  const Page(this.meta, this.content);
  
  int get pageNumber => meta.number;
  int get pageSize => meta.size;
  int get totalElements => meta.totalElements;
  int get totalPages => meta.totalPages;

  Page.empty()
      : meta = PageMeta(
          number: 0,
          size: 0,
          totalElements: 0,
          totalPages: 0,
        ),
        content = const [];

  Page.fromData(this.content, int skip, int limit, int totalElements)
      : meta = PageMeta.fromData(skip, limit, totalElements);

  @override
  T operator [](int index) {
    return content[index];
  }

  @override
  void operator []=(int index, T value) {
    throw UnsupportedError("Page is immutable");
  }

  @override
  int get length => content.length;

  @override
  set length(int newLength) => throw UnsupportedError("Page is immutable");
}

class PageMeta {
  final int number;
  final int size;
  final int totalElements;
  final int totalPages;

  PageMeta({
    required this.number,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory PageMeta.fromData(int skip, int limit, int totalElements) {
    return PageMeta(
      number: (skip / limit).floor(),
      size: limit,
      totalElements: totalElements,
      totalPages: (totalElements / limit).ceil(),
    );
  }
}

class PageRequest {
  final int page;
  final int size;

  const PageRequest({
    this.page = 0,
    this.size = 20,
  });

  const PageRequest.of(this.page, this.size);

  int get skip => page * size;
}

final pageBaseFactory = TreeBaseConverterFactory.createNargsFactory(
    nargs: 1, consume: <T>() => PageConverter<T>());

class PageConverter<T> extends NTreeArgConverter<Page> {
  @override
  Page deserialize(value, DogEngine engine) {
    if (value is! Map) throw ArgumentError("Expected Map");
    var meta = PageMeta(
      number: value["number"],
      size: value["size"],
      totalElements: value["totalElements"],
      totalPages: value["totalPages"],
    );
    var content = value["content"];
    if (content is! List) throw ArgumentError("Expected List");
    var result = content.map((e) => deserializeArg(e, 0, engine) as T).toList();
    return Page<T>(meta, result);
  }

  @override
  serialize(Page value, DogEngine engine) {
    var map = <String, dynamic>{
      "number": value.meta.number,
      "size": value.meta.size,
      "totalElements": value.meta.totalElements,
      "totalPages": value.meta.totalPages,
      "content": value.content.map((e) => serializeArg(e, 0, engine)).toList(),
    };
  }
}

abstract class PageableDatabase<ENTITY extends Object, ID extends Object>
    implements CrudDatabase<ENTITY, ID> {
  Future<Page<ENTITY>> findPaginatedByQuery(Query query, Sorted sort,
      {required int skip, required int limit});
}

abstract class PageableRepository<ENTITY extends Object, ID extends Object> {
  Future<Page<ENTITY>> findPaginated(PageRequest request);

  Future<Page<ENTITY>> findPaginatedByQuery(
      QueryLike query, PageRequest request,
      [Sorted sort]);
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
