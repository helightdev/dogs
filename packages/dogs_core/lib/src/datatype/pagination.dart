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

import "dart:collection";

import "package:dogs_core/dogs_core.dart";

/// Collection that represents a page of results.
class Page<T> with ListMixin<T> {
  /// The pagination metadata of the page.
  final PageMeta meta;

  /// The content of the page.
  final List<T> content;

  /// Creates a new page with the given metadata and content.
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
  PageRequest get nextRequest => switch (hasNext) {
        true => PageRequest.of(pageNumber + 1, pageSize),
        false => PageRequest.of(pageNumber, pageSize),
      };

  /// Returns a [PageRequest] to retrieve the previous page.
  PageRequest get previousRequest => switch (hasPrevious) {
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

  /// Metadata about a page.
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

/// The default page size used by [PageRequest]s.
int kDefaultPageSize = 20;

/// Simple page and size based pagination request.
class PageRequest {
  /// The number of the page.
  late final int page;

  /// The size of the page.
  late final int size;

  /// Simple page and size based pagination request.
  PageRequest({
    int? page,
    int? skip,
    int? size,
  }) {
    this.size = size ?? kDefaultPageSize;
    if (page != null) {
      this.page = page;
    } else if (skip != null) {
      this.page = (skip / this.size).floor();
    } else {
      this.page = 0;
    }
  }

  /// Creates a [PageRequest] with the given [page] and [size].
  PageRequest.of(this.page, this.size);

  /// Creates a [PageRequest] from a page query.
  /// Takes the `page` and `size` parameters from a query parameter map.
  factory PageRequest.fromPageQuery(Map<String, dynamic> query) {
    return PageRequest(
      page: query["page"],
      size: query["size"],
    );
  }

  /// Creates a [PageRequest] from a cursor query.
  /// Takes the `skip` and `limit` parameters from a query parameter map.
  factory PageRequest.fromCursorQuery(Map<String, dynamic> query) {
    return PageRequest(
      skip: query["skip"],
      size: query["limit"],
    );
  }

  /// Calculates the number of elements to skip.
  int get skip => page * size;

  /// Returns a [Map] representation of the cursor query.
  /// Contains the `skip` and `limit` parameters.
  Map<String, dynamic> get cursorQuery => {
        "skip": skip,
        "limit": size,
      };

  /// Returns a [Map] representation of the page query.
  /// Contains the `page` and `size` parameters.
  Map<String, dynamic> get pageQuery => {
        "page": page,
        "size": size,
      };
}

/// A [NTreeArgConverter] for [Page]s.
class PageNTreeArgConverter<T> extends NTreeArgConverter<Page> {
  @override
  Page deserialize(value, DogEngine engine) {
    if (value is! Map) throw ArgumentError("Expected Map");
    final meta = PageMeta(
      number: value["number"],
      size: value["size"],
      totalElements: value["totalElements"],
      totalPages: value["totalPages"],
    );
    final content = value["content"];
    if (content is! List) throw ArgumentError("Expected List");
    final result = content.map((e) => deserializeArg(e, 0, engine) as T).toList();
    return Page<T>(meta, result);
  }

  @override
  serialize(Page value, DogEngine engine) {
    return <String, dynamic>{
      "number": value.meta.number,
      "size": value.meta.size,
      "totalElements": value.meta.totalElements,
      "totalPages": value.meta.totalPages,
      "content": value.content.map((e) => serializeArg(e, 0, engine)).toList(),
    };
  }

  @override
  SchemaType inferSchemaType(DogEngine engine, SchemaConfig config) {
    return SchemaObject(
      fields: [
        SchemaField("number", SchemaType.integer),
        SchemaField("size", SchemaType.integer),
        SchemaField("totalElements", SchemaType.integer),
        SchemaField("totalPages", SchemaType.integer),
        SchemaField(
          "content",
          itemConverters[0].describeOutput(engine, config),
        ),
      ],
    );
  }

  @override
  Iterable<(dynamic, int)> traverse(dynamic value, DogEngine engine) sync* {
    if (value is Page) {
      for (var entry in value.content) {
        yield (entry, 0);
      }
    }
  }
}

/// A [DogConverter] for [PageRequest]s.
class PageRequestConverter extends SimpleDogConverter<PageRequest> {
  /// A [DogConverter] for [PageRequest]s.
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
    return <String, dynamic>{
      "page": value.page,
      "size": value.size,
    };
  }

  @override
  SchemaType describeOutput(DogEngine engine, SchemaConfig config) {
    return SchemaObject(
      fields: [
        SchemaField("page", SchemaType.integer),
        SchemaField("size", SchemaType.integer),
      ],
    );
  }
}
