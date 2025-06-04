# Projection

You can project multiple objects and maps into a single object by using the `project` method.

??? tip "Data Transfer Objects (DTO)"
    When working with DTOs, you can use this method to create a new object from the
    data of the original object while also allowing you to merge in additional data from other
    serializable objects or maps.

!!! info "Based on the native serialization"
    The `project` method is based on the **native** format of the underlying dog engine. For most
    cases, this will be the map format accepted by dart's `jsonEncode` method. To use a shallow
    field based projection, use the `shallow` variants of the `project` method. Those will not copy
    nested objects and maps may contain non-native values.

```dart title="Projection Expansion"
var user = dogs.project<User>(
    NameAndAge("Alex", 22),
    {"id": "1234", "isAdmin": true}
);
```

```dart title="Projection Reduction"
var reduced = dogs.project<NameAndAge>(
    User("1234", "Alex", 22, true),
);
```

??? warning "Based on runtimeType"
    The projection for supplied objects is based on the runtime type of the object. This means that
    the engine can only infer the type for concrete classes. If you want to project collections or
    other non-concrete types, convert the object using `toNative()` first.

