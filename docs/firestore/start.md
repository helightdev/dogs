# Getting Started

To get started, add the dogs_firestore package to your pubspec.yaml file:

```yaml
dependencies:
  dogs_firestore: ^0.0.1
```

Then setup firebase by following the [official documentation](https://firebase.google.com/docs/firestore/quickstart#dart).

After you have setup firebase, you can start using the package using either the extension methods or
the `FirestoreEntity<T>` dataclass replacement.

=== "Firestore Entity"

    ```dart
    @serializable
    class Person extends FirestoreEntity<Person> {
      String name;
      int age;
      Timestamp? timestamp;
      GeoPoint? location;

      Person(this.name, this.age, this.timestamp, this.location);
    }

    void main() async {
      await initialiseDogs();
      installFirebaseInterop();
      final person = Person('John', 42, Timestamp.now(), GeoPoint(0, 0));
      await person.save();
    }
    ```

=== "Extension Methods"

    ```dart
    @serializable
    class Person with Dataclass<Person> {
      String name;
      int age;
      Timestamp? timestamp;
      GeoPoint? location;

      Person(this.name, this.age, this.timestamp, this.location);
    }

    void main() async {
      await initialiseDogs();
      installFirebaseInterop();

      final collection = FirebaseFirestore.instance
        .collection("my_collection")
        .withStructure<Person>();

      final person = Person('John', 42, Timestamp.now(), GeoPoint(0, 0));
      await collection.add(person);
    }
    ```