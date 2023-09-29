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

## API Schema Visitor

Using the `APISchemaObjectMetaVisitor` interface, you can create a visitor that will be called
when the api schema is generated for a structure. 

## Converter Supplier

Using the `ConverterSupplyingVisitor` interface, you can create a converter supplying visitor that
can supply a converter for a given field.

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