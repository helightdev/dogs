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
import 'package:dogs_odm/dogs_odm.dart';

import '../query_dsl.dart';

abstract class QueryableRepository<T extends Object, ID extends Object> {
  Future<List<T>> findAllByQuery(QueryLike query,
      [Sorted sort = const Sorted.empty()]);

  Future<T?> findOneByQuery(QueryLike query,
      [Sorted sort = const Sorted.empty()]);

  Future<int> countByQuery(QueryLike query);

  Future<bool> existsByQuery(QueryLike query);

  Future<void> deleteOneByQuery(QueryLike query);

  Future<void> deleteAllByQuery(QueryLike query);
}

mixin QueryableRepositoryMixin<
        T extends Object,
        ID extends Object,
        SYS extends OdmSystem,
        SYS_DB_BASE extends QueryableDatabase,
        SYS_DB extends QueryableDatabase<T, SYS_ID>,
        SYS_ID extends Object> on DatabaseReferences<T, ID, SYS, SYS_DB_BASE, SYS_DB, SYS_ID>
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

abstract class QueryableDatabase<T extends Object, ID extends Object>
    implements CrudDatabase<T, ID> {
  Future<List<T>> findAllByQuery(Query query, Sorted sort);

  Future<T?> findOneByQuery(Query query, Sorted sort);

  Future<int> countByQuery(Query query);

  Future<bool> existsByQuery(Query query);

  Future<void> deleteOneByQuery(Query query);

  Future<void> deleteAllByQuery(Query query);
}

//<editor-fold desc="Sorting">
class Sorted {
  final SortExpr? sort;

  const Sorted({this.sort});

  const Sorted.empty() : this(sort: null);

  factory Sorted.byField(String field, {bool ascending = true}) {
    return Sorted(sort: SortScalar(field, ascending));
  }

  factory Sorted.byFields(List<String> fields,
      {List<bool>? ascending, defaultAscending = true}) {
    ascending ??= List.filled(fields.length, defaultAscending);
    if (fields.length != ascending.length)
      throw Exception("Fields and ascending must have the same length.");
    var sorts = <SortExpr>[];
    for (var i = 0; i < fields.length; i++) {
      sorts.add(SortScalar(fields[i], ascending[i]));
    }
    return Sorted(sort: SortCombine(sorts));
  }
}

sealed class SortExpr {
  const SortExpr();
}

class SortScalar extends SortExpr {
  final String field;
  final bool ascending;

  const SortScalar(this.field, this.ascending);
}

class SortCombine extends SortExpr {
  final List<SortExpr> sorts;

  const SortCombine(this.sorts);
}
//</editor-fold>

class Query extends QueryLike {
  final int? limit;
  final int? skip;
  final FilterExpr? filter;

  const Query(this.filter, {this.limit, this.skip});

  const Query.empty() : this(null);

  const Query.cursor(int limit, int skip)
      : this(null, limit: limit, skip: skip);

  Query copyWith({
    int? limit,
    int? skip,
    FilterExpr? filter,
  }) {
    return Query(
      filter ?? this.filter,
      limit: limit ?? this.limit,
      skip: skip ?? this.skip,
    );
  }

  @override
  Query get asQuery => this;
}

sealed class QueryLike {
  const QueryLike();

  Query get asQuery;
}

sealed class FilterExpr extends QueryLike {
  const FilterExpr();

  operator &(FilterExpr other) => this.and(other);

  operator |(FilterExpr other) => this.or(other);

  @override
  Query get asQuery => Query(this);
}

class FilterEqStruct<T> extends FilterExpr with TypeCaptureMixin<T> {
  final String field;
  final T? value;

  const FilterEqStruct(this.field, this.value);

  @override
  String toString() {
    return "$field == $value";
  }
}

class FilterEq extends FilterExpr {
  final String field;
  final Object? value;

  const FilterEq(this.field, this.value);

  @override
  String toString() {
    return "$field == $value";
  }
}

class FilterNe extends FilterExpr {
  final String field;
  final Object? value;

  const FilterNe(this.field, this.value);

  @override
  String toString() {
    return "$field != $value";
  }
}

class FilterNeStruct<T> extends FilterExpr with TypeCaptureMixin<T> {
  final String field;
  final T? value;

  const FilterNeStruct(this.field, this.value);

  @override
  String toString() {
    return "$field != $value";
  }
}

class FilterLt extends FilterExpr {
  final String field;
  final Object? value;

  const FilterLt(this.field, this.value);

  @override
  String toString() {
    return "$field < $value";
  }
}

class FilterGt extends FilterExpr {
  final String field;
  final Object? value;

  const FilterGt(this.field, this.value);

  @override
  String toString() {
    return "$field > $value";
  }
}

class FilterLte extends FilterExpr {
  final String field;
  final Object? value;

  const FilterLte(this.field, this.value);

  @override
  String toString() {
    return "$field <= $value";
  }
}

class FilterGte extends FilterExpr {
  final String field;
  final Object? value;

  const FilterGte(this.field, this.value);

  @override
  String toString() {
    return "$field >= $value";
  }
}

class FilterExists extends FilterExpr {
  final String field;
  final bool value;

  const FilterExists(this.field, this.value);

  @override
  String toString() {
    return "$field != unset";
  }
}

class FilterAnd extends FilterExpr {
  final List<FilterExpr> filters;

  const FilterAnd(this.filters);

  @override
  String toString() {
    return filters.map((e) => "($e)").join(" && ");
  }
}

class FilterOr extends FilterExpr {
  final List<FilterExpr> filters;

  const FilterOr(this.filters);

  @override
  String toString() {
    return filters.map((e) => "($e)").join(" || ");
  }
}

class FilterIn extends FilterExpr {
  final String field;
  final List<Object?> values;

  const FilterIn(this.field, this.values);

  @override
  String toString() {
    return "$field in $values";
  }
}

class FilterNotIn extends FilterExpr {
  final String field;
  final List<Object?> values;

  const FilterNotIn(this.field, this.values);

  @override
  String toString() {
    return "$field notIn $values";
  }
}

class FilterNative extends FilterExpr {
  final Object obj;

  const FilterNative(this.obj);
}

sealed class ArrayFilterExpr extends FilterExpr {
  const ArrayFilterExpr();
}

class FilterArrayContains extends ArrayFilterExpr {
  final String field;
  final Object? value;

  const FilterArrayContains(this.field, this.value);

  @override
  String toString() {
    return "$field contains $value";
  }
}

class FilterMatcherArrayAny extends FilterExpr {
  final String field;
  final FilterExpr filter;

  const FilterMatcherArrayAny(this.field, this.filter);

  @override
  String toString() {
    return "$field any $filter";
  }
}
