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

import 'dart:math';

import 'package:dogs_mongo_driver/dogs_mongo_driver.dart';
import 'package:dogs_odm/dogs_odm.dart';

class MongoFilterParser {
  MongoFilterParser._();

  static SelectorBuilder parse(FilterExpr expr, MongoOdmSystem system, {bool extractQuery = false}) {
    var builder = _parse(expr, system);
    if (extractQuery) builder.map = builder.map[r"$query"];
    return builder;
  }

  static SelectorBuilder _parse(FilterExpr expr, MongoOdmSystem system) {
    switch (expr) {
      case FilterNative():
        return expr.obj as SelectorBuilder;
      case FilterAnd():
        var matchers =
            expr.filters.map((e) => MongoFilterParser.parse(e, system)).toList();
        if (matchers.isEmpty) return where.raw({});
        if (matchers.length == 1) return matchers.first;
        return matchers.skip(1).fold(matchers.first, (previousValue, element) {
          return previousValue.and(element);
        });
      case FilterOr():
        var matchers =
            expr.filters.map((e) => MongoFilterParser.parse(e, system)).toList();
        if (matchers.isEmpty) return where.raw({});
        if (matchers.length == 1) return matchers.first;
        return matchers.skip(1).fold(matchers.first, (previousValue, element) {
          return previousValue.or(element);
        });
      case FilterExists():
        if (expr.value == true) return where.exists(expr.field);
        return where.notExists(expr.field);
      case FilterArrayContains():
        return where.all(expr.field, [expr.value]);
      case FilterIn():
        return where.oneFrom(expr.field, expr.values);
      case FilterNotIn():
        return where.nin(expr.field, expr.values);
      case FilterEqStruct():
        var document = system.serializeObject(expr.value, expr.typeArgument);
        return where.eq(expr.field, document);
      case FilterNeStruct():
        var document = system.serializeObject(expr.value, expr.typeArgument);
        return where.ne(expr.field, document);
      case FilterEq():
        return where.eq(expr.field, expr.value);
      case FilterNe():
        return where.ne(expr.field, expr.value);
      case FilterLt():
        return where.lt(expr.field, expr.value);
      case FilterGt():
        return where.gt(expr.field, expr.value);
      case FilterLte():
        return where.lte(expr.field, expr.value);
      case FilterGte():
        return where.gte(expr.field, expr.value);
    }
  }
}
