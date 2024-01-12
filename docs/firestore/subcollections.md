To specify subcollections, you can use the 'subcollectionOf' argument of the `@Collection`
annotation. This will make the collection a subcollection of the specified entity and can only
be accessed through the parent entity.

```dart

@serializable
class Town extends FirestoreEntity<Town> {

  String name;
  String country;

  Town(this.name, this.country);

}

@serializable
@Collection(subcollectionOf: Town)
class Person extends FirestoreEntity<Person> {
  String name;
  int age;
  
  Person(this.name, this.age);
}

```

To insert a newly created entity into a subcollection, you can use the `store` method of the
parent entity.

``` .dart title="Inserting a subcollection entity"
var town = Town("London", "UK");
await town.save();
var person = Person("John", 25);
await town.$store(person);
```

!!! tip "All subcollection related methods are prefixed with a '$' sign"
    They offer the same functionality as the static non-prefixed methods, but
    they are scoped to the parent entity. This currently includes:
    `$get`, `$find`, `$query`, `$store`

## Additional Examples

``` .dart title="Retrieving a subcollection entities"
var town = await FirestoreEntity.get<Town>("town_id_here");
var persons = await town.$query<Person>();
```

``` .dart title="Retrieving a subcollection entity by id"
var town = await FirestoreEntity.get<Town>("town_id_here");
var person = await town.$get<Person>("person_id");
```