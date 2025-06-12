# Annotations

Dogs make strong use of annotations to generate code for you and to add functionality to your
classes and fields. Even though some annotations only work by using the code generator, many are
also available for use without code generation at runtime.

To achieve this extensibility without directly depending on the code generator, dogs retains
all annotations implementing `StructureMetadata` in the structure definition. This is accomplished
by reconstructing the constructor call of the annotation using the code_generator and the lyell
companion library.

## Validation

Validation is one of the features of dogs that makes heavy use of retained annotations.
All annotation validators are created by making the annotation class extend `StructureMetadata` and
implement `FieldValidator` or `ClassValidator`. When constructing the validation mode for the
generated structure, the field annotations are collected and the individual validators are created.

## Converter Supplier

Using the `ConverterSupplyingVisitor` interface, you can supply a converter for the annotated field.

## Code Examples

``` { .dart title="Getting a single field annotation" }
DogStructureField field; /* Get field here*/
final supplier = field.firstAnnotationOf<ConverterSupplyingVisitor>();
if (supplier != null) {
  return supplier.resolve(structure, field, engine);
}
```

``` { .dart title="Getting multiple class annotations"}
DogStructure structure; /* Get structure here*/
var classValidators = structure.annotationsOf<ClassValidator>().toList();
```

## Hooks
### Field Hooks

Field hooks enable fine-grained control over the serialization of individual fields.
They are implemented by mixing in the `FieldSerializationHook` interface on a
class that also implements `StructureMetadata`.

Field hooks are executed for structure converters when using the `NativeSerializerMode`.
They receive the field context and are able to modify the serialized map after a
field has been serialized as well as before it is deserialized.

``` {.dart title="Field Serialization Hook Example" }
class MultiplyByTwo extends StructureMetadata with FieldSerializationHook {
  const MultiplyByTwo();

  @override
  void postFieldSerialization(
      NativeStructureContext context,
      NativeStructureFieldContext fieldContext,
      Map<String, dynamic> map,
      DogEngine engine) {
    final value = map[fieldContext.key] as int?;
    if (value != null) map[fieldContext.key] = value * 2;
  }

  @override
  void beforeFieldDeserialization(
      NativeStructureContext context,
      NativeStructureFieldContext fieldContext,
      Map<String, dynamic> map,
      DogEngine engine) {
    final value = map[fieldContext.key] as int?;
    if (value != null) map[fieldContext.key] = value ~/ 2;
  }
}
```

The hook can then be applied to a field like any other annotation:

``` { .dart .focus hl_lines="4-5" }
@serializable
class Example with Dataclass<Example> {

  @MultiplyByTwo()
  int number;

  Example(this.number);
}
```

### Structure Hooks

Structure hooks operate on the entire serialized map of a class. They are implemented by extending the
`SerializationHook` class or implementing it. You can apply them to a structure by annotating the class with the
annotation that extends `SerializationHook`.

Structure hooks are executed for structure converters when using the `NativeSerializerMode`.
They receive the full structure map and can freely modify it before deserialization or after serialization.


``` {.dart title="Structure Serialization Hook Example" }
class ExampleHook extends SerializationHook {
  const ExampleHook();

  @override
  void beforeDeserialization(
      Map<String, dynamic> map,
      DogStructure structure,
      DogEngine engine) {
    map['decoded_at'] ??= DateTime.now().toIso8601String();
  }

  @override
  void postSerialization(
      dynamic obj,
      Map<String, dynamic> map,
      DogStructure structure,
      DogEngine engine) {
    map['encoded_at'] ??= DateTime.now().toIso8601String();
  }
}
```