Dogs offers a few static methods on the `FirestoreEntity` class to query the database. These methods
are `get`, `find` and `query`. They are all asynchronous and return a `Future` of the requested
entity/entities.

## Get
The `get` method is used to retrieve a single entity from the database. It takes the id of the
entity as an argument and returns a `Future` of the requested entity. You can additionally specify
a `orCreate` argument, that takes a supplier function as an argument. If the entity is not found in
the database, the supplier function will be called and the supplied entity will be stored in the
database and returned.

```dart title="Simple get"
var town = await FirestoreEntity.get<Town>("town_id_here");
```

```dart title="Using the orCreate argument"
var town = await FirestoreEntity.get<Town>("town_id_here",
  orCreate: () => Town("London", "UK"));
);
```

## Find
The `find` method is used to retrieve a single entity from the database. It takes a `Query` as an
optional argument and returns a `Future` of the requested entity. If no `Query` is specified, the
first entity of the collection will be returned.

```dart title="Simple find that returns the first entity"
var town = await FirestoreEntity.find<Town>();
```

```dart title="Find that returns the first entity that matches the query"
var town = await FirestoreEntity.find<Town>(
    query: (q) => q.where("name", isEqualTo: "London"),
);
```

## Query
The `query` method is used to retrieve a list of entities from the database. It takes a `Query` as
an optional argument and returns a `Future` of the requested entities. If no `Query` is specified,
all entities of the collection are included in the query. To use pagination, you can specify a
limit using the 'Query.limit' method. To set cursors, use the cursor methods on the `query` method
itself, since they also take firestore entities as arguments.

```dart title="Simple query that includes all entities"
var towns = await FirestoreEntity.query<Town>();
```

```dart title="Pagination with a cursor and a limit of 10"
var previous = // [...]
var towns = await FirestoreEntity.query<Town>(
    query: (q) => q.limit(10),
    startAfter: previous,
)
```

!!! tip "To insert an entity into the database, use the `save` method of the entity itself"
    ```dart
    var person = Person("John", 25);
    await person.save();
    ```