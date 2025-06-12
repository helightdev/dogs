# Serializable Classes

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
4. You constructor must only reference serializable field and must not be private.
You can also use a secondary constructor for serialization by naming it `dogs`.
Non-formal fields can also be used if they have a backing getter of field with the same name.
5. You can also annotate enums to make them serializable.
Enum values will be serialized and deserialized as strings using their name.

## Conformities
Not every serializable class must be semantically equal to this dataclass example.
Besides the initially presented dataclass, DOGs also supports the following other
conformities:

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

## Field Variants
To not limit your creativity, DOGs supports multiple ways to define serializable fields.
This includes (super) formal parameters, which refer to fields and non-formal parameters which
have a backing field or getter with the same name. This list showcases all possible variants:

=== "Formal Parameter"

    ```dart
    @serializable
    class Entity with Dataclass<Person> {
    
      final String id;
      final String name;

      Entity(this.id, this.name);
    }
    ```

=== "Super Formal Parameter"

    ```dart
    @serializable
    class Entity extends Base with Dataclass<Person> {
    
      final String name;

      Entity({
        required super.id,
        required this.name
      });
    }
    ```

    !!! note "The super field can have annotations"
    ??? warning "The super parameter must have a formal base definition"
        The super parameter must end up as a formal parameter in the superclasses constructor.
        Recursive backing fields or getters are not allowed in this case.

=== "Backing Field"

    ```dart
    @serializable
    class Entity with Dataclass<Person> {
    
      final String id;

      Entity(String? id) : this.id = id ?? Uuid().v4();
    }
    ```

    !!! note "Annotations go on the field"
        Annotations for fields must be placed on the field itself, not on the constructor parameter.

=== "Backing Getter"

    ```dart
    @serializable
    class Entity with Dataclass<Person> {
    
      String? _id;

      Entity(String? id) {
        _id = id;
      }

      String get id => _id ??= Uuid().v4();
    }
    ```

    !!! note "Annotations go on the getter"
        Annotations for fields must be placed on the getter itself, not on the constructor parameter.

## Restrictions
To make your serializable classes work with the serialization system, you must follow a few
restrictions, some of them enforced by the code generator and some of them at runtime:

??? failure "No Class-Level Generics"
    You cannot use generics on the **class level**. This is because the default structure generator
    generates a **static structure definition** for your class once, having dynamically changing field types
    would make this definition invalid. If you require generics **for custom containers**, you can implement a
    a **tree base converter** for this class.

??? failure "Don't use Records"
    You cannot currently use records as field types, as the code generator does not support them.
    I plan on adding support for them sometime in the future though.

??? failure "Types inside Field-Generics can't be nullable"
    You **cannot use generic field types** with **nullable type arguments**, as the type tree does not
    store the nullability of the type arguments. If you require nullable items, consider using
    the `Optional<T>` type instead, which is a wrapper for nullable types.

    In practice, this means that you can't use `List<String?>` but you can use `List<Optional<String>>`.
  
    However, the **root type** of the field **can be nullable**: `List<String>?` is **perfectly fine** without any changes.

??? success "All types must be serializable"
    All fields of your serializable class must be **serializable recursively** themselves.
    For sealed classes for example, this means that **all possible subclasses** must be serializable. 
    This also means, that they need to be marked as `@serializable` if they don't have a custom
    converter registered.  

    See [Polymorphism](/basics/polymorphism) for more information.

??? success "Parameters must either be formal or have a backing member with the same name"
    All parameters of your constructor must either be **formal parameters** (this./super.) or have a
    **backing member with the same name**. This class member can either be a field or a getter.

## Modifications

You can use the automatically generated builder to modify serializable classes easily.
Depending on your prefer code style, you can use either the imperative or lambda builder.

=== "Copy"
    
    ```dart
    var updated = person.copy(
      name: "Alex",
      age: 22,
    );
    ```
    
    This method is similar to Kotlin's `copy` and `copyWith`s which are common in dart libraries. Parameters which
    aren't explicitly overridden retain their original values, allowing you to even set fields to null.

=== "Lambda Builder"

    ```dart
    var built = person.rebuild((builder) => builder
      ..name = "Alex"
      ..age = 22
    );
    ```

    This method is similar to built's builder implementation.

=== "Imperative Builder"

    ```dart
    var builder = person.toBuilder();
    builder.name = "Günter";
    builder.age = 25;
    var obj = builder.build();
    ```

!!! note "Availability"
    The builder is only available for dataclasses and basic serializable classes.

## Special Annotations

Dogs include several annotations that can be used to modify the behavior of serialization and deserialization.
Here is a (non-exhaustive) list of the most common annotations and their usage:

<div class="common-min-size-table" markdown="1">

| Annotation                                       | Applicable To        | Description                                                                                                                                                                                                                                                                                        |
|--------------------------------------------------|----------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `@PropertyName()`                                | **Field**            | Sets the name of the field when serialized. This is useful if you want to use a different name for the field in the serialized data than in the class.                                                                                                                                             |
| `@EnumProperty()`                                | **Field**            | The name of the enum constant can be overridden using the `name` parameter. Additionally, a single constant can be marked as `fallback` to handle invalid enum values.                                                                                                                             |
| `@DefaultValue()`                                | **Field**            | Sets a default value for the field. If the field is not present in the serialized data, the default value will be used. If the field is present, the default value will be ignored. If `keep` is set to `true`, the field will be included in the output even if it is equal to the default value. |
| `@excludeNull`                                   | **Field**, **Class** | Excludes the field from serialization if it is null. This is useful for fields that are optional and should not be serialized if they are not set. Can also be applied to a class to exclude all null values from serialization.                                                                   |
| `@LightweightMigration()` `@RevisionMigration()` | **Class**            | Specifies migrations that can be applied before the data is deserialized.                                                                                                                                                                                                                          |

</div>
