# 1. Serializable Classes

To create a serializable class, just annotate it with `@serializable` and mixin
`Dataclass<T>`. The code generator will then generate the required structure definition of
your class.

!!! example "Explore Code Snippets"
    You can explore the code in codeblocks by expanding comments using the floating (+) button.

``` { .dart .annotate }
@serializable /*(1)!*/
class Person with Dataclass<Person> /*(2)!*/ {

  final String name;
  final int age;
  final Set<String>? tags; /*(3)!*/
  
  Person(this.name, this.age, this.tags); /*(4)!*/
  
}

@serialzable // (5)!
enum MyEnum { 
  a,b,c;
}
```

1. The serializable annotation is required to make a class serializable.
2. The dataclass mixin is optional but recommended, as it provides **equals**,
**hashCode** and **toString** implementations.
3. DOGs natively supports `List<T>` and `Set<T>` for any serializable type. While the field
itself is allowed to be null, the elements of the iterable must not be null.
If you require nested nullability, consider using the `Optional<T>` type.
4. You constructor must only reference serializable fields and must not be private.
You can also use a secondary constructor for serialization by naming it `dogs`.
5. You can also annotate enums to make them serializable.
Enum values will be serialized and deserialized as strings using their name.

## Conformities
Not every serializable class must be semantically equal to this dataclass example.
Besides the initially presented dataclass, DOGs also supports the following other
conformities:

=== "Dataclass"

    ``` dart
    @serializable
    class Person with Dataclass<Person> {
    
      final String name;
      final int age;
      final Set<String>? tags;
    
      Person(this.name, this.age, this.tags);
    }
    ```
    
    Dataclasses are the most common type of serializable classes. They are immutable
    and their fields should be final. They are also the only type of serializable class
    you should use when you require equality.

=== "Dataclass (named args)"

    !!! tip "Named Argument Constructors"
        You can also use named arguments with you dataclass constructor. This is especially useful
        when you have a lot of optional fields or many fields with the same type.

    ``` dart
    @serializable
    class Person with Dataclass<Person> {

      final String name;
      final int age;
      final Set<String>? tags;
    
      Person({
        required this.name,
        required this.age,
        this.tags
      });
    }
    ```

=== "Basic"

    ``` dart
    @serializable
    class Person {
    
      String name;
      int age;
      Set<String>? tags;
    
      Person(this.name, this.age, this.tags);
    }
    ```
    
    If you don't use the dataclass mixin, the generator will not generate equality and hashcode
    implementations for this structure and you will have to implement them yourself if required.
    Since the generator doesn't expect this class to be immutable, you can use mutable fields
    and setters with this type of serializable class.

=== "Beans"

    !!! danger "Prefer other conformities like Dataclass!"

    ``` dart
    @serializable
    class Person {
    
      late String name;
      int? age;
      Set<String>? tags;
    
      @beanIgnore
      late String ignored;
    
    }
    ```

    Beans are the most flexible but also the most error prone type of serializable class.
    Serializable fields must be mutable and have a public no-arg constructor.
    They are only intended for frameworks which benefit from such a structure for simplicity.
    
    To instantiate a bean, you should use the generated `{name}Factory` class with its 
    static `create` method.

## Restrictions
To make your serializable classes work with the serialization system, you must follow a few
restrictions (to read more about the restrictions, expand the region below).

??? failure "No Class-Level Generics"
    You cannot use generics on the class level. This is due to the fact that the generator
    generates a structure definition for your class, which erases all generic information which
    is not used in the fields of your class.  
    **Generics on fields are allowed, though!**

??? failure "Don't use Records"
    You cannot use records as field types. This is due to the fact that records can't be easily
    represented by the structure format and make the overall system more unnecessarily complex and
    possible generated model schemas obscure.

??? failure "Types inside Field-Generics can't be nullable"
    You cannot use generic field types with nullable type arguments, as the type tree does not
    store the nullability of the type arguments. If you require nullable items, consider using
    the `Optional<T>` type instead, which is a wrapper for nullable types.

    In practice, this means that you can't use `List<String?>` but you can use `List<Optional<String>>`.
  
    **The root type of the field can be nullable!**  
    `List<String>?` is perfectly fine without any changes.

??? success "All leaf types must be serializable"
    All fields of your serializable class must be **serializable recursively** themselves.
    For sealed classes for example, this means that all possible subclasses must be serializable. 
    This also means, that they need to be marked as `@serializable` if they don't have a custom
    converter registered.  
    See [Polymorphism](/polymorphism) for more information.

??? abstract "Terminology: Leaf Type"
    Objects which are possible terminal values of a type boundary are referred to as **leaf types**.
    In practice, this refers to the `runtimeType` of the object in question.

    If you have a field of type `Animal`, `Animal` is the type boundary and possible leaf types
    would be `Dog` or `Cat`. For DOGs, this would mean `Dog` and `Cat` need to be serializable.

## Modifications

You can use the automatically generated builder to modify serializable classes easily.
Depending on your prefer code style, you can use either the imperative or lambda builder.

=== "Lambda Builder"

    ```dart
    var built = person.rebuild((builder) => builder
      ..name = "Alex"
      ..age = 22
    );
    ```

=== "Imperative Builder"

    ```dart
    var builder = person.toBuilder();
    builder.name = "Günter";
    builder.age = 25;
    var obj = builder.build();
    ```

!!! note "Availability"
    The builder is only available for dataclasses and basic serializable classes.

[Continue Reading! :material-arrow-right:](/serialization/){ .md-button .md-button--primary }