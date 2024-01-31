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

import "package:conduit_open_api/v3.dart";
import "package:dogs_core/dogs_core.dart";
import "package:meta/meta.dart";

abstract class DogConverter<T> extends TypeCapture<T> {
  final bool isAssociated;
  final bool keepIterables;
  final DogStructure<T>? struct;

  const DogConverter(
      {this.struct, this.isAssociated = true, this.keepIterables = false});

  OperationMode<T>? resolveOperationMode(Type opmodeType) => null;

  /// Describes the converts output using openapi3 component specs.
  APISchemaObject get output => APISchemaObject.empty();
}

/// See @[serializable].
class Serializable {
  const Serializable();
}

/// Marks a library import as dogs serializable.
///
/// All types defined inside or exported by the library will be considered
/// serializable. The [include] and [exclude] parameters can be used to
/// further restrict the set of serializable types.
///
/// Types that semantically match a structure conformity or compatibility check must also be
/// correct, invalid items will not be skipped but throw an exception. You must explicitly exclude
/// types that are not serializable using the [exclude] parameter, or only include types that are
/// serializable using the [include] parameter.
///
/// For built_value types, the not serializable builder will automatically be excluded, but will be
/// used for the generation of the actual type converter.
class SerializableLibrary {
  /// A list of regex patterns that match the type identifiers to include in the serialization.
  final List<String>? include;

  /// A list of regex patterns that match the type identifiers to exclude from the serialization.
  final List<String>? exclude;
  const SerializableLibrary({this.include, this.exclude});
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

@internal
class LinkSerializer {
  const LinkSerializer();
}

/// Manually marks a custom dog converter implementation for linking.
/// The dogs_generator will then include an instance of this converter.
const linkSerializer = LinkSerializer();

class _BeanIgnore {
  const _BeanIgnore();
}

/// Marks a property as ignored when using the bean conformity.
const beanIgnore = _BeanIgnore();

/// Marks a property as polymorphic, meaning its values type can vary.
class _Polymorphic extends StructureMetadata {
  const _Polymorphic();
}

/// Marks a property as polymorphic, meaning its value's type can vary.
const polymorphic = _Polymorphic();

@internal
/// Checks if a field is marked as polymorphic.
bool isPolymorphicField(DogStructureField field) {
  return field.annotationsOf<_Polymorphic>().isNotEmpty;
}

/// Overrides the name that will be used by the [GeneratedDogConverter] for this
/// specific property. By default, the field name will be used.
class PropertyName {

  /// The name of the property used as a map key in serialization.
  final String name;

  /// Instantiates a new [PropertyName] with the given [name].
  const PropertyName(this.name);
}

/// Overrides the serializer that will be used by the [GeneratedDogConverter]
/// for this specific property. By default, the field will be serialized using
/// the convert associated with its type.
class PropertySerializer {

  /// The type of the serializer.
  final Type type;

  /// Instantiates a new [PropertySerializer] with the given [type].
  const PropertySerializer(this.type);
}

/// Simple converter base that only requires a [serialize] and [deserialize]
/// method. Automatically adds [NativeSerializerMode] and [GraphSerializerMode]s,
/// as well as a synthetic [DogStructure] with the given [SimpleDogConverter.serialName].
abstract class SimpleDogConverter<T> extends DogConverter<T>
    with OperationMapMixin<T> {

  /// Instantiates a new [SimpleDogConverter] with the given [serialName].
  /// Specify the [serialName] using `: super(serialName: "")`.
  SimpleDogConverter({required String serialName})
      : super(struct: DogStructure<T>.synthetic(serialName));

  @override
  Map<Type, OperationMode<T> Function()> get modes => {
        NativeSerializerMode: () => NativeSerializerMode.create(
            serializer: (value, engine) => serialize(value, engine),
            deserializer: (value, engine) => deserialize(value, engine)),
        GraphSerializerMode: () => GraphSerializerMode.auto(this)
      };

  /// Serializes the given [value] to a [DogNativeCodec] native value.
  dynamic serialize(T value, DogEngine engine);

  /// Deserializes the given [value] from a [DogNativeCodec] native value.
  T deserialize(dynamic value, DogEngine engine);
}
