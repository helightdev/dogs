# Getting Started

Dogs odm provides a simple way to interact with document database like MongoDB. In a backend
friendly way.

## Installation
To get started, you need to add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  dogs_odm: ^1.0.0
```

additionally, you should choose a database driver. Currently, the only supported driver is
`dogs_mongo_driver`. To add it, add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  dogs_mongo_driver: ^1.0.0
```

Then run `pub get` to install the package.

## Usage
Besides normal dogs initialization, you need to connect to the database. This is done by
calling `MongoOdmSystem.connect` with the connection string as the first argument or wrapping
an already existing `DB` instance using `MongoOdmSystem.fromDb`. The following example shows
how to connect to a local MongoDB instance:

```dart
import 'package:dogs_odm/dogs_odm.dart';
import 'package:dogs_mongo_driver/dogs_mongo_driver.dart';

void main() async {
  await initialiseDogs();
  installOdmConverters(); // Install odm converters to support odm types in normal dogs.
  installMongoConverters(); // Install mongo converters to support mongo types in normal dogs.
  
  await MongoOdmSystem.connect('mongodb://localhost:27017');

    // ...
}
```

### Defining Models
All serializable classes can be used as models. However, you need to specify an id field either by
name or by using the `@Id` annotation. The following example shows how to define a model:

```dart
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_odm/dogs_odm.dart';

@serializable
class Person with Dataclass<Person> {
  @Id()
  String? id;
  String name;
  int age;
  
  Person({
    this.id,
    required this.name,
    required this.age,
  });
}
```

!!! tip "Visit [Serializable Classes](/serializables/) for more information on how to define serializable classes."

### Creating Repositories
Repositories are used to interact with the database. You generally define repositories on a global
level. The following example shows how to define a repository:

```dart
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_odm/dogs_odm.dart';

class PersonRepository extends MongoRepository<Person,String> {
  // Custom query methods go here.
}

final personRepository = PersonRepository();
```

!!! note "The second type parameter of `MongoRepository` is the type of the id field you want to use for querying."

You can also use the `plain` factory for many repositories if you don't want to define additional
methods. The following example shows how to define a repository using the `plain` factory:

```dart
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_odm/dogs_odm.dart';

final personRepository = MongoRepository.plain<Person,String>();
```

### Using Repositories
Depending on the type of repository you are using, different methods are available.
All repositories support basic crud operations but most will also support `QueryableRepository`
and `PaginatedRepository`. The following example shows how to use a repository:

```dart
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_odm/dogs_odm.dart';

void main() async {
  // ...
  
  final person = Person(name: 'John', age: 42);
  
  // Would return the saved person with an id.
  await personRepository.save(person);
  
  final searched = await personRepository.findOneByQuery(eq('name', 'John'));
  print(searched); // Person(id: ..., name: 'John', age: 42)
  
  await personRepository.delete(searched!);
  
  // ...
}
```