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

import 'dart:core';

import 'package:collection/collection.dart';
import 'package:dogs_odm/dogs_odm.dart';

class MapSorting {

  static List<Map<String, dynamic>> sort(List<Map<String, dynamic>> items, SortExpr sort) {
    var comparator = parse(sort);
    return items.sorted(comparator.compare);
  }

  static MapComparator parse(SortExpr? expr) {
    switch (expr) {
      case null:
        return _NoSort();
      case SortScalar():
        return _SortScalar(expr.field, expr.descending);
      case SortCombine():
        return _SortCombine(expr.sorts.map((e) => parse(e)).toList());
    }
  }

  static ({bool exists, dynamic value}) traverse(Map map, String key) {
    var subPaths = key.split(".");
    dynamic value = map;
    for (var path in subPaths) {
      if (value is! Map) return (exists: false, value: null);
      if (!value.containsKey(path)) return (exists: false, value: null);
      value = value[path];
    }
    return (exists: true, value: value);
  }
}

abstract class MapComparator {
  int compare(Map<String, dynamic> a, Map<String, dynamic> b);
}

class _NoSort implements MapComparator {
  @override
  int compare(Map<String, dynamic> a, Map<String, dynamic> b) {
    return 0;
  }
}

class _SortScalar implements MapComparator {
  final String field;
  final bool descending;

  _SortScalar(this.field, this.descending);

  @override
  int compare(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (!descending) return compareInternal(a, b);
    return compareInternal(b, a);
  }

  int compareInternal(Map<String, dynamic> a, Map<String, dynamic> b) {
    var aValue = MapSorting.traverse(a, field);
    var bValue = MapSorting.traverse(b, field);
    if (!aValue.exists && !bValue.exists) return 0;
    if (!aValue.exists) return 1;
    if (!bValue.exists) return -1;
    return aValue.value.compareTo(bValue.value);
  }
}

class _SortCombine implements MapComparator {
  final List<MapComparator> sorts;

  _SortCombine(this.sorts);

  @override
  int compare(Map<String, dynamic> a, Map<String, dynamic> b) {
    for (var sort in sorts) {
      var result = sort.compare(a, b);
      if (result != 0) return result;
    }
    return 0;
  }
}