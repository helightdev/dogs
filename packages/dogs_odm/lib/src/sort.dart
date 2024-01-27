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

  factory Sorted.byField(String field, {bool ascending = true}) {
    return Sorted(sort: SortScalar(field, ascending));
  }

  factory Sorted.byFields(List<String> fields,
      {List<bool>? ascending, defaultAscending = true}) {
    ascending ??= List.filled(fields.length, defaultAscending);
    if (fields.length != ascending.length) {
      throw Exception("Fields and ascending must have the same length.");
    }
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