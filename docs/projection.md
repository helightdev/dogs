# Projection

You can project multiple objects and maps into a single object by using the `project` method.

!!! tip "Data Transfer Objects (DTO)"
    When working with DTOs, you can use this method to create a new object from the
    data of the original object while also allowing you to merge in additional data from other
    serializable objects or maps.

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

[Continue Reading! :material-arrow-right:](/validation/){ .md-button .md-button--primary }