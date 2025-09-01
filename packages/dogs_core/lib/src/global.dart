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

import "package:collection/collection.dart";
import "package:dogs_core/dogs_core.dart";
import "package:meta/meta.dart";

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

/// Compares two types by their hashcodes.
@internal
int compareTypeHashcodes(Type a, Type b) => a.hashCode.compareTo(b.hashCode);

/// Entrypoint for enabling and configuring a [DogEngine].
///
/// You can provide a list of [DogPlugin]s, which will be applied in the given order.
/// If [global] is true (default), the configured engine will be set as the global
/// singleton and can be accessed via [dogs].
DogEngine configureDogs({
  required List<DogPlugin> plugins,
  bool global = true,
}) {
  final engine = DogEngine();
  for (var plugin in plugins) {
    plugin(engine);
  }
  if (global) {
    engine.setSingleton();
  }
  return engine;
}
