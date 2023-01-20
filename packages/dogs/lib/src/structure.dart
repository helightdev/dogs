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

class DogStructure {
  final Type type;
  final String serialName;
  final List<DogStructureField> fields;

  const DogStructure(this.type, this.serialName, this.fields);

  factory DogStructure.named(Type type, String name) =>
      DogStructure(type, name, []);
}

class DogStructureField {
  final Type type;
  final Type serialType;
  final Type? converterType;
  final IterableKind iterableKind;
  final String name;
  final bool optional;
  final bool structure;

  const DogStructureField(this.type, this.serialType, this.converterType,
      this.iterableKind, this.name, this.optional, this.structure);

  factory DogStructureField.string(String name,
      {bool optional = false,
      IterableKind iterable = IterableKind.none,
      Type? converterType}) {
    var type = String;
    if (iterable == IterableKind.list) {
      type = List<String>;
    } else if (iterable == IterableKind.set) {
      type = Set<String>;
    }
    return DogStructureField(
        type, String, converterType, iterable, name, optional, false);
  }

  factory DogStructureField.int(String name,
      {bool optional = false,
      IterableKind iterable = IterableKind.none,
      Type? converterType}) {
    var type = int;
    if (iterable == IterableKind.list) {
      type = List<int>;
    } else if (iterable == IterableKind.set) {
      type = Set<int>;
    }
    return DogStructureField(
        type, int, converterType, iterable, name, optional, false);
  }

  factory DogStructureField.double(String name,
      {bool optional = false,
      IterableKind iterable = IterableKind.none,
      Type? converterType}) {
    var type = double;
    if (iterable == IterableKind.list) {
      type = List<double>;
    } else if (iterable == IterableKind.set) {
      type = Set<double>;
    }
    return DogStructureField(
        type, double, converterType, iterable, name, optional, false);
  }

  factory DogStructureField.bool(String name,
      {bool optional = false,
      IterableKind iterable = IterableKind.none,
      Type? converterType}) {
    var type = bool;
    if (iterable == IterableKind.list) {
      type = List<bool>;
    } else if (iterable == IterableKind.set) {
      type = Set<bool>;
    }
    return DogStructureField(
        type, bool, converterType, iterable, name, optional, false);
  }

  factory DogStructureField.structure(
      String name, Type serial, Type type, IterableKind iterable,
      {bool optional = false, Type? converterType}) {
    return DogStructureField(
        type, serial, converterType, iterable, name, optional, false);
  }
}

mixin StructureEmitter<T> on DogConverter<T> {
  DogStructure get structure;
}
