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

abstract class DogVisitor<T> {
  T visit(DogGraphValue v) {
    if (v is DogMap) return visitMap(v);
    if (v is DogList) return visitList(v);
    if (v is DogString) return visitString(v);
    if (v is DogInt) return visitInt(v);
    if (v is DogDouble) return visitDouble(v);
    if (v is DogBool) return visitBool(v);
    if (v is DogNull) return visitNull(v);
    return null as T;
  }

  T visitMap(DogMap m) => null as T;
  T visitList(DogList l) => null as T;
  T visitString(DogString s) => null as T;
  T visitInt(DogInt i) => null as T;
  T visitDouble(DogDouble d) => null as T;
  T visitBool(DogBool b) => null as T;
  T visitNull(DogNull n) => null as T;
}