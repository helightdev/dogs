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

FilterExpr eq<STRUCT>(String field, dynamic value) {
  if (STRUCT == dynamic) return FilterEq(field, value);
  return FilterEqStruct<STRUCT>(field, value);
}

FilterExpr ne<STRUCT>(String field, dynamic value) {
  if (STRUCT == dynamic) return FilterNe(field, value);
  return FilterNeStruct<STRUCT>(field, value);
}

FilterExpr lt(String field, dynamic value) {
  return FilterLt(field, value);
}

FilterExpr gt(String field, dynamic value) {
  return FilterGt(field, value);
}

FilterExpr lte(String field, dynamic value) {
  return FilterLte(field, value);
}

FilterExpr gte(String field, dynamic value) {
  return FilterGte(field, value);
}

FilterExpr exists(String field, {bool value = true}) {
  return FilterExists(field, value);
}

FilterExpr all(String field, List<dynamic> values) {
  return FilterAll(field, values);
}

FilterExpr and(List<FilterExpr> filters) {
  return FilterAnd(filters);
}

FilterExpr or(List<FilterExpr> filters) {
  return FilterOr(filters);
}

FilterExpr any(String field, FilterExpr filter) {
  return FilterAny(field, filter);
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