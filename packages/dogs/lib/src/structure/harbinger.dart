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

/// Utility class for resolving converters for a [DogStructure].
class StructureHarbinger<T> {
  final DogStructure<T> structure;
  final DogEngine engine;

  late List<({DogStructureField field, DogConverter? converter})>
      fieldConverters;

  StructureHarbinger(this.structure, this.engine) {
    fieldConverters = structure.fields.map((e) {
      var fieldConverter = getConverter(engine, e);
      return (field: e, converter: fieldConverter);
    }).toList();
  }

  @internal
  DogConverter? getConverter(DogEngine engine, DogStructureField field) {
    // Try resolving using supplying visitors
    final supplier = field.firstAnnotationOf<ConverterSupplyingVisitor>();
    if (supplier != null) {
      return supplier.resolve(structure, field, engine);
    }

    // Converter type is specifically defined
    if (field.converterType != null) {
      return engine.findConverter(field.converterType!);
    }

    // This value is native, we don't need a converter
    if (engine.codec.isNative(field.type.qualified.typeArgument)) {
      return null;
    }

    // Try resolving the type directly
    var directConverter =
        engine.findAssociatedConverter(field.type.typeArgument);
    if (directConverter != null) return directConverter;

    if (field.iterableKind != IterableKind.none) {
      // Try resolving using the serial type argument (i.E. the first type argument)
      var serialConverter =
          engine.findAssociatedConverter(field.serial.typeArgument);
      if (serialConverter != null) return serialConverter;
    }
    // Resolve using tree converter
    return engine.getTreeConverter(field.type, isPolymorphicField(field));
  }

  static StructureHarbinger create(DogStructure structure, DogEngine engine) =>
      StructureHarbinger(structure, engine);
}
