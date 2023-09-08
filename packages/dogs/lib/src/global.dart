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

/// Static instance of [DogEngine] that will be initialised by invoking
/// the generated initialiseDogs() method.
DogEngine get dogs => DogEngine.instance;

/// Changes if [Dataclass]es lazily cache their deep hashCode.
/// Significantly speeds up high-volume comparisons between similar Dataclasses but
/// increases memory overhead.
bool kCacheDataclassHashCodes = true;

/// Changes if polymorphic terminal nodes inferred for type trees print warnings on
/// creation in debug mode.
bool kWarnPolymorphicTerminalNode = true;

/// Static [DeepCollectionEquality] instance used by the dog library.
const DeepCollectionEquality deepEquality = DeepCollectionEquality();

/// Encodes this [value] to json, using the [DogConverter] associated with [T].
String toJson<T>(T value) => DogEngine.instance.jsonEncode<T>(value);

/// Decodes this [json] to an [T] instance, using the [DogConverter] associated with [T].
T fromJson<T>(String json) => DogEngine.instance.jsonDecode(json);

/// Converts an [T] instance to a native value, using the [DogConverter] associated with [T].
/// Output follows the default [DogNativeCodec] implementation, [DefaultNativeCodec].
dynamic toNative<T>(T value) =>
    DogEngine.instance.convertObjectToNative(value, T);

/// Converts an a native value to an [T] instance, using the [DogConverter] associated with [T].
/// Input must follow the default [DogNativeCodec] implementation, [DefaultNativeCodec].
T fromNative<T>(dynamic native) =>
    DogEngine.instance.convertObjectFromNative(native, T);

/// Creates a projection resulting in an instance of [T]. All input fields are dynamic and contain following:
/// 1. Serializable Object (which is then converted to a field map)
/// 2. String Keyed Maps
/// 3. Iterables containing
T project<T>(Object value, [Object? a, Object? b, Object? c]) =>
    DogEngine.instance.project<T>(value, a, b, c);

@internal
int compareTypeHashcodes(Type a, Type b) => a.hashCode.compareTo(b.hashCode);

@internal
Map<Type, StructureOperationModeFactory> structureOperationFactories = {};

void registerStructureOperationFactory(StructureOperationModeFactory factory) {
  structureOperationFactories[factory.typeArgument] = factory;
}
