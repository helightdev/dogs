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
// ignore_for_file: invalid_use_of_internal_member

import 'package:darwin_marshal/darwin_marshal.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_darwin/dogs_darwin.dart';

class DogsMarshal {
  static void link(DarwinMarshal marshal, [DogEngine? engineOverride]) {
    var engine = engineOverride ?? DogEngine.internalSingleton!;
    engine.associatedConverters.forEach((key, value) {
      var collectionSerializer = DogsDarwinCollectionMapper(key, value, engine);
      marshal.registerTypeMapper(
          key, DogsDarwinSingleMapper(key, value, engine));
      marshal.registerTypeMapper(value.deriveList, collectionSerializer);
      marshal.registerTypeMapper(value.deriveSet, collectionSerializer);
    });
  }
}
