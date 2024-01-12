# Getting Started

To get started, add the dogs_forms package to your pubspec.yaml file:

```yaml
dependencies:
  dogs_forms: ^0.0.1
```

After adding you added the extension package to your project, you can instantly start using it
for creating your forms for already existing dogs structures. Simply use the `DogsForm` widget:

```dart
Future main() async {
  await initialiseDogs();
  dogs.registerModeFactory(defaultFormFactories); // This is important!
  runApp(MyApp());
}
// [...]
class MyWidget extends StatelessWidget {
  
  // Reference to retrieve data from the form.
  // Acts like a global key.
  final DogsFormRef<Person> reference = DogsFormRef();
  
  @override
  Widget build(BuildContext context) {
    // [...]
    DogsForm<Person>(
        reference: reference
    );
    // [...]
  }
  
  void handleSubmit() {
    // Retrieve the data from the form.
    final person = reference.read();
    print(person.toString());
  }
}
```

!!! tip "How to create serializable classes for forms?"
    For details on how to create serializable classes, head to [Serializable Classes](/serializables/).