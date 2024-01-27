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

library query_dsl;

import 'dogs_odm.dart';

/// Matches if the [field] is equal to the given [value].
/// If [STRUCT] is specified, the [value] is expected to be a [STRUCT] instance
/// and is automatically converted to a [Map].
FilterExpr eq<STRUCT>(String field, dynamic value) {
  if (STRUCT == dynamic) return FilterEq(field, value);
  return FilterEqStruct<STRUCT>(field, value);
}

/// Matches if the [field] is not equal to the given [value].
/// If [STRUCT] is specified, the [value] is expected to be a [STRUCT] instance
/// and is automatically converted to a [Map].
FilterExpr ne<STRUCT>(String field, dynamic value) {
  if (STRUCT == dynamic) return FilterNe(field, value);
  return FilterNeStruct<STRUCT>(field, value);
}

/// Matches if the [field] is less than the given [value].
FilterExpr lt(String field, dynamic value) {
  return FilterLt(field, value);
}

/// Matches if the [field] is greater than the given [value].
FilterExpr gt(String field, dynamic value) {
  return FilterGt(field, value);
}

/// Matches if the [field] is less than or equal to the given [value].
FilterExpr lte(String field, dynamic value) {
  return FilterLte(field, value);
}

/// Matches if the [field] is greater than or equal to the given [value].
FilterExpr gte(String field, dynamic value) {
  return FilterGte(field, value);
}

/// Matches if the [field]'s existence matches the given [value].
FilterExpr exists(String field, {bool value = true}) {
  return FilterExists(field, value);
}

/// Matches if all of the given [filters] match.
FilterExpr and(List<FilterExpr> filters) {
  return FilterAnd(filters);
}

/// Matches if any of the given [filters] match.
FilterExpr or(List<FilterExpr> filters) {
  return FilterOr(filters);
}

/// Matches if the [field] contains any of the given values.
FilterExpr inArray(String field, List<dynamic> values) {
  return FilterIn(field, values);
}

/// Matches if the [field] does not contain any of the given values.
FilterExpr notInArray(String field, List<dynamic> values) {
  return FilterNotIn(field, values);
}

/// Matches if the [field] contains exactly the given value.
FilterExpr arrayContains(String field, dynamic value) {
  return FilterArrayContains(field, value);
}

FilterExpr nativeFilter(Object obj) {
  return FilterNative(obj);
}

extension FilterExprExtension on FilterExpr {
  FilterExpr and(FilterExpr other) {
    if (this is FilterAnd) {
      var and = this as FilterAnd;
      return FilterAnd([...and.filters, other]);
    }
    return FilterAnd([this, other]);
  }

  FilterExpr or(FilterExpr other) {
    if (this is FilterOr) {
      var or = this as FilterOr;
      return FilterOr([...or.filters, other]);
    }
    return FilterOr([this, other]);
  }
}