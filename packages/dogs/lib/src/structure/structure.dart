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

abstract class StructureMetadata extends RetainedAnnotation {
  const StructureMetadata();
}

class TestStructureAnnotation extends StructureMetadata {
  final String value;

  const TestStructureAnnotation(this.value);
}

class DogStructure<T> extends RetainedAnnotationHolder
    with TypeCaptureMixin<T>
    implements StructureNode {
  /// Serial name of the structure.
  final String serialName;

  /// Collection of the structure's properties.
  final List<DogStructureField> fields;

  /// Proxy for accessing structure data.
  final DogStructureProxy proxy;

  @override
  final List<RetainedAnnotation> annotations;

  bool get isSynthetic => fields.isEmpty;

  const DogStructure(
      this.serialName, this.fields, this.annotations, this.proxy);

  @override
  String toString() {
    return 'DogStructure $typeArgument';
  }

  factory DogStructure.synthetic(String name) =>
      DogStructure<T>(name, [], [], const MemoryDogStructureProxy());
}

abstract class StructureNode {
  const StructureNode();
}

mixin StructureEmitter<T> on DogConverter<T> {
  DogStructure get structure;
}
