# Structures

The code generator generates a `DogStructure` definition for every serializable class.
These definitions are used by the `DefaultStructureConverter` to create the operation modes
for the individual class.

By default, they are generated by the dogs code generator for all serializable classes, but they
can also be manually created and registered. This is useful when you want to write a custom
converter for a foreign class. For simple type registrations without any structural information,
you can use the synthetic `DogStructure` factory, to just create a structure for a given type together
with a serial name.

## Structure Properties
A generated or manually created `DogStructure` has following properties:

- `serialName`: The name of the class when serialized. Primarily used for polymorphic serialization.
- `type`: The type of the class, obtained via a `TypeCapture<T>`.
- `annotations`: A list of retained annotations for this field.  
  Annotations are retained by the code generator and can be used to provide additional information
  about the field or expand the functionality of the structure.
- `proxy`: A proxy object for the class.  
  The proxy object is used to create instances of the class and to access the fields of the class.
- `fields`: A list of `DogField` definitions for each field of the class.

??? abstract "Terminology: Retained Annotations"

    **Retained Annotations** are datastructures defined by the companion 'lyell' package, that are used
    to represent annotations at runtime. Retained annotations are, like the name suggests, retained
    by the code generator and can be accessed via the generated `DogStructure`.

    All classes which can be used as annotations can also be retained, if they are not private to
    the library they are defined in and implement the corrsesponding interface. For retained structure
    annotations, this means that they have to implement `StructureMetadata`.

## Structure Proxies
Structure proxies provide following functionality:

- `instantiate`: Creates an instance of the structure with the given arguments.
- `getField`: Gets the value of a single field of a given structure instance.
- `getFieldValues`: Gets the values of all fields of a given structure instance.

When using a dataclass conform structure, the proxy also defined following properties:

- `hashFunc`: A function that calculates the hash of a given structure instance.
- `equalsFunc`: A function that checks whether two structure instances are equal.


## Field Serialization

How a field is serialized depends on the operation mode of the structure converter and the
type of the field as well as the field properties. For all builtin serialization modes, the 
`StructureHarbinger` decides the mapping of the field to a converter, which is then used
to retrieve the operation mode for the field.

!!! info "Converter Resolution Priorities"
    
    Annotation Supplied > Converter Overrides > Native Type > Direct Converter >
    Serial Converter > Tree Converter.

??? abstract "Terminology: Direct Converter"

    A converter mapping is direct, if it can directy serialize a specific type without
    the need for iterable transformation or tree conversion. If a converter is associated
    to the type `List<Person>`, it can directly serialize this type and the harbing
    will not try to find a tree converter for `Person`.

??? abstract "Terminology: Serial Converter"

    Serial converters and tree converters are similar, in that they both serialize collection types.
    Though **a tree converter is more powerful** and can also be used for other types than dart native ones
    and with deeper nesting. Serial converters **support only lists and sets** of serializable types and
    are **not able to serialize polymorphic types**. Every dart converter is by default able to handle
    serial conversion through the "{mode}Iterable" methods on the respective operation modes. This
    behaviour can be turned off by using the `keepIterables` option on the converter.
    
    For graph and native operation modes, this includes the creation of a `TypeTree` based converter
    structure for each individual field. These individual tree converters are then used by the structure
    converter to serialize the whole class.

## Type Tree Resolution

The following flowchart shows the structure serialization process for a single field's type tree:
``` mermaid
graph LR
  A[TypeTree] --> B;
  B{Is Terminal?} -->|Yes| C;
  C{Is Native?} --> |Yes|D[Retain value];
  C --> |No| E;
  E{Has associated DogConverter?} --> |Yes| F;
  E --> |No| G[Polymorphic Serializer];
  B --> |No| H;
  H{Has associated DogConverter?} ---> |Yes| F[Use Converter];
  H --> |No| I;
  I{Has associated TreeConverter?} --> |Yes| J;
  J[Use TreeConverter] ----> |Potentially for type arguments| A;
  I --> |No| K[Throw Exception];
```

??? abstract "Terminology: Type Trees"

    **TypeTrees** are datastructures defined by the companion 'lyell' package, that are used
    to represent arbitrary dart types. They are commonly generated by the dogs code generator and
    have following properties:

    - `base`: The base type of the represented type, represented by a `TypeCapture<T>`
    - `typeArguments`: The type arguments of the represented type, represented by another `TypeTree<T>` 

    additionally to to these properties, `QualifiedTypeTrees` also have the `TypeCapture<T>` property
    `qualified` representing the fully qualified type of this subtree which is used
    for type checks and casting. Dogs uses these qualified type trees to represent the field types.
    QualifiedTypeTrees are also necessary for TreeConverters.

!!! question "Is Load-Order Important? "
    The structure converter is **lazily loaded**, meaning that it only generates the tree converter's
    operation mode **when it is first used**. This is done to prevent unnecessary load times and
    time-coupling in the initialization.

    This means that the order in which you define your serializable classes is **not important**.

## Field Properties
Additionally to the type of the field, the structure also stores following properties for each field:

- `name`: The name of the field when serialized
- `optional`: Whether the field is nullable or not
- `structure`: Whether the field is a structure or not
- `converterType?`: Defines a converter override for this field
- `iterableKind`: Defines the kind of iterable this field is.  
    This can be `List`, `Set`, `Iterable` and `None`. Custom collection types can be handled
    via tree converters but are not included in the structure definition and have to be derived
    from the type tree.
- `annotations`: A list of retained annotations for this field.  
    Annotations are retained by the code generator and can be used to provide additional information
    about the field or expand the functionality of the structure.