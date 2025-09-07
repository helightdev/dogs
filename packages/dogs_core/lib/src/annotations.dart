// TODO: Future replacement for @serializable
import "package:dogs_core/dogs_core.dart";
import "package:meta/meta.dart";

/// Configures the dogs structuration of a class or enum.
class Structure extends Serializable implements StructureMetadata {
  /// If the type is serializable.
  final bool serializable;

  /// Configures the dogs structuration of a class or enum.
  const Structure({this.serializable = false, super.serialName});
}

/// See @[serializable].
class Serializable {
  /// The name of the type used for serialization.
  final String? serialName;

  /// See @[serializable].
  const Serializable({this.serialName});
}

/// Marks a class or enum as serializable.
const serializable = Structure(serializable: true);

@internal
class DogLinked {
  const DogLinked();
}

/// Manually marks a custom dog converter implementation for linking.
/// The dogs_generator will then include an instance of this converter.
const linkSerializer = DogLinked();

/// Automatically links a [DogLinkable] object when running the generated
/// dogs plugin.
const dogsLinked = DogLinked();

/// Supplier function for default values.
typedef DefaultValueSupplier = dynamic Function();

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

/// Configures how the [GeneratedEnumDogConverter] will serialize this individual
/// enum value. The name can be overridden by specifying a [name]. This enum
/// value can also be marked as the fallback value.
class EnumProperty {
  /// The name of the enum value used as a map key in serialization.
  final String? name;

  /// If this enum value should be used as a fallback value when an invalid
  /// value is encountered during deserialization.
  final bool fallback;

  /// Instantiates a new [EnumProperty] with the given [name] and [fallback].
  const EnumProperty({this.name, this.fallback = false});
}