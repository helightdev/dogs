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

import "package:dogs_core/dogs_core.dart";

/// Visitor for [DogGraphValue]s that maps a value to type [T].
abstract interface class DogVisitor<T> {
  /// Visits an arbitrary [DogGraphValue] and returns a result of type [T].
  T visit(DogGraphValue v);
}

/// A mixin that provides a default implementation for [ExpandedDogVisitor].
/// Override the methods to provide custom behavior for each type of value.
mixin ExpandedGraphDogVisitorMixin<T> on DogVisitor<T> implements ExpandedDogVisitor<T> {
  @override
  T visit(DogGraphValue v) => switch (v) {
        DogNative() => visitNative(v),
        DogString() => visitString(v),
        DogInt() => visitInt(v),
        DogDouble() => visitDouble(v),
        DogBool() => visitBool(v),
        DogNull() => visitNull(v),
        DogList() => visitList(v),
        DogMap() => visitMap(v),
      };

  @override
  T visitMap(DogMap m) => null as T;

  @override
  T visitList(DogList l) => null as T;

  @override
  T visitString(DogString s) => null as T;

  @override
  T visitInt(DogInt i) => null as T;

  @override
  T visitDouble(DogDouble d) => null as T;

  @override
  T visitBool(DogBool b) => null as T;

  @override
  T visitNull(DogNull n) => null as T;

  @override
  T visitNative(DogNative n) => null as T;
}

/// A visitor for [DogGraphValue]s that provides a visitor method for each type of value.
abstract interface class ExpandedDogVisitor<T> {
  /// Visits a [DogGraphValue] of type [DogMap].
  T visitMap(DogMap m);

  /// Visits a [DogGraphValue] of type [DogList].
  T visitList(DogList l);

  /// Visits a [DogGraphValue] of type [DogString].
  T visitString(DogString s);

  /// Visits a [DogGraphValue] of type [DogInt].
  T visitInt(DogInt i);

  /// Visits a [DogGraphValue] of type [DogDouble].
  T visitDouble(DogDouble d);

  /// Visits a [DogGraphValue] of type [DogBool].
  T visitBool(DogBool b);

  /// Visits a [DogGraphValue] of type [DogNull].
  T visitNull(DogNull n);

  /// Visits a [DogGraphValue] of type [DogNative].
  T visitNative(DogNative n);
}
