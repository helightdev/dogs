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

/// Requires a field to match another field.
class MustMatch extends ContextFieldValidator<MustMatchCacheEntry> implements StructureMetadata {

  final String otherFieldName;
  const MustMatch(this.otherFieldName);

  static const String messageId = "must-match";

  @override
  MustMatchCacheEntry getCachedValue(DogStructure structure, DogStructureField field) {
    final selfIndex = structure.fields.indexOf(field);
    final otherIndex = structure.indexOfFieldName(otherFieldName)!;
    final proxy = structure.proxy;
    return MustMatchCacheEntry(field.name, structure.fields[otherIndex].name, selfIndex, otherIndex, proxy);
  }

  @override
  bool validate(MustMatchCacheEntry cached, instance, DogEngine engine) {
    final selfValue = cached.proxy.getField(instance, cached.selfIndex);
    final otherValue = cached.proxy.getField(instance, cached.otherIndex);
    return deepEquality.equals(selfValue, otherValue);
  }

  @override
  AnnotationResult annotate(dynamic cached, dynamic instance, DogEngine engine) {
    final isValid = validate(cached, instance, engine);
    if (isValid) return AnnotationResult.empty();
    final entry = cached as MustMatchCacheEntry;
    return AnnotationResult(messages: [
      AnnotationMessage(id: messageId, message: "Must match field %otherField%", target: entry.fieldName, variables: {
        "field": entry.fieldName,
        "otherField": entry.otherFieldName
      })
    ]);
  }
}

class MustMatchCacheEntry {
  final String fieldName;
  final String otherFieldName;
  final int selfIndex;
  final int otherIndex;
  final DogStructureProxy proxy;

  MustMatchCacheEntry(this.fieldName, this.otherFieldName, this.selfIndex, this.otherIndex, this.proxy);
}