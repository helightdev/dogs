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

library dogs_core;

import 'dogs_core.dart';

export 'src/async.dart';
export 'src/builder.dart';
export 'src/converter.dart';
export 'src/copyable.dart';
export 'src/engine.dart';
export 'src/extensions.dart';
export 'src/global.dart';
export 'src/graph_value.dart';
export 'src/json.dart';
export 'src/null_exclusion.dart';
export 'src/polymorphic.dart';
export 'src/serializer.dart';
export 'src/string_keyed.dart';
export 'src/structure.dart';
export 'src/visitor.dart';

/// Static instance of [DogEngine] that will be initialised by invoking
/// the generated initialiseDogs() method.
late DogEngine dogs;

/// Marks an object as serializable.
/// The dogs_generator will then generate an [GeneratedDogConverter] emitting
/// [StructureEmitter], [DogConverter] and [Copyable] instances for the
/// annotated type. Annotated types must match following conditions:
/// 1. Have a primary constructor
/// 2. All constructor parameters must be field references.
/// 3. All serialized fields must be serializable via a converter or
/// of the type String, int, double or boolean.
class Serializable {
  const Serializable();
}

/// Manually marks a custom dog converter implementation for linking.
/// The dogs_generator will then include an instance of this converter.
class LinkSerializer {
  const LinkSerializer();
}

/// Overrides the name that will be used by the [GeneratedDogConverter] for this
/// specific property. By default, the field name will be used.
class PropertyName {
  final String name;
  const PropertyName(this.name);
}

/// Overrides the serializer that will be used by the [GeneratedDogConverter]
/// for this specific property. By default, the field will be serialized using
/// the convert associated with its type.
class PropertySerializer {
  final Type type;
  const PropertySerializer(this.type);
}

/// Marks a property as polymorphic, meaning its value can vary
class Polymorphic {
  const Polymorphic();
}

/// Common iterable kinds which are compatible with dogs.
enum IterableKind { list, set, none }
