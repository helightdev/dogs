# Custom Converters

Dog provides a number of built-in converters for common types. However, you may need to create your
own converters for custom types. This section will explain how to create custom converters and how
to register them in the `DogEngine`.

## Simple Converters

``` { .dart .annotate title="Example using the SimpleDogConverter" }
class LatLng {
  final double lat;
  final double lng;

  LatLng(this.lat, this.lng);

  @override
  String toString() => "LatLng($lat, $lng)";
}

@dogsLinked/*(1)!*/
class LatLngConverter extends SimpleDogConverter<LatLng>/*(2)!*/ {
  LatLngConverter() : super(serialName: "LatLng");

  @override
  LatLng deserialize(value, DogEngine engine) {
    var list = value as List;
    return LatLng(list[0], list[1]);
  }

  @override
  serialize(LatLng value, DogEngine engine) {
    return [value.lat, value.lng];
  }
}
```

1. The `@linkSerializer` annotation is used to automatically register compatible extensions in the `DogEngine`.
2. The `SimpleDogConverter` class is a convenience class that implements `DogConverter` and provides
   both the NativeSerializerMode and the GraphSerializerMode. It also creates a synthetic structure for
   the converter type that uses the `serialName`.

In this example, we created a converter for the `LatLng` class. The converter is registered in the
`DogEngine` using the `@dogsLinked` annotation. The 'SimpleDogConverter' base class is the easiest
way to create a converter – it implements the `DogConverter` interface and automatically creates a native
serialization mode and a synthetic structure.

??? info "Manual Registration"
    To manually register a converter in the `DogEngine`, you can use the `registerAutomatic` method to
    register converter and also link both the structure and it's associated type.

    To **only** register the converter for a **specific type**, use `registerAssociatedConverter`.  
    To **only** register a **structure**, use `registerStructure`.  
    To **only** register a converter, **without associating** it with a type, use `registerShelvedConverter`.


## Tree Converters
Tree converters build a tree of converters based on a given `TypeTree`. In the newer versions of dogs, **most of the
complex serialization is done using tree converters.**

Each node inside the tree represents a **single terminal or compound type**.
Generally, all type trees consist of a base type (e.g. `int`, `String`, `List`, `Map`, etc.) and
a list of type arguments. There are also some special types of type trees for specific use-cases:

- `QualifiedTypeTree` also contain a final combined type of the tree, which results in it being able to be fully
  cached once constructed.
- `SyntheticTypeCapture` doesn't define a base type, but uses the **serial name** of a structure like a type,
  allowing dynamically generated structures to be used as if they had a backing type. To enable this, downstream
  type safety is not guaranteed and trying to access the captured type will return `dynamic`.
- `UnsafeRuntimeTypeCapture` uses the **runtime type** of value as a simple version of a type tree. Has the same
  limitations as synthetic type captures.

To construct a converter tree converter, the engine invokes the converter creation **top-down**, starting with the
first base type. If the type tree has type arguments, the base converter will most likely **resolve the type argument subtrees
recursively**.

``` { .dart title="List Converter using createIterableFactory" } 
@dogsLinked
final myListFactory = TreeBaseConverterFactory.createIterableFactory<MyList>(
  wrap: <T>(Iterable<T> entries) => MyList(entries.toList()),
  unwrap: <T>(MyList value) => value,
);
```
Iterable converters are the most basic and also the most common type of tree converters. They are
easy to create and can be used to convert any type of iterable. The `wrap` and `unwrap` functions
are used to convert the iterable to and from the tree's base type.

??? note "Manual Registration"
    You can register a custom tree base factory using the `registerTreeBaseFactory` method of the `DogEngine`.

    ```{ .dart title="Registering a custom tree base factory" }
    dogs.registerTreeBaseFactory(
      TypeToken<MyConverterBaseType>(),
      myCustomConverterFactory
    );
    ```


```{ .dart title="Map Converter using NTreeArgConverter" }
@dogsLinked
final mapFactory = TreeBaseConverterFactory.createNargsFactory<Map>(
  nargs: 2, consume: <K, V>() => MapNTreeArgConverter<K, V>()
);

class MapNTreeArgConverter<K,V> extends NTreeArgConverter<Map> {
  @override
  Map deserialize(value, DogEngine engine) {
    return (value as Map).map<K,V>((key, value) => MapEntry<K,V>(
      deserializeArg(key, 0, engine),
      deserializeArg(value, 1, engine),
    ));
  }

  @override
  serialize(Map value, DogEngine engine) {
    return value.map((key, value) => MapEntry(
      serializeArg(key, 0, engine),
      serializeArg(value, 1, engine),
    ));
  }
}
```

!!! warning "Don't use Type Constraints"
    Since tree converters are dynamic in nature, they cannot statically enforce type constraints on their type arguments,
    as this would require down-casting type constraints at runtime, which is not possible in Dart.

    If type constraints are required, consider performing runtime checks inside the converter methods.

`NTreeArgConverters` are used to convert complex types that have a fixed number of type arguments.
The consume method is used to expand the stored type arguments to usable generic type arguments
which then need to be used to create a NTreeArgConverter. The `NTreeArgConverter` class provides
the `deserializeArg` and `serializeArg` methods to convert generic items using the converter
associated with the type argument at the given index.

``` { .dart title="Complex Container using NTreeArgConverter" }
final containerFactory = TreeBaseConverterFactory.createNargsFactory<Container>(
  nargs: 3, consume: <A,B,C>() => ContainerConverter<A,B,C>(),
);

class Container<A,B,C> {
  final A a;
  final B b;
  final C c;

  Container(this.a, this.b, this.c);

  String toString() => "Container<$A, $B, $C>($a, $b, $c)";
}

class ContainerConverter<A,B,C> extends NTreeArgConverter<Container> {

  @override
  Container deserialize(value, DogEngine engine) {
    return Container<A,B,C>(
      deserializeArg(value["a"], 0, engine),
      deserializeArg(value["b"], 1, engine),
      deserializeArg(value["c"], 2, engine),
    );
  }

  @override
  serialize(Container value, DogEngine engine) {
    return {
      "a": serializeArg(value.a, 0, engine),
      "b": serializeArg(value.b, 1, engine),
      "c": serializeArg(value.c, 2, engine)
    };
  }
}
```