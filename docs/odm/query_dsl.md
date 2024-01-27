# Query DSL
Dogs odm provides a simple query dsl to filter repositories in a basic way. The syntax is similar to
the one used by `mongo_dart`. The following example shows how to use the query dsl:

```dart
import 'package:dogs_odm/query_dsl.dart';

// ...

void main() {
  var result = repository.findAllByQuery(
    eq('name', 'John') & gt('age', 42),
  );
}
```

The following table shows all available query operators:

| Operator        | Description                 |
|-----------------|-----------------------------|
| `eq`            | Equal to a value or struct  |
| `ne`            | Inverted equals             |
| `gt`            | Greater than                |
| `gte`           | Greater than or equal to    |
| `lt`            | Less than                   |
| `lte`           | Less than or equal to       |
| `inArray`       | Equal to one of the values  |
| `notInArray`    | Equal to none of the values |
| `exists`        | The field exists            |
| `arrayContains` | Array contains a value      |
| `and` or `&`    | Logical And                 |
| `or` or `       | `                           | Logical Or                          |


## Field Paths
To access deeper sub documents you can join field names with a dot.
```dart
"person.address.street" -> document['person']['address']['street']
```

## Limitations
The support for logical operators may be limited depending on the database you are using.
Complex nested queries may not be supported by all databases, in this case you should use the
native query syntax of your database.

The syntax of the dsl is already limited to the most common features of document databases, to
be as database agnostic as possible.