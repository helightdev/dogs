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
import 'package:meta/meta.dart';

class DogStructureField extends RetainedAnnotationHolder
    implements StructureNode {
  /// Declared type of the structure.
  final QualifiedTypeTree type;

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
      Type? converterType,
      List<RetainedAnnotation> annotations = const []}) {
    var type = QualifiedTypeTree.terminal<String>();
    if (iterable == IterableKind.list) {
      type = QualifiedTypeTree.list<String>();
    } else if (iterable == IterableKind.set) {
      type = QualifiedTypeTree.set<String>();
    }
    return DogStructureField(type, TypeToken<String>(), converterType, iterable,
        name, optional, false, annotations);
  }

  factory DogStructureField.int(String name,
      {bool optional = false,
      IterableKind iterable = IterableKind.none,
      Type? converterType,
      List<RetainedAnnotation> annotations = const []}) {
    var type = QualifiedTypeTree.terminal<int>();
    if (iterable == IterableKind.list) {
      type = QualifiedTypeTree.list<int>();
    } else if (iterable == IterableKind.set) {
      type = QualifiedTypeTree.set<int>();
    }
    return DogStructureField(type, TypeToken<int>(), converterType, iterable,
        name, optional, false, annotations);
  }

  factory DogStructureField.double(String name,
      {bool optional = false,
      IterableKind iterable = IterableKind.none,
      Type? converterType,
      List<RetainedAnnotation> annotations = const []}) {
    var type = QualifiedTypeTree.terminal<double>();
    if (iterable == IterableKind.list) {
      type = QualifiedTypeTree.list<double>();
    } else if (iterable == IterableKind.set) {
      type = QualifiedTypeTree.set<double>();
    }
    return DogStructureField(type, TypeToken<double>(), converterType, iterable,
        name, optional, false, annotations);
  }

  factory DogStructureField.bool(String name,
      {bool optional = false,
      IterableKind iterable = IterableKind.none,
      Type? converterType,
      List<RetainedAnnotation> annotations = const []}) {
    var type = QualifiedTypeTree.terminal<bool>();
    if (iterable == IterableKind.list) {
      type = QualifiedTypeTree.list<bool>();
    } else if (iterable == IterableKind.set) {
      type = QualifiedTypeTree.set<bool>();
    }
    return DogStructureField(type, TypeToken<bool>(), converterType, iterable,
        name, optional, false, annotations);
  }

  static DogStructureField create<TYPE>(String name,
      {bool optional = false,
        IterableKind iterable = IterableKind.none,
        Type? converterType,
        List<RetainedAnnotation> annotations = const []}) {
    var type = QualifiedTypeTree.terminal<TYPE>();
    if (iterable == IterableKind.list) {
      type = QualifiedTypeTree.list<TYPE>();
    } else if (iterable == IterableKind.set) {
      type = QualifiedTypeTree.set<TYPE>();
    }
    return DogStructureField(type, TypeToken<TYPE>(), converterType, iterable,
        name, optional, false, annotations);
  }
}
