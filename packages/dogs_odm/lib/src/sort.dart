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

class Sorted {
  final SortExpr? sort;

  const Sorted({this.sort});

  const Sorted.empty() : this(sort: null);

  /// Sorts by the given [field] in ascending order.
  factory Sorted.byField(String field, {bool descending = false}) {
    return Sorted(sort: SortScalar(field, descending));
  }

  /// Sorts by the given [fields] in ascending order.
  factory Sorted.byFields(List<String> fields,
      {List<bool>? descending, defaultDescending = false}) {
    descending ??= List.filled(fields.length, defaultDescending);
    if (fields.length != descending.length) {
      throw Exception("Fields and descending must have the same length.");
    }
    var sorts = <SortExpr>[];
    for (var i = 0; i < fields.length; i++) {
      sorts.add(SortScalar(fields[i], descending[i]));
    }
    return Sorted(sort: SortCombine(sorts));
  }

  factory Sorted.combine(List<Sorted> sorts) {
    var expressions = <SortExpr>[];
    for (var sort in sorts) {
      if (sort.sort == null) {
        continue;
      } else if (sort.sort is SortCombine) {
        expressions.addAll((sort.sort as SortCombine).sorts);
      } else {
        expressions.add(sort.sort!);
      }
    }
    return Sorted(sort: SortCombine(expressions));
  }

  Sorted operator &(Sorted other) {
    if (sort == null) {
      return other;
    } else if (other.sort == null) {
      return this;
    } else {
      var sorts = <SortExpr>[];
      if (sort is SortCombine) {
        sorts.addAll((sort as SortCombine).sorts);
      } else {
        sorts.add(sort!);
      }
      if (other.sort is SortCombine) {
        sorts.addAll((other.sort as SortCombine).sorts);
      } else {
        sorts.add(other.sort!);
      }
      return Sorted(sort: SortCombine(sorts));
    }
  }
}

sealed class SortExpr {
  const SortExpr();
}

class SortScalar extends SortExpr {
  final String field;
  final bool descending;

  const SortScalar(this.field, this.descending);
}

class SortCombine extends SortExpr {
  final List<SortExpr> sorts;

  const SortCombine(this.sorts);
}