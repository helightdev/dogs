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
Operation modes are always resolved through the engine's `OperationModeRegistry`. This registry serves
as a central cache and mapping from converters and types to operation mode entries. Child engines
will always have their independent operation mode registry.

Operation modes are always first looked up in the registry. For misses, the registry will first try to resolve
the operation mode through the converter itself. If the converter does not provide the requested
operation mode, the registry will try to infer the operation mode using the `OperationModeFactory`s registered in
the current engine instance.

## Examples
### NativeSerializerMode
The native operation mode is the most basic operation mode. It is used to serialize and deserialize
objects to and from dart maps that can be directly serialized to JSON. Most of the dogs library
is built around this operation mode.

### ValidationMode
The validation operation mode is used to validate objects. It is used by the `@validate` annotation
and can be used to validate objects before they are serialized, or to validate objects that have
been deserialized.