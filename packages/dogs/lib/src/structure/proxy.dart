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

import 'package:dogs_core/src/structure/structure.dart';

abstract class DogStructureProxy {
  const DogStructureProxy();

  /// Creates a new instance of the structure.
  dynamic instantiate(List<dynamic> args);

  /// Accesses a field of the structure.
  dynamic getField(dynamic obj, int index);
}

/// Simple class-less implementation of [DogStructureProxy], primarily for tests.
class MemoryDogStructureProxy extends DogStructureProxy {
  const MemoryDogStructureProxy();

  @override
  dynamic instantiate(List args) => args;

  @override
  dynamic getField(obj, int index) {
    return obj[index];
  }
}

/// [DogStructureProxy] implementation for creating universal object factories.
class ObjectFactoryStructureProxy<T> extends DogStructureProxy {
  /// Factory method for instantiating [T] using a sorted list of field values.
  final T Function(List args) activator;

  /// Accessor methods for all indexed fields of the [DogStructure] for type [T].
  final List<dynamic Function(T obj)> getters;

  /// [DogStructureProxy] implementation for creating universal object factories.
  const ObjectFactoryStructureProxy(this.activator, this.getters);

  @override
  dynamic getField(dynamic obj, int index) {
    return getters[index](obj);
  }

  @override
  dynamic instantiate(List args) {
    return activator(args);
  }
}
