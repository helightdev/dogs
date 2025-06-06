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
import "package:meta/meta.dart";

/// Utility class for resolving converters for a [DogStructure].
class StructureHarbinger<T> {
  /// The structure this harbinger is for.
  final DogStructure<T> structure;

  /// The engine this used to create this harbinger instance.
  final DogEngine engine;

  /// Resolved list of all field converters for the structure.
  late List<({DogStructureField field, DogConverter? converter})>
      fieldConverters;

  /// Creates a new [StructureHarbinger] for the supplied [structure] and [engine].
  StructureHarbinger(this.structure, this.engine) {
    fieldConverters = structure.fields.map((e) {
      final fieldConverter = getConverter(engine, structure, e);
      return (field: e, converter: fieldConverter);
    }).toList();
  }

  /// Performs the converter lookup for a single field.
  @internal
  static DogConverter? getConverter(DogEngine engine, DogStructure? structure, DogStructureField field, {
    bool nativeConverters = false,
  }) {
    if (structure != null) {
      // Try resolving using supplying visitors
      final supplier = field.firstAnnotationOf<ConverterSupplyingVisitor>();
      if (supplier != null) {
        return supplier.resolve(structure, field, engine);
      }
    }

    // Converter type is specifically defined
    if (field.converterType != null) {
      return engine.findConverter(field.converterType!);
    }

    // This value is native, we don't need a converter
    if (field.type.isQualified && engine.codec.isNative(field.type.qualified.typeArgument)) {
      if (nativeConverters) {
        return engine.codec.bridgeConverters[field.type.qualified.typeArgument];
      }
      return null;
    }

    // Try resolving the type directly
    final directConverter =
        engine.findAssociatedConverter(field.type.qualifiedOrBase.typeArgument);
    if (directConverter != null) return directConverter;

    // Resolve using tree converter
    return engine.getTreeConverter(field.type, isPolymorphicField(field));
  }

  /// Creates a new [StructureHarbinger] for the supplied [structure] and [engine].
  static StructureHarbinger create(DogStructure structure, DogEngine engine) =>
      StructureHarbinger(structure, engine);
}
