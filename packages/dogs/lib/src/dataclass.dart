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

import "dart:collection";

import "package:dogs_core/dogs_core.dart";

/*
Note: This dataclass implementation is pretty optimised for being runtime-only
if you ignore the data that is collected through the structure generator. The
hashcode and equality providers would be slightly faster if you would use a
generated mixin instead of structure analysis, but that would defeat
the zero-boilerplate goal.

The performance overhead is pretty much:
- Map lookup (Type key)
- Proxied accessor value lookups
 */

Map<Type, int Function(dynamic)> _dataclassHashCode = HashMap();
Map<Type, bool Function(dynamic, dynamic)> _dataclassEquals = HashMap();

int Function(dynamic) _createDataclassHashCodeProvider<T>() {
  final structure = dogs.findStructureByType(T)!;
  final fieldCount = structure.fields.length;
  final proxy = structure.proxy;
  late final int Function(dynamic) provider;
  if (proxy.hashFunc == null) {
    provider = (obj) {
      var h = 0;
      for (var i = 0; i < fieldCount; i++) {
        final fieldValue = proxy.getField(obj, i);
        if (fieldValue is Iterable || fieldValue is Map) {
          h ^= deepEquality.hash(fieldValue);
        } else {
          h ^= fieldValue.hashCode;
        }
      }
      return h;
    };
  } else {
    provider = proxy.hashFunc!;
  }
  _dataclassHashCode[T] = provider;
  return provider;
}

bool Function(dynamic, dynamic) _createDataclassEqualityProvider<T>() {
  final structure = dogs.findStructureByType(T)!;
  final proxy = structure.proxy;
  late final bool Function(dynamic, dynamic) provider;
  if (proxy.equalsFunc == null) {
    provider = (a, b) {
      final va = proxy.getFieldValues(a);
      final vb = proxy.getFieldValues(b);
      return deepEquality.equals(va, vb);
    };
  } else {
    provider = proxy.equalsFunc!;
  }
  _dataclassEquals[T] = provider;
  return provider;
}

mixin Dataclass<T> {
  /// Returns true if this object is valid.
  /// Does not throw any exceptions if the object is invalid.
  bool get isValid => DogEngine.instance.validateObject(this, T);

  /// Throws an exception if this object is invalid.
  void validate() => DogEngine.instance.validate<T>(this as T);

  @override
  String toString() {
    try {
      return "$T ${DogEngine.instance.convertObjectToGraph(this, T).coerceString()}";
    } catch (e,st) {
      assert((){
        print("Error in Dataclass toString(): $e:\n$st");
        return true;
      }());
      return "$T ${DogEngine.instance.findStructureByType(T)!.getFieldMap(this)}";
    }
  }

  int? _cachedHashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! T) return false;
    if (kCacheDataclassHashCodes && hashCode != other.hashCode) return false;
    var equalityProvider = _dataclassEquals[T];
    equalityProvider ??= _createDataclassEqualityProvider<T>();
    return equalityProvider(this, other);
  }

  @override
  int get hashCode {
    if (kCacheDataclassHashCodes) {
      final cv = _cachedHashCode;
      if (cv != null) return cv;
      var hashCodeProvider = _dataclassHashCode[T];
      hashCodeProvider ??= _createDataclassHashCodeProvider<T>();
      final computed = hashCodeProvider(this);
      _cachedHashCode = computed;
      return computed;
    } else {
      var hashCodeProvider = _dataclassHashCode[T];
      hashCodeProvider ??= _createDataclassHashCodeProvider<T>();
      return hashCodeProvider(this);
    }
  }
}
