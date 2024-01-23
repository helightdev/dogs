# Tree Converters
Tree converters are a special type of converter that can be used to convert a complex type tree
structure. To register a tree converter, you must call the `registerTreeBaseFactory` method of the
`DogEngine`. This method takes a `Type` and a `TreeBaseConverterFactory` instance as arguments.
For more details on when tree converters are used, refer to the [Field Serialization](/advanced/structures/#field-serialization)

## List Converter using createIterableFactory
```dart
final listFactory = TreeBaseConverterFactory.createIterableFactory<List>(
  wrap: <T>(Iterable<T> entries) => entries.toList(),
  unwrap: <T>(List value) => value,
);
```
Iterable converters are the most basic and also the most common type of tree converters. They are
easy to create and can be used to convert any type of iterable. The `wrap` and `unwrap` functions
are used to convert the iterable to and from the tree's base type.

## Map Converter using NTreeArgConverter
```dart
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
`NTreeArgConverters` are used to convert complex types that have a fixed number of type arguments.
The consume method is used to expand the stored type arguments to usable generic type arguments
which then need to be used to create a NTreeArgConverter. The `NTreeArgConverter` class provides
the `deserializeArg` and `serializeArg` methods to convert generic items using the converter
associated with the type argument at the given index.

## Complex Container using NTreeArgConverter
```dart
final containerFactory = TreeBaseConverterFactory.createNargsFactory<Container>(
  nargs: 3,
  consume: <A,B,C>() => ContainerConverter<A,B,C>(),
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