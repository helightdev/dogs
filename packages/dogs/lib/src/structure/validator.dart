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

import 'package:collection/collection.dart';
import 'package:dogs_core/dogs_core.dart';

/// Property level validator for annotations of [DogStructureField]s.
abstract class FieldValidator {
  const FieldValidator();

  bool isApplicable(DogStructure structure, DogStructureField field) => true;
  dynamic getCachedValue(DogStructure structure, DogStructureField field);
  bool validate(dynamic cached, dynamic value, DogEngine engine);
}

/// Class level validator for annotations of [ClassValidator]s.
abstract class ClassValidator {
  const ClassValidator();

  bool isApplicable(DogStructure structure) => true;
  dynamic getCachedValue(DogStructure structure);
  bool validate(dynamic cached, dynamic value, DogEngine engine);
}

class ValidationException implements Exception {}


class StructureValidation<T> extends ValidationMode<T> with TypeCaptureMixin<T> {
  DogStructure<T> structure;

  StructureValidation(this.structure);

  bool _hasValidation = false;
  late Map<ClassValidator, dynamic> _cachedClassValidators;
  late Map<int, List<MapEntry<FieldValidator, dynamic>>> _cachedFieldValidators;

  @override
  void initialise(DogEngine engine) {
    // Create and cache validators eagerly
    _cachedClassValidators =
        Map.fromEntries(structure.annotationsOf<ClassValidator>().where((e) {
          var applicable = e.isApplicable(structure);
          if (applicable) {
            _hasValidation = true;
          } else {
            print("$e is not applicable in $structure");
          }
          return applicable;
        }).map((e) => MapEntry(e, e.getCachedValue(structure))));

    _cachedFieldValidators =
        Map.fromEntries(structure.fields.mapIndexed((index, field) {
          var validators = field
              .annotationsOf<FieldValidator>()
              .where((e) {
            var applicable = e.isApplicable(structure, field);
            if (applicable) {
              _hasValidation = true;
            } else {
              print("$e is not applicable for $field in $structure");
            }
            return applicable;
          })
              .map((e) => MapEntry(e, e.getCachedValue(structure, field)))
              .toList();
          return MapEntry(index, validators);
        }));
  }

  @override
  bool validate(T value, DogEngine engine) {
    if (!_hasValidation) return true;
    return !_cachedFieldValidators.entries.any((pair) {
      var fieldValue = structure.proxy.getField(value, pair.key);
      return pair.value
          .any((e) => !e.key.validate(e.value, fieldValue, engine));
    }) &&
        !_cachedClassValidators.entries
            .any((e) => !e.key.validate(e.value, value, engine));
  }
}