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

/// Converter that just keeps the value as is.
class NativeRetentionConverter<T> extends DogConverter<T>
    with OperationMapMixin<T> {
  /// The schema type of the value.
  final SchemaType Function()? schema;

  /// Converter that just keeps the value as is.
  const NativeRetentionConverter({this.schema}) : super();

  @override
  Map<Type, OperationMode<T> Function()> get modes => {
        NativeSerializerMode: () => NativeSerializerMode.create(
            serializer: (value, engine) => value,
            deserializer: (value, engine) => value),
      };

  @override
  SchemaType describeOutput(DogEngine engine, SchemaConfig config) {
    return schema?.call() ?? SchemaType.any;
  }

  @override
  String toString() {
    return "Native<$T>";
  }
}

/// Metadata that marks a property as native.
class NativeProperty extends StructureMetadata
    implements ConverterSupplyingVisitor {
  /// Metadata that marks a property as native.
  const NativeProperty();

  @override
  DogConverter resolve(DogStructure<dynamic> structure, DogStructureField field,
      DogEngine engine) {
    return NativeRetentionConverter();
  }
}

/// Metadata that marks a property as native.
/// The value will be kept as is during serialization and deserialization.
const NativeProperty native = NativeProperty();
