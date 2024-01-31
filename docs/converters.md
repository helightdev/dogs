# 6. Custom Converters

Dog provides a number of built-in converters for common types. However, you may need to create your
own converters for custom types. This section will explain how to create custom converters and how 
to register them in the `DogEngine`.

``` { .dart .annotate title="Example using the SimpleDogConverter" }
class LatLng {
  final double lat;
  final double lng;

  LatLng(this.lat, this.lng);

  @override
  String toString() => "LatLng($lat, $lng)";
}

@linkSerializer/*(1)!*/
class LatLngConverter extends SimpleDogConverter<LatLng>/*(2)!*/ {
  LatLngConverter() : super(serialName: "LatLng");

  @override
  LatLng deserialize(value, DogEngine engine) {
    var list = value as List;
    return LatLng(list[0], list[1]);
  }

  @override
  serialize(LatLng value, DogEngine engine) {
    return [value.lat, value.lng];
  }
}
```

1. The `@linkSerializer` annotation is used to automatically register the converter in the `DogEngine`.
2. The `SimpleDogConverter` class is a convenience class that implements `DogConverter` and provides
both the NativeSerializerMode and the GraphSerializerMode. It also creates a synthetic structure for
the converter type that uses the `serialName`.

In this example, we created a converter for the `LatLng` class. The converter is registered in the
`DogEngine` using the `@linkSerializer` annotation. The 'SimpleDogConverter' base class is the easiest
way to create a converter. It implements the `DogConverter` interface and provides both the
`NativeSerializerMode` and the `GraphSerializerMode`. It also creates a synthetic structure for the
converter type that uses the `serialName`.

??? info "Manual Registration"
    To manually register a converter in the `DogEngine`, you can use the `registerAutomatic` method to
    register converter and also link both the structure and it's associated type.  

    To **only** register the converter for a **specific type**, use `registerAssociatedConverter`.  
    To **only** register a **structure**, use `registerStructure`.  
    To **only** register a converter, **without associating** it with a type, use `registerShelvedConverter`.

## Collections and generic types
For custom collections and generic types, you need to create a `TreeBaseConverterFactory`. This
is relatively easy, refer to [Tree Converters](/advanced/tree_converters) for more information.