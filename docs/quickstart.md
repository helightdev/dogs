---
icon: octicons/zap-16
---

``` { .dart .focus hl_lines="3 6-9" }
import 'package:dogs_flutter/dogs_flutter.dart';
import 'package:flutter/material.dart';
import 'package:todos/dogs.g.dart';

void main() {
  configureDogs(plugins: [
    GeneratedModelsPlugin(),
    DogsFlutterPlugin(),
  ]);
  runApp(const MyApp());
}
```

First, we always need to initialize the dogs engine so we can later use it. After installing the plugin, you can run
the build_runner to generate the `dogs.g.dart` file, which contains the code for the initializer.

``` { .dart }
@serializable
class TodoEntry {
  final String text;
  final bool done;
  final DateTime createdAt;

  TodoEntry(this.text, this.done, this.createdAt);
}

```

Next, we define our simple todo model using the `@serializable` annotation. After that, we run the build_runner again
to generate the `*.conv.g.dart` files, which are automatically registered.

``` { .dart .focus hl_lines="2 5" }
Checkbox(
  value: entry.done,
  onChanged: (value) {
    setState(() {
      todoEntries[i] = entry.copy(done: !entry.done);
    });
  },
),
```

Now we implemented our simple todo view and create a checkbox that toggles the `done` state of the entry.
To change the entry state, we use the `copy` method, which is automatically generated.

``` { .dart .focus hl_lines="4" }
IconButton(
  icon: const Icon(Icons.save),
  onPressed: () {
    final encodedText = dogs.toJson<TodoEntry>(entry);
    showExportDialog(context, encodedText);
  },
),
```

We then add a button to share the entry as JSON. The `dogs.toJson` method is used to convert the entry to a JSON string,
that is then display in a dialog.