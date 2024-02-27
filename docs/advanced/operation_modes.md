# Operation Modes
Operation modes are a relatively unique concept to the dogs serialization library. They are used to
provide different ways of consuming the auto-generated structure definitions.

All converters must implement `resolveOperationMode`. This function is used to lookup converter
specific operation modes, like the `NativeSerializerMode`.

To make handling the operation modes more intuitive, the `OperationMapMixin<T>` is provided.
It is used to provide a lookup table for operation modes.
```dart title="OperationMapMixin getter of the DateTimeConverter"
@override
Map<Type, OperationMode<DateTime> Function()> get modes => {
  NativeSerializerMode: () => NativeSerializerMode.create(
    serializer: (value, engine) => value.toIso8601String(),
    deserializer: (value, engine) => DateTime.parse(value)),
};
```

## Mode Registry
Operation modes are always resolved through the `OperationModeRegistry`. This registry serves
as a central cache and mapping from converters and types to operation mode entries. Child engines
will always have their independent operation mode registry.

!!! success "Modes do not need to be registered!"
    The registration is handled on the fly by the `OperationModeRegistry`. If a mode is not found
    in the registry, the registry will try to infer the operation mode using the `OperationModeFactory`

## Operation Mode Factories
If an operation mode is not found in the registry, the registry will try infer the operation mode
using the `OperationModeFactory` list of its engine. Those factories can provide operation modes
for converters that do not define the required operation modes themselves. Using this mechanism,
packages can provide operation modes for converters that are not under their control. This feature
is used by the `dogs_forms` package to provide operation modes for the `AutoFormFieldFactory`.

The `OperationModeFactory` class defines several static functions that can be used to create
and combine factories for specific converter or structure types.
```dart title="Default factory composition for dogs_forms"
final defaultFormFactories = OperationModeFactory.compose<AutoFormFieldFactory>([
  OperationModeFactory.converterSingleton<NativeRetentionConverter<String>,
      AutoFormFieldFactory>(const TextFieldFormFieldFactory()),
  // [...]
  ListFieldOperationModeFactory<String>(const TextFieldFormFieldFactory()),
  ListFieldOperationModeFactory<int>(const IntTextFieldFormFieldFactory()),
  // [...]
  EnumOpmodeFactory(),
  StructureOpmodeFactory(),
]);

```

## Examples
### NativeSerializerMode
The native operation mode is the most basic operation mode. It is used to serialize and deserialize
objects to and from dart maps that can be directly serialized to json. Most of the dogs library
is built around this operation mode.

!!! tip "Not only for serialization!"
    The operation modes are not only used to serialize and deserialize objects,
    but can also to provide additional functionality like validation and introspection.

### ValidationMode
The validation operation mode is used to validate objects. It is used by the `@validate` annotation
and can be used to validate objects before they are serialized, or to validate objects that have
been deserialized.

### AutoFormFieldFactory
While the name may be a bit misleading, the auto form field factory is also an operation mode that
is used to derive flutter form fields from structures.