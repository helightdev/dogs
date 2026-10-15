Code generator for the dogs serialization library.

To put generated Dart files under `lib/generated`, configure all three builders
with the same option in the consuming package's `build.yaml`:

```yaml
targets:
  $default:
    builders:
      dogs_generator:dogs_descriptors:
        options: {output_directory: generated}
      dogs_generator:dogs_bindings:
        options: {output_directory: generated}
      dogs_generator:dogs_reactor:
        options: {output_directory: generated}
```

For example, `lib/city/city_model.dart` generates
`lib/generated/city/city_model.conv.g.dart`, and the registry is
`lib/generated/dogs.g.dart`. The default layout is unchanged. Converter source
subdirectories are retained to avoid collisions between equal file names.
