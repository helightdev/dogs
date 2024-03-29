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

import "package:conduit_open_api/v3.dart";
import "package:dogs_core/dogs_core.dart";

/// Default [DogConverter] base for [DogStructure]s.
/// Normally extended by generated converters.
abstract class DefaultStructureConverter<T> extends DogConverter<T> {
  /// Default [DogConverter] base for [DogStructure]s.
  DefaultStructureConverter({required super.struct});

  @override
  OperationMode<T>? resolveOperationMode(Type opmodeType) {
    if (opmodeType == NativeSerializerMode) {
      return StructureNativeSerialization(struct!);
    }
    if (opmodeType == ValidationMode) return StructureValidation(struct!);
    return structureOperationFactories[opmodeType]?.resolve(struct!)
        as OperationMode<T>?;
  }

  @override
  APISchemaObject get output {
    if (struct!.isSynthetic) return APISchemaObject.empty();
    return APISchemaObject()
      ..referenceURI = Uri(path: "/components/schemas/${struct!.serialName}");
  }
}

/// Mock implementation for [DefaultStructureConverter].
class DogStructureConverterImpl<T> extends DefaultStructureConverter<T> {
  /// Mock implementation for [DefaultStructureConverter].
  DogStructureConverterImpl(DogStructure<T> structure)
      : super(struct: structure);
}
