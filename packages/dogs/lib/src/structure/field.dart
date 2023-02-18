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
import 'package:lyell/lyell.dart';

class DogStructureField extends RetainedAnnotationHolder implements StructureNode {
  /// Declared type of the structure.
  final Type type;

  /// Serial type of the structure.
  /// If the declared type is [Iterable], [List] or [Set], the type argument
  /// of the iterable will be the serial type.
  final TypeCapture serial;

  /// Optional converter type override.
  final Type? converterType;

  /// Type of the iterable, if this field is iterable.
  final IterableKind iterableKind;

  /// The name of the field.
  final String name;

  /// Defines the nullability of the field.
  final bool optional;

  /// Defines if the fields serial type is a structure.
  final bool structure;

  @override
  final List<RetainedAnnotation> annotations;

  const DogStructureField(
      this.type,
      this.serial,
      this.converterType,
      this.iterableKind,
      this.name,
      this.optional,
      this.structure,
      this.annotations);


  @override
  String toString() {
    return 'DogStructureField $type${optional ? '?' : ''} $name';
  }

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
    return DogStructureField(type, TypeToken<String>(), converterType, iterable,
        name, optional, false, []);
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
    return DogStructureField(type, TypeToken<int>(), converterType, iterable,
        name, optional, false, []);
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
    return DogStructureField(type, TypeToken<double>(), converterType, iterable,
        name, optional, false, []);
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
    return DogStructureField(type, TypeToken<bool>(), converterType, iterable,
        name, optional, false, []);
  }

  static DogStructureField create<T>(
      String name, Type type, IterableKind iterable,
      {bool optional = false, Type? converterType}) {
    return DogStructureField(type, TypeToken<T>(), converterType, iterable,
        name, optional, true, []);
  }
}
