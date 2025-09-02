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

import "package:dogs_core/src/structure/structure.dart";

/// Method proxy provider for [DogStructure]s.
/// A structure proxy must provided instantiation/"activation" for the object
/// and property accessor methods for all fields defined by the structure.
/// A get-all method for faster field value retrieval must also be provided.
abstract class DogStructureProxy {
  /// Creates a new [DogStructureProxy].
  const DogStructureProxy();

  /// Optional generated hash function created by the dogs_generator.
  abstract final int Function(dynamic obj)? hashFunc;

  /// Optional generated equals function created by the dogs_generator.
  abstract final bool Function(dynamic a, dynamic b)? equalsFunc;

  /// Creates a new instance of the structure.
  dynamic instantiate(List<dynamic> args);

  /// Accesses a field of the structure.
  dynamic getField(dynamic obj, int index);

  /// Shortcut method for collecting all field values in a single call.
  List getFieldValues(dynamic obj);
}

/// Simple class-less implementation of [DogStructureProxy], primarily for tests.
class MemoryDogStructureProxy extends DogStructureProxy {
  /// Creates a new [MemoryDogStructureProxy].
  const MemoryDogStructureProxy();

  @override
  dynamic instantiate(List args) => args;

  @override
  dynamic getField(obj, int index) {
    return obj[index];
  }

  @override
  List getFieldValues(obj) {
    return obj;
  }

  @override
  bool Function(dynamic a, dynamic b)? get equalsFunc => null;

  @override
  int Function(dynamic obj)? get hashFunc => null;
}

/// Simple class-less implementation of [DogStructureProxy], that serializes to
/// a string keyed field map.
class FieldMapStructureProxy extends DogStructureProxy {
  /// Ordered list of the field names of the structure.
  final List<String> fieldNames;

  /// Simple class-less implementation of [DogStructureProxy], that serializes to
  /// a string keyed field map.
  const FieldMapStructureProxy(this.fieldNames);

  @override
  dynamic instantiate(List args) => Map<String, dynamic>.fromIterables(fieldNames, args);

  @override
  dynamic getField(obj, int index) {
    return obj[fieldNames[index]];
  }

  @override
  List getFieldValues(obj) {
    return fieldNames.map((e) => obj[e]).toList();
  }

  @override
  int Function(dynamic obj)? get hashFunc => null;

  @override
  bool Function(dynamic a, dynamic b)? get equalsFunc => null;
}

/// [DogStructureProxy] implementation for creating universal object factories.
class ObjectFactoryStructureProxy<T> extends DogStructureProxy {
  /// Factory method for instantiating [T] using a sorted list of field values.
  final T Function(List args) activator;

  /// Accessor methods for all indexed fields of the [DogStructure] for type [T].
  final List<dynamic Function(T obj)> getters;

  /// Shortcut method for collecting all field values in a single call.
  final List Function(T obj) values;

  /// Optional generated hash function created by the dogs_generator.
  final int Function(T obj)? $hashFunc;

  /// Optional generated equals function created by the dogs_generator.
  final bool Function(T a, T b)? $equalsFunc;

  @override
  bool Function(dynamic a, dynamic b)? get equalsFunc => (a, b) => $equalsFunc!(a, b);

  @override
  int Function(dynamic obj)? get hashFunc => (obj) => $hashFunc!(obj);

  /// [DogStructureProxy] implementation for creating universal object factories.
  const ObjectFactoryStructureProxy(this.activator, this.getters, this.values,
      [this.$hashFunc, this.$equalsFunc]);

  @override
  dynamic getField(dynamic obj, int index) {
    return getters[index](obj);
  }

  @override
  dynamic instantiate(List args) {
    return activator(args);
  }

  @override
  List getFieldValues(obj) {
    return values(obj);
  }
}

/// Hook that runs after a structure [T] has been rebuilt.
abstract class PostRebuildHook<T> {
  /// Hook that runs after a structure [T] has been rebuilt.
  const PostRebuildHook();

  /// Runs after [from] has been rebuilt into [to];
  void postRebuild(T from, T to);
}
