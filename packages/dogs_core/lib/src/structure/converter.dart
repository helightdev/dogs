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

/// Default [DogConverter] base for [DogStructure]s.
/// Normally extended by generated converters.
abstract class DefaultStructureConverter<T> extends DogConverter<T> {
  /// Default [DogConverter] base for [DogStructure]s.
  DefaultStructureConverter({required super.struct});

  @override
  OperationMode<T>? resolveOperationMode(DogEngine engine, Type opmodeType) {
    if (opmodeType == NativeSerializerMode) {
      return StructureNativeSerialization<T>(struct!);
    }
    if (opmodeType == ValidationMode) return StructureValidation(struct!);
    return null;
  }

  @override
  SchemaType describeOutput(DogEngine engine, SchemaConfig config) {
    final pass = SchemaPass.current!;

    final structure = struct!;
    if (structure.isSynthetic) return SchemaType.any;
    if (config.useReferences && pass.depth >= 1) {
      return SchemaReference(structure.serialName);
    }

    pass.depth++;
    final fields = structure.fields.map((e) {
      final converter = engine.getTreeConverter(e.type);
      final type = converter.describeOutput(engine, config);
      type.nullable = e.optional;

      final schemaField = SchemaField(e.name, type);
      e.annotationsOf<SchemaFieldVisitor>().forEach((visitor) {
        visitor.visitSchemaField(schemaField);
      });
      return schemaField;
    }).toList();
    pass.depth--;

    final object = SchemaObject(fields: fields);
    object[SchemaProperties.serialName] = structure.serialName;
    return object;
  }
}

/// Mock implementation for [DefaultStructureConverter].
class DogStructureConverterImpl<T> extends DefaultStructureConverter<T> {
  /// Mock implementation for [DefaultStructureConverter].
  DogStructureConverterImpl(DogStructure<T> structure) : super(struct: structure);

  @override
  String toString() {
    return "DogStructureConverterImpl<$T>(serialName: ${struct?.serialName})";
  }
}
