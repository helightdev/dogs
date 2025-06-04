# Serializable Classes

::: code-group
```dart [Basic]
@serializable
class Person {
  
  String name;
  int age;
  Set<String>? tags;
  
  Person(this.name, this.age, this.tags);
}
```

```dart [Dataclass]
@serializable
class Person with Dataclass<Person> {

  final String name;
  final int age;
  final Set<String>? tags;

  Person(this.name, this.age, this.tags);
} 
```

```dart [Super Parameter]
@serializable
class Entity extends Base with Dataclass<Person> {

  final String name;

  Entity({
    required super.id,
    required this.name
  });
}
```

```dart [Backing Field]
@serializable
class Entity with Dataclass<Person> {

  final String id;

  Entity(String? id) : this.id = id ?? Uuid().v4();
}
```

```dart [Backing Getter]
@serializable
class Entity with Dataclass<Person> {
    
  String? _id;

  Entity(String? id) {
    _id = id;
  }

  String get id => _id ??= Uuid().v4();
}
```
:::

Serializing dogs serializables is straightforward and can be done using the `toJson` and `fromJson` method on the global `dogs` instance.
```dart
final person = Person("Alex", 22, {"developer", "dart"});
final json = dogs.toJson<Person>(person); // [!code focus]
print(json); // {"name":"Alex","age":22,"tags":["developer","dart"]}
final person = dogs.fromJson<Person>(json); // [!code focus]
print(person); // Person(name: Alex, age: 22, tags: {developer, dart})
```

Other serialization formats can be used as well following the same pattern. Native serialization, for example, will
converter the object to a `Map<String,dynamic>` with only primitive types.
```dart
final person = Person("Alex", 22, {"developer", "dart"});
final json = dogs.toNative<Person>(person); // [!code focus]
print(json); // {name:"Alex", age:22, tags:["developer","dart"]}
final person = dogs.fromNative<Person>(json); // [!code focus]
print(person); // Person(name: Alex, age: 22, tags: {developer, dart})
```

You can modify instances of serializable classes using the `copy` extension method. This works exactly like the
`copy` method in **Kotlin's data classes**, only changing the fields you specify, supporting null values.
```dart
final person = Person("Alex", 22, {"developer", "dart"});
print(person); // Person(name: Alex, age: 22, tags: {developer, dart})
final modified = person.copy(name: "Bob", age: 30); // [!code focus]
print(modified); // Person(name: Bob, age: 30, tags: {developer, dart})
```