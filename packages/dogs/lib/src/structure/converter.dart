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

import 'package:conduit_open_api/v3.dart';
import 'package:dogs_core/dogs_core.dart';

abstract class DefaultStructureConverter<T> extends DogConverter<T> {

  DefaultStructureConverter({
    required super.struct
  });

  @override
  DogConverter<T> fork(DogEngine forkEngine) => DogStructureConverterImpl<T>(struct!);

  @override
  OperationMode<T>? resolveOperationMode(Type opmodeType) {
    if (opmodeType == NativeSerializerMode) return StructureNativeSerialization(struct!);
    if (opmodeType == GraphSerializerMode) return StructureGraphSerialization(struct!);
    if (opmodeType == ValidationMode) return StructureValidation(struct!);
    return structureOperationFactories[opmodeType]?.resolve(struct!) as OperationMode<T>?;
  }

  @override
  void registrationCallback(DogEngine engine) {
    // Run annotation callbacks
    struct!.annotationsOf<RegistrationHook>().forEach((e) {
      e.onRegistration(engine, this);
    });
    struct!.fields
        .expand((e) => e.annotationsOf<RegistrationHook>())
        .forEach((e) {
      e.onRegistration(engine, this);
    });
  }

  @override
  APISchemaObject get output {
    if (struct!.isSynthetic) return APISchemaObject.empty();
    return APISchemaObject()
      ..referenceURI = Uri(path: "/components/schemas/${struct!.serialName}");
  }

  /*
  @override
  T copy(T src, DogEngine engine, Map<String, dynamic>? overrides) {
    if (overrides == null) {
      return struct!.proxy.instantiate(struct!.proxy.getFieldValues(src));
    } else {
      var map = overrides.map(
          (key, value) => MapEntry(struct!.indexOfFieldName(key)!, value));
      var values = [];
      for (var i = 0; i < struct!.fields.length; i++) {
        if (map.containsKey(i)) {
          values.add(map[i]);
        } else {
          values.add(struct!.proxy.getField(src, i));
        }
      }
      return struct!.proxy.instantiate(values);
    }
  }
   */
}

class DogStructureConverterImpl<T> extends DefaultStructureConverter<T> {
  DogStructureConverterImpl(DogStructure<T> structure) : super(struct: structure);
}