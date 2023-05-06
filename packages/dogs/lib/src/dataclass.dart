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
import 'package:meta/meta.dart';

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

/// Changes if [Dataclass]es lazily cache their deep hashCode.
/// Significantly speeds up high-volume comparisons between similar Dataclasses but
/// increases memory overhead.
bool cacheDataclassHashCodes = true;

/// Static [DeepCollectionEquality] instance used by the dog library.
const DeepCollectionEquality deepEquality = DeepCollectionEquality();

Map<Type, int Function(dynamic)> _dataclassHashCode = {};
Map<Type, bool Function(dynamic,dynamic)> _dataclassEquals = {};

int Function(dynamic) _createDataclassHashCodeProvider<T>() {
  var structure = dogs.structures[T]!;
  var fieldCount = structure.fields.length;
  var proxy = structure.proxy;
  int Function(dynamic) provider;
  if (proxy.hashFunc == null) {
    provider = (obj) {
      var h = 0;
      for (var i = 0; i < fieldCount; i++) {
        var fieldValue = proxy.getField(obj, i);
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

bool Function(dynamic,dynamic) _createDataclassEqualityProvider<T>() {
  var structure = dogs.structures[T]!;
  var proxy = structure.proxy;
  bool Function(dynamic,dynamic) provider;
  if (proxy.equalsFunc == null) {
    provider = (a,b) {
      var va = proxy.getFieldValues(a);
      var vb = proxy.getFieldValues(b);
      return deepEquality.equals(va, vb);
    };
  } else {
    provider = proxy.equalsFunc!;
  }
  _dataclassEquals[T] = provider;
  return provider;
}

mixin Dataclass<T> {
  bool get isValid => DogEngine.instance.validateObject(this, T);
  void validate() => DogEngine.instance.validate<T>(this as T);

  @override
  String toString() {
    return "$T ${DogEngine.instance.convertObjectToGraph(this, T).coerceString()}";
  }

  int? _cachedHashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! T) return false;
    if (cacheDataclassHashCodes && hashCode != other.hashCode) return false;
    var equalityProvider = _dataclassEquals[T];
    equalityProvider ??= _createDataclassEqualityProvider<T>();
    return equalityProvider(this,other);
  }

  @override
  int get hashCode {
    if (cacheDataclassHashCodes) {
      var cv = _cachedHashCode;
      if (cv != null) return cv;
      var hashCodeProvider = _dataclassHashCode[T];
      hashCodeProvider ??= _createDataclassHashCodeProvider<T>();
      var computed = hashCodeProvider(this);
      _cachedHashCode = computed;
      return computed;
    } else {
      var hashCodeProvider = _dataclassHashCode[T];
      hashCodeProvider ??= _createDataclassHashCodeProvider<T>();
      return hashCodeProvider(this);
    }
  }
}