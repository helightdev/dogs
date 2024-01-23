# Getting Started

To get started, add the dogs_built package to your pubspec.yaml file:

```yaml
dependencies:
  dogs_built: any
  built_value: any
  built_collection: any
```

After this, the library import containing your built_value classes must be annotated with
`@SerializableLibrary`. Exported libraries are automatically considered. To restrict which types
get included, you can use the `include` and `exclude` parameters, which take a list of regular
expressions.
```dart
@SerializableLibrary(include: ["package:petstore_api/src/model/.*"])
import 'package:petstore_api/petstore_api.dart';
```

In your initialization code, you need to call `initialiseDogs` and `installBuiltSerializers` to
register support for all built_value types as well as some internal converters exposed by built_value.
```dart

import 'dogs.g.dart';

Future main() async {
  await initialiseDogs();
  installBuiltSerializers(PetstoreApi().serializers);
}
```

!!! warning "Only one serializer can be installed at the same time"