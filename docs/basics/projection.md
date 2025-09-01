# Projection

You can project multiple objects and maps into a single object by using the `Projection` class and its methods.

??? tip "Data Transfer Objects (DTO)"
    When working with DTOs, you can use this method to create a new object from the
    data of the original object while also allowing you to merge in additional data from other
    serializable objects or maps.


```dart title="Projection Expansion"
var user = Projection<User>()
    .merge(NameAndAge("Alex", 22))
    .mergeMap({"id": "1234", "isAdmin": true})
    .perform();
```

```dart title="Projection Reduction"
var reduced = Projection<NameAndAge>()
    .merge(User("1234", "Alex", 22, true))
    .perform();
```

Projection operations are executed top-down in the order they were added.

## Reusable Projection Pipelines
Projection objects can be easily reused by using `unwrap` methods instead of `merge` methods. These methods will
unwrap/'merge' value loaded from a specific path. The pipelines can then be invoked by specifying input values in the
perform method.

```dart title="Reusable Projection Pipeline"
final projection = Projection<NameAndAge>()
  .unwrapType<User>("input");

// Usage
final invoked = projection.perform({
  "input": User("1234", "Alex", 22, true)
});
```