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

/// Property level validator for annotations of [DogStructureField]s.
abstract class FieldValidator {
  const FieldValidator();

  bool isApplicable(DogStructure structure, DogStructureField field) => true;
  dynamic getCachedValue(DogStructure structure, DogStructureField field);
  bool validate(dynamic cached, dynamic value);
}

/// Class level validator for annotations of [ClassValidator]s.
abstract class ClassValidator {
  const ClassValidator();

  bool isApplicable(DogStructure structure) => true;
  dynamic getCachedValue(DogStructure structure);
  bool validate(dynamic cached, dynamic value);
}

class ValidationException implements Exception {}
