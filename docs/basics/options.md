# Generator Options
The generator behavior can be configured using the `dogs` section in your `pubspec.yaml` file.

``` { .yaml .file title="pubspec.yaml" .focus hl_lines="5-100" }
dev_dependencies:
  build_runner: any
  dogs_generator: any

dogs:
  library: false
  property_case: keep
  name_case: keep
  enum_case: keep
  nullable_accessors: false
```

## Options
#### `library` (default: `false`)
If set to `true`, the generator will generate library named modules instead to prevent conflicts when sharing
models across multiple packages.
#### `property_case` (default: `keep`)
Defines the casing style for generated property names.
#### `name_case` (default: `keep`)
Defines the casing style for generated class and enum serial names.
#### `enum_case` (default: `keep`)
Defines the casing style for generated enum values.
#### `nullable_accessors` (default: `false`)
Forces builder accessor nullability regardless of the field nullability.

## Casing Options
- `keep`: Keep the original name.
- `camel`: Convert to camelCase.
- `pascal`: Convert to PascalCase.
- `snake`: Convert to snake_case.
- `kebab`: Convert to kebab-case.
- `constant`: Convert to CONSTANT_CASE.