# 5. Polymorphism
DOGs supports polymorphism on a per-field basis. This means that you can have a field with any type
you want, as long as all leaf types are serializable. If you want to use polymorphism, you need to
add the `@polymorphic` annotation - This is required so you don't accidentally use polymorphism
without knowing it.

!!! warning "Abstract classes and interfaces can't be annotated with @serializable"
    You only need to annotate leaf classes with `@serializable`. Abstract classes and interfaces
    can't be instantiated and therefore can't use automatic structure generation, for which
    `@serializable` is the marker.

    Therefore: Only annotate leaf types with `@serializable`.

!!! warning "Limitations"
    All leaf types must be serializable. This means that you can use `dynamic` or `Object` as long as
    the actual runtime type is serializable i.E. the runtime type is associated with a structure definition
    and has a converter.

## Discriminator
To identity a leaf type in a polymorphic field, DOGs uses a `_type` discriminator, that is added
to the serialized data of the object in question. If the leaf object is not a map, tha value will
be wrapped in a map and stored in the `_value` field.

## When do I need to use @polymorphic?
If all leaf node of your fields type tree are concrete classes, or have an associated structure
and converter, you don't need to use `@polymorphic`.

| Type                        | Polymorphic?       | Explanation                                                                   |
|-----------------------------|--------------------|-------------------------------------------------------------------------------|
| `int`                       | :x:                | `int` is a serializable class and therefore does not need to be annotated.    |
| `List<int>`                 | :x:                | `int` is a serializable class and therefore does not need to be annotated.    |
| `List<Animal>`              | :white_check_mark: | `Animal` is an abstract class and therefore needs to be annotated.            |
| `List<Object>`              | :white_check_mark: | `Object` is an abstract class and therefore needs to be annotated.            |
| `Map<String,String>`        | :x:                | All leaf types are serializable classes therefore no annotation is required.  |
| `Map<String,Animal>`        | :white_check_mark: | `Animal` is an abstract class and therefore needs to be annotated.            |
| `Map<String,Object>`        | :white_check_mark: | `Object` is an abstract class and therefore needs to be annotated.            |
| `Map<String,Person>`        | :x:                | `Person` is a serializable class and therefore does not need to be annotated. |
| `Map<String, List<String>>` | :x:                | All leaf types are serializable classes therefore no annotation is required.  |



## Examples
```dart title="Sealed Classes"
sealed class Animal {}

@serializable
class Dog extends Animal {
  String name;
  int age;
  
  Dog(this.name, this.age);
}

@serializable
class Dolphin extends Animal {
  bool isNamedFlipper;
  
  Dolphin(this.isNamedFlipper);
}

@serializable
class Zoo {
  @polymorphic
  List<Animal> animals;
  
  Zoo(this.animals);
}
```

```dart title="Object Field"
@serializable
class Person {
  String name;
  
  @polymorphic
  Object attachment;
  
  Person(this.name, this.attachment);
}

```

[Continue Reading! :material-arrow-right:](/converters/){ .md-button .md-button--primary }