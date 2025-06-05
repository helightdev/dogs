---
icon: octicons/download-16
---

To install the base package, modify your `pubspec.yaml` to include following packages:

``` { .yaml .file title="pubspec.yaml" hl_lines="2 5-6" }
dependencies:
  dogs_core: any

dev_dependencies:
  build_runner: any
  dogs_generator: any
```

The following additional packages are available for your convenience:

``` { .yaml .file title="pubspec.yaml" hl_lines="2-6" }
dependencies:
  dogs_built: any # Support for built_value converters
  dogs_yaml: any # Support for YAML files
  dogs_toml: any # Support for TOML files
  dogs_cbor: any # Support for CBOR files
```

After adding the packages, run `pub get` to download the packages and `pub run build_runner build`
to generate the `dogs.g.dart` reactor file.

After this, you just need to load the dogs engine from your entrypoint of choice:

``` { .dart .file title="main.dart" }
import 'package:dogs_core/dogs_core.dart';
import 'dogs.g.dart';

void main() {
  configureDogs(plugins: [
    GeneratedModelsPlugin()
  ]);
  // [...]
}
```

!!! tip "Use build_runner watch"
    When working with the dogs engine, it is recommended to use `build_runner watch` to
    automatically generate the `dogs.g.dart` file and `*.conv.g.dart` files when you make changes
    to your models. Changing the model and forgetting to run `build_runner` will not always result
    in exceptions, but it will result in unexpected behaviour as the generated code will not match
    the current model.
