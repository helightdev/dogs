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

/// Collection that represents a page of results.
class Page<T> with ListMixin<T> {

  /// The pagination metadata of the page.
  final PageMeta meta;

  /// The content of the page.
  final List<T> content;

  const Page(this.meta, this.content);

  /// Returns the number of the page.
  int get pageNumber => meta.number;

  /// Returns the size of the page.
  int get pageSize => meta.size;

  /// Returns the total number of elements.
  int get totalElements => meta.totalElements;

  /// Returns the total number of pages.
  int get totalPages => meta.totalPages;

  /// Returns `true` if there is a previous page.
  bool get hasPrevious => pageNumber > 0;

  /// Returns `true` if there is a next page.
  bool get hasNext => pageNumber < totalPages - 1;

  /// Returns a [PageRequest] to retrieve the next page.
  PageRequest get nextRequest => switch(hasNext) {
    true => PageRequest.of(pageNumber + 1, pageSize),
    false => PageRequest.of(pageNumber, pageSize),
  };

  /// Returns a [PageRequest] to retrieve the previous page.
  PageRequest get previousRequest => switch(hasPrevious) {
    true => PageRequest.of(pageNumber - 1, pageSize),
    false => PageRequest.of(pageNumber, pageSize),
  };

  /// Returns a [PageRequest] to retrieve the first page.
  PageRequest get firstPageRequest => PageRequest.of(0, pageSize);

  /// Returns a [PageRequest] to retrieve the last page.
  PageRequest get lastPageRequest => PageRequest.of(totalPages - 1, pageSize);

  /// Creates an empty page with no content and a size of 0.
  Page.empty()
      : meta = PageMeta(
          number: 0,
          size: 0,
          totalElements: 0,
          totalPages: 0,
        ),
        content = const [];

  /// Creates a page from the given [content] and pagination metadata.
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

/// Metadata about a page.
class PageMeta {
  /// The number of the page.
  final int number;

  /// The size of the page.
  final int size;

  /// The total number of elements.
  final int totalElements;

  /// The total number of pages.
  final int totalPages;

  PageMeta({
    required this.number,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  /// Creates a [PageMeta] from aggregation results.
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
    nargs: 1, consume: <T>() => PageNTreeArgConverter<T>());

class PageNTreeArgConverter<T> extends NTreeArgConverter<Page> {
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

class PageRequestConverter extends SimpleDogConverter<PageRequest> {
  PageRequestConverter() : super(serialName: "PageRequest");

  @override
  PageRequest deserialize(value, DogEngine engine) {
    if (value is! Map) throw DogException("Expected Map");
    return PageRequest(
      page: value["page"],
      size: value["size"],
    );
  }

  @override
  serialize(PageRequest value, DogEngine engine) {
    return <String,dynamic>{
      "page": value.page,
      "size": value.size,
    };
  }
}