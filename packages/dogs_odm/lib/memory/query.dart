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

abstract class MapMatcher {
  const MapMatcher();

  bool matches(Map<dynamic, dynamic> map);

  static bool evaluate(FilterExpr? expr, Map document, OdmSystem system) {
    if (expr == null) return true;
    var matcher = MapMatcher.parse(expr, system);
    return matcher.matches(document);
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

  static MapMatcher parse(FilterExpr expr, OdmSystem system) {
    switch(expr) {
      case FilterNative():
        return expr.obj as MapMatcher;
      case FilterAnd():
        var matchers = expr.filters.map((e) => MapMatcher.parse(e, system)).toList();
        return MapFilterAndMatcher(matchers);
      case FilterOr():
        var matchers = expr.filters.map((e) => MapMatcher.parse(e, system)).toList();
        return MatchFilterOrMatcher(matchers);
      case FilterExists():
        return MapFilterExistsMatcher(expr.field, expr.value);
      case FilterEqStruct():
        var document = system.serializeObject(expr.value, expr.typeArgument);
        return MapMatcherEq(expr.field, document);
      case FilterNeStruct():
        var document = system.serializeObject(expr.value, expr.typeArgument);
        return MapMatcherNe(expr.field, document);
      case FilterEq():
        return MapMatcherEq(expr.field, expr.value);
      case FilterNe():
        return MapMatcherNe(expr.field, expr.value);
      case FilterLt():
        return MapFilterLtMatcher(expr.field, expr.value);
      case FilterGt():
        return MapFilterGtMatcher(expr.field, expr.value);
      case FilterLte():
        return MapFilterLteMatcher(expr.field, expr.value);
      case FilterGte():
        return MapFilterGteMatcher(expr.field, expr.value);
      case FilterArrayContains():
        return MapFilterContainsMatcher(expr.field, expr.value);
      case FilterIn():
        return MapFilterInMatcher(expr.field, expr.values);
      case FilterNotIn():
        return MapFilterNotInMatcher(expr.field, expr.values);
    }
  }
}

class MapFilterLtMatcher extends MapMatcher {
  final String field;
  final Object? value;

  MapFilterLtMatcher(this.field, this.value);

  @override
  bool matches(Map<dynamic, dynamic> map) {
    var q = MapMatcher.traverse(map, field);
    if (!q.exists) return false;
    var fieldValue = q.value;
    if (fieldValue == null) return false;
    if (fieldValue is! Comparable) return false;
    return fieldValue.compareTo(value) < 0;
  }
}

class MapFilterGtMatcher extends MapMatcher {
  final String field;
  final Object? value;

  MapFilterGtMatcher(this.field, this.value);

  @override
  bool matches(Map<dynamic, dynamic> map) {
    var q = MapMatcher.traverse(map, field);
    if (!q.exists) return false;
    var fieldValue = q.value;
    if (fieldValue == null) return false;
    if (fieldValue is! Comparable) return false;
    return fieldValue.compareTo(value) > 0;
  }
}

class MapFilterLteMatcher extends MapMatcher {
  final String field;
  final Object? value;

  MapFilterLteMatcher(this.field, this.value);

  @override
  bool matches(Map<dynamic, dynamic> map) {
    var q = MapMatcher.traverse(map, field);
    if (!q.exists) return false;
    var fieldValue = q.value;
    if (fieldValue == null) return false;
    if (fieldValue is! Comparable) return false;
    return fieldValue.compareTo(value) <= 0;
  }
}

class MapFilterGteMatcher extends MapMatcher {
  final String field;
  final Object? value;

  MapFilterGteMatcher(this.field, this.value);

  @override
  bool matches(Map<dynamic, dynamic> map) {
    var q = MapMatcher.traverse(map, field);
    if (!q.exists) return false;
    var fieldValue = q.value;
    if (fieldValue == null) return false;
    if (fieldValue is! Comparable) return false;
    return fieldValue.compareTo(value) >= 0;
  }
}

class MapFilterExistsMatcher extends MapMatcher {
  final String field;
  final bool value;

  MapFilterExistsMatcher(this.field, this.value);

  @override
  bool matches(Map<dynamic, dynamic> map) {
    var q = MapMatcher.traverse(map, field);
    return q.exists == value;
  }
}

class MapFilterContainsMatcher extends MapMatcher {
  final String field;
  final Object? value;

  MapFilterContainsMatcher(this.field, this.value);

  @override
  bool matches(Map<dynamic, dynamic> map) {
    var q = MapMatcher.traverse(map, field);
    if (!q.exists) return false;
    var value = q.value;
    if (value == null) return false;
    if (value is! List) return false;
    return value.any((element) {
      var matches = deepEquality.equals(element, this.value);
      print("Comparing: $element with ${this.value}: $matches");
      return matches;
    });
  }
}

class MapFilterInMatcher extends MapMatcher {
  final String field;
  final List<Object?> values;

  MapFilterInMatcher(this.field, this.values);

  @override
  bool matches(Map<dynamic, dynamic> map) {
    var q = MapMatcher.traverse(map, field);
    if (!q.exists) return false;
    var value = q.value;
    if (value == null) return false;
    return values.any((element) => deepEquality.equals(element, value));
  }
}

class MapFilterNotInMatcher extends MapMatcher {
  final String field;
  final List<Object?> values;

  MapFilterNotInMatcher(this.field, this.values);

  @override
  bool matches(Map<dynamic, dynamic> map) {
    var q = MapMatcher.traverse(map, field);
    if (!q.exists) return true;
    var value = q.value;
    if (value == null) return true;
    return values.every((element) => !deepEquality.equals(element, value));
  }
}

class MapFilterArrayMatcherAnyMatcher extends MapMatcher {
  final String field;
  final MapMatcher matcher;

  MapFilterArrayMatcherAnyMatcher(this.field, this.matcher);

  @override
  bool matches(Map<dynamic, dynamic> map) {
    var q = MapMatcher.traverse(map, field);
    if (!q.exists) return false;
    var value = q.value;
    if (value == null) return false;
    if (value is! List) return false;
    for (var element in value) {
      if (element is! Map) return false;
      if (matcher.matches(element)) return true;
    }
    return false;
  }
}

class MapFilterAndMatcher extends MapMatcher {
  final List<MapMatcher> matchers;

  MapFilterAndMatcher(this.matchers);

  @override
  bool matches(Map<dynamic, dynamic> map) {
    return matchers.every((matcher) => matcher.matches(map));
  }
}

class MatchFilterOrMatcher extends MapMatcher {
  final List<MapMatcher> matchers;

  MatchFilterOrMatcher(this.matchers);

  @override
  bool matches(Map<dynamic, dynamic> map) {
    return matchers.any((matcher) => matcher.matches(map));
  }
}

class MapAllMatcher extends MapMatcher {
  final List<MapMatcher> matchers;

  MapAllMatcher(this.matchers);

  @override
  bool matches(Map<dynamic, dynamic> map) {
    return matchers.every((matcher) => matcher.matches(map));
  }
}

class MapOrMatcher extends MapMatcher {
  final List<MapMatcher> matchers;

  MapOrMatcher(this.matchers);

  @override
  bool matches(Map<dynamic, dynamic> map) {
    return matchers.any((matcher) => matcher.matches(map));
  }
}

class MapMatcherEq extends MapMatcher {
  final String field;
  final Object? value;

  MapMatcherEq(this.field, this.value);

  @override
  bool matches(Map<dynamic, dynamic> map) {
    var q = MapMatcher.traverse(map, field);
    if (!q.exists) return false;
    var fieldValue = q.value;
    return deepEquality.equals(fieldValue, value);
  }
}

class MapMatcherNe extends MapMatcher {
  final String field;
  final Object? value;

  MapMatcherNe(this.field, this.value);

  @override
  bool matches(Map<dynamic, dynamic> map) {
    var q = MapMatcher.traverse(map, field);
    if (!q.exists) return false;
    var fieldValue = q.value;
    return !deepEquality.equals(fieldValue, value);
  }
}
