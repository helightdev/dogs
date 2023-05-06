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

abstract class StructureMetadata extends RetainedAnnotation {
  const StructureMetadata();
}

abstract class RegistrationHook {
  const RegistrationHook();

  void onRegistration(DogEngine engine, DefaultStructureConverter converter);
}

abstract class ConverterSupplyingVisitor extends StructureMetadata {
  const ConverterSupplyingVisitor();

  DogConverter resolve(
      DogStructure structure, DogStructureField field, DogEngine engine);
}

/// Defines the structure of class [T] and provides methods for instance creation
/// and data lookups. Also contains runtime instances of [RetainedAnnotation]s
/// used in [T].
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

  bool get isSynthetic => fields.isEmpty;

  const DogStructure(this.serialName, this.conformity, this.fields,
      this.annotations, this.proxy);

  @override
  String toString() {
    return 'DogStructure $typeArgument';
  }

  factory DogStructure.synthetic(String name) => DogStructure<T>(
      name, StructureConformity.basic, [], [], const MemoryDogStructureProxy());
}

abstract class StructureNode {
  const StructureNode();
}

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

mixin StructureEmitter<T> on DogConverter<T> {
  DogStructure get structure;
}
