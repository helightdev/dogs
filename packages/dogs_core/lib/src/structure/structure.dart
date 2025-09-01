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

/// Marks a annotation as a structure annotation and retainable.
abstract class StructureMetadata extends RetainedAnnotation {
  /// Marks a annotation as a structure annotation and retainable.
  const StructureMetadata();
}

/// Annotation to override the converter used for a field.
abstract class ConverterSupplyingVisitor extends StructureMetadata {
  /// Annotation to override the converter used for a field.
  const ConverterSupplyingVisitor();

  /// Returns the converter type to use for the field.
  DogConverter resolve(
      DogStructure structure, DogStructureField field, DogEngine engine);
}

/// Annotation to manually set the convert used for a field to a fixed instance.
class UseConverterInstance
    implements StructureMetadata, ConverterSupplyingVisitor {
  /// Fixed converter instance that will be used for the annotated field.
  final DogConverter converter;

  /// Annotation to manually set the convert used for a field to a fixed instance.
  const UseConverterInstance(this.converter);

  @override
  DogConverter resolve(
      DogStructure structure, DogStructureField field, DogEngine engine) {
    return converter;
  }
}

/// Defines the structure of class [T] and provides methods for instance creation
/// and data lookups. Also contains runtime instances of [RetainedAnnotation]s
/// used in [T].
///
/// See also: https://dogs.helight.dev/advanced/structures
class DogStructure<T> extends RetainedAnnotationHolder
    with TypeCaptureMixin<T>
    implements StructureNode {
  /// Serial name of the structure.
  final String serialName;

  /// Specifies the type of the structure.
  final StructureConformity conformity;

  /// Collection of the structure's properties.
  final List<DogStructureField> fields;

  /// Proxy for accessing structure data.
  final DogStructureProxy proxy;

  @override
  final List<RetainedAnnotation> annotations;

  /// Returns true if this structure is synthetic.
  bool get isSynthetic => fields.isEmpty;

  /// Creates a new [DogStructure].
  ///
  /// See also: https://dogs.helight.dev/advanced/structures
  const DogStructure(this.serialName, this.conformity, this.fields,
      this.annotations, this.proxy);

  @override
  String toString() {
    return "DogStructure '$serialName' with type '$typeArgument'";
  }

  /// Creates a synthetic [DogStructure]. This means that the structure is not
  /// automatically generated from a class and (most likely) does not have a
  /// backing class and proxy.
  factory DogStructure.synthetic(String name) => DogStructure<T>(
      name, StructureConformity.basic, [], [], const MemoryDogStructureProxy());

  /// Create a copy of this structure with optional modifications.
  DogStructureCopyFrontend<T> get copy =>
      _DogStructureCopyFrontendImpl<T>(this);
}

/// Superclass for all structure related subtypes.
abstract class StructureNode {
  /// Superclass for all structure related subtypes.
  const StructureNode();
}

/// The conformity of a structure.
///
/// See also: https://dogs.helight.dev/serializables#conformities
enum StructureConformity {
  /// Class which posses following attributes are parsed and understood as bean
  /// classes:
  /// - The class is annotated with @serializable
  /// - The primary constructor has no arguments
  /// - The class has at least one property or field with both a getter and a setter
  ///
  /// If a structure is generated as a bean, the activation function will, instead
  /// of using constructors like for [basic] and [dataclass], be using the field
  /// setters to create a new instance. All field with the late modifier will
  /// be treated as required fields and all nullable fields as optional respectively.
  ///
  /// A bean factory, which is named *ClassName*Factory, will be generated
  /// together with the structure definition. This factory can be used to create
  /// instances of the bean using the static 'create'  method with named
  /// arguments. No other classes are generated for bean-type structures.
  bean,

  /// Classes which posses following attributes are parsed and understood as
  /// basic classes:
  /// - The class is annotated with @serializable
  /// - The class has a primary constructor or secondary constructor named 'dog'
  /// that has only field references
  ///
  /// If a structure is generated as a basic structure, a builder and an extension
  /// for creating the builder will be created together with the structure
  /// definition. This build can be used to create a builder
  basic,

  /// Classes which posses following attributes are parsed and understood as
  /// dataclass classes:
  /// - The class is annotated with @serializable
  /// - The class uses the mixin Dataclass&lt*ClassName*&gt
  /// - The class has a primary constructor or secondary constructor named 'dog'
  /// that has only field references
  /// - All fields used with the previously mentioned constructor must be
  /// effectively final and should therefore also have the final modifier
  dataclass
}

/// Static way to provide additional opmode factories to the default structure
/// converter.
abstract class StructureOperationModeFactory<MODE_TYPE extends OperationMode>
    with TypeCaptureMixin<MODE_TYPE> {
  /// Returns the operation mode for the [structure].
  MODE_TYPE resolve(DogStructure structure);
}

/// Frontend for copying a [DogStructure] with optional modifications.
abstract interface class DogStructureCopyFrontend<T> {
  /// Creates a copy of the structure with the given [name] and [conformity].
  DogStructure<T> call({
    String? serialName,
    StructureConformity? conformity,
    DogStructureProxy? proxy,
    List<DogStructureField>? fields,
    List<RetainedAnnotation>? annotations,
  });
}

class _DogStructureCopyFrontendImpl<T> implements DogStructureCopyFrontend<T> {
  final DogStructure<T> structure;
  const _DogStructureCopyFrontendImpl(this.structure);

  @override
  DogStructure<T> call({
    Object? serialName = #none,
    Object? conformity = #none,
    Object? proxy = #none,
    Object? fields = #none,
    Object? annotations = #none,
  }) {
    return DogStructure<T>(
      serialName == #none ? structure.serialName : serialName as String,
      conformity == #none
          ? structure.conformity
          : conformity as StructureConformity,
      fields == #none ? structure.fields : fields as List<DogStructureField>,
      annotations == #none
          ? structure.annotations
          : annotations as List<RetainedAnnotation>,
      proxy == #none ? structure.proxy : proxy as DogStructureProxy,
    );
  }
}
