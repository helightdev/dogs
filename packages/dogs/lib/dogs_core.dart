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

export 'src/converters/common.dart';
export 'src/converters/enum.dart';
export 'src/converters/polymorphic.dart';
export 'src/converters/structure.dart';

export 'src/dataclass/builder.dart';
export 'src/dataclass/copyable.dart';
export 'src/dataclass/validatable.dart';

export 'src/schema/schema.dart';
export 'src/schema/visitor.dart';

export 'src/structure/field.dart';
export 'src/structure/proxy.dart';
export 'src/structure/structure.dart';
export 'src/structure/validator.dart';

export 'src/visitors/null_exclusion.dart';
export 'src/visitors/string_keyed.dart';

export 'src/async.dart';
export 'src/converter.dart';
export 'src/engine.dart';
export 'src/extensions.dart';
export 'src/global.dart';
export 'src/graph_value.dart';
export 'src/json.dart';
export 'src/serializer.dart';
export 'src/visitor.dart';

/// Static instance of [DogEngine] that will be initialised by invoking
/// the generated initialiseDogs() method.
DogEngine get dogs => DogEngine.instance;

/// Marks a class or enum as serializable.
/// The dogs_generator will then generate a [DefaultStructureConverter] which
/// also implements [Copyable] and [Validatable]. The generator will also
/// generate an implementation of [Builder] for the given type with the suffix
/// 'Builder' appended to the original class name.
///  Annotated types must match following conditions:
/// 1. Have a primary constructor or a secondary constructor
/// named 'dog' with only positional parameters.
/// 2. All constructor parameters must be field references. (this.fieldName)
/// 3. All fields specified in the eligible constructor must be serializable
/// using a converter or must be of type String, int, double or boolean.
class Serializable {
  const Serializable();
}

/// Marks a class or enum as serializable.
/// The dogs_generator will then generate a [DefaultStructureConverter] which
/// also implements [Copyable] and [Validatable]. The generator will also
/// generate an implementation of [Builder] for the given type with the suffix
/// 'Builder' appended to the original class name.
///  Annotated types must match following conditions:
/// 1. Have a primary constructor or a secondary constructor
/// named 'dog' with only positional parameters.
/// 2. All constructor parameters must be field references. (this.fieldName)
/// 3. All fields specified in the eligible constructor must be serializable
/// using a converter or must be of type String, int, double or boolean.
const serializable = Serializable();

/// Manually marks a custom dog converter implementation for linking.
/// The dogs_generator will then include an instance of this converter.
class LinkSerializer {
  const LinkSerializer();
}

/// Manually marks a custom dog converter implementation for linking.
/// The dogs_generator will then include an instance of this converter.
const linkSerializer = LinkSerializer();

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

/// Marks a property as polymorphic, meaning its values type can vary.
class Polymorphic {
  const Polymorphic();
}

/// Marks a property as polymorphic, meaning its values type can vary.
const polymorphic = Polymorphic();

/// Common iterable kinds which are compatible with dogs.
enum IterableKind { list, set, none }
