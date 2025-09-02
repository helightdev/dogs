---
icon: simple/flutter
---

# Flutter ![Static Badge](https://img.shields.io/badge/experimental-orange)

This package provides Flutter specific functionality for the Dogs serialization library, including: 

- [Databinding](binding) and Form Generation
- [Converters](converters) for Flutter specific types


To install the base package, modify your `pubspec.yaml` to include following packages:

``` { .yaml .file .focus title="pubspec.yaml" hl_lines="3" }
dependencies:
  dogs_core: any
  dogs_flutter: any

dev_dependencies:
  build_runner: any
  dogs_generator: any
```

and replace the `any` with the desired/latest version constraint.