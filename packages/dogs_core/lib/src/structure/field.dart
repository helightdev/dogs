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

/// The definition of a field in a [DogStructure].
/// Holds all necessary information to validate and serialize and introspect
/// the field.
///
/// See also: https://dogs.helight.dev/advanced/structures
class DogStructureField extends RetainedAnnotationHolder
    implements StructureNode {
  /// Declared type of the structure.
  final TypeTree type;

  /// Optional converter type override.
  final Type? converterType;

  /// The name of the field.
  final String name;

  /// Defines the nullability of the field.
  final bool optional;

  /// Defines if the fields serial type is a structure.
  final bool structure;

  @override
  final List<RetainedAnnotation> annotations;

  /// The kind of iterable this field is.
  ///
  /// NOTE: Originally, this was a custom field that has since been removed and
  /// replaced with this getter for compatibility reasons.
  IterableKind get iterableKind {
    if (type.arguments.length == 1) {
      final base = type.base.typeArgument;
      if (base == List) {
        return IterableKind.list;
      } else if (base == Set) {
        return IterableKind.set;
      }
    }
    return IterableKind.none;
  }

  /// Returns the serial type of this field.
  ///
  /// NOTE: Originally, this was a custom field that has since been removed and
  /// replaced with this getter for compatibility reasons.
  TypeCapture get serial {
    if (iterableKind == IterableKind.none) {
      return type.qualifiedOrBase;
    } else {
      final arg = type.arguments[0];
      if (arg.isQualified) {
        return arg.qualifiedOrBase;
      } else {
        return arg.base;
      }
    }
  }

  /// Creates a new [DogStructureField].
  ///
  /// See also: https://dogs.helight.dev/advanced/structures
  const DogStructureField(this.type, this.converterType, this.name,
      this.optional, this.structure, this.annotations);

  @override
  String toString() {
    return 'DogStructureField $type${optional ? '?' : ''} $name';
  }

  /// Creates a synthetic [String] field.
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
    return DogStructureField(
        type, converterType, name, optional, false, annotations);
  }

  /// Creates a synthetic [int] field.
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
    return DogStructureField(
        type, converterType, name, optional, false, annotations);
  }

  /// Creates a synthetic [double] field.
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
    return DogStructureField(
        type, converterType, name, optional, false, annotations);
  }

  /// Creates a synthetic [bool] field.
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
    return DogStructureField(
        type, converterType, name, optional, false, annotations);
  }

  /// Creates a synthetic field for a terminal serial type.
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
    return DogStructureField(
        type, converterType, name, optional, true, annotations);
  }

  /// Provides a fluent API to create modified copies of this field.
  DogStructureFieldCopyFrontend get copy =>
      _DogStructureFieldCopyFrontendImpl(this);
}

/// Fluent API to create modified copies of a [DogStructureField].
abstract interface class DogStructureFieldCopyFrontend {
  /// Creates a copy of the field with the given modifications.
  DogStructureField call({
    QualifiedTypeTree? type,
    String? name,
    bool? optional,
    IterableKind? iterable,
    Type? converterType,
    bool? structure,
    List<RetainedAnnotation>? annotations,
  });
}

class _DogStructureFieldCopyFrontendImpl
    implements DogStructureFieldCopyFrontend {
  final DogStructureField field;
  const _DogStructureFieldCopyFrontendImpl(this.field);

  @override
  DogStructureField call({
    Object? type = #none,
    Object? name = #none,
    Object? optional = #none,
    Object? iterable = #none,
    Object? converterType = #none,
    Object? structure = #none,
    Object? annotations = #none,
  }) {
    return DogStructureField(
      type == #none ? field.type : type as QualifiedTypeTree,
      converterType == #none ? field.converterType : converterType as Type?,
      name == #none ? field.name : name as String,
      optional == #none ? field.optional : optional as bool,
      structure == #none ? field.structure : structure as bool,
      annotations == #none
          ? field.annotations
          : annotations as List<RetainedAnnotation>,
    );
  }
}
