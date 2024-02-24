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
import 'package:dogs_odm/dogs_odm.dart';
import 'package:uuid/uuid.dart';

import 'database.dart';

class MemoryOdmSystem extends OdmSystem<MemoryDatabase, String> {

  final Map<Type, MemoryDatabase> _databases = <Type, MemoryDatabase>{};

  @override
  late DogEngine engine;

  MemoryDatabase<T> _createDatabase<T extends Object>() {
    return MemoryDatabase<T>(this);
  }

  @override
  MemoryDatabase<T> getDatabase<T extends Object>([Repository? repository]) {
    return _databases.putIfAbsent(T, () => _createDatabase<T>())
        as MemoryDatabase<T>;
  }

  MemoryOdmSystem([DogEngine? engine]) {
    if (engine != null) {
      this.engine = engine;
    } else {
      this.engine = dogs.getChildOrFork(#memoryOdmSystem);
    }
  }

  @override
  String generateId<T extends Object>(T entity) {
    return const Uuid().v4();
  }

  @override
  String? transformId<FOREIGN>(FOREIGN? id) {
    switch (id) {
      case null:
        return null;
      case String():
        return id;
      case int():
        return id.toString();
      default:
        throw Exception('Unsupported type: ${id.runtimeType}');
    }
  }

  @override
  FOREIGN inverseTransformId<FOREIGN>(String id) {
    switch (FOREIGN) {
      case const (String):
        return id as FOREIGN;
      case const (int):
        return int.parse(id) as FOREIGN;
      default:
        throw Exception('Unsupported type: $FOREIGN');
    }
  }
}