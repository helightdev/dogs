# 2. Object Serialization

You can use the global variable `dogs` to easily access any dogs related functionality.
All default encoders and decoders expose extension methods on the `DogEngine` class
in the schema of `{format}Encode<T>` and `{format}Decode<T>`.

Native and Graph serialization,
which build the backend of the other encoders and decoders, follow a different schema
and are exposed as `convertObjectTo{Format}` and `convertObjectFrom{Format}`. They don't
require the type as a type parameter but as a positional argument.


## JSON Serialization
**Json Encode**
``` { .dart }
var person = Person("Alex", 22, {"developer", "dart"});
var json = dogs.jsonEncode<Person>(person);
```

**Json Decode**
``` { .dart .annotate }
var encoded = """{"name":"Alex","age":22,"tags":["developer","dart"]}""";
var person = dogs.jsonDecode<Person>(person);
```

!!! tip "Always specify the type parameter!"
    Even when the type is inferred, you should always specify the type to avoid unexpected behavior.

!!! warning "The type `T` must be directly serializable"
    This means that the type `T` must be a structure or at least convertible.  
    **Collections** of `T` **are not** directly **serializable** and must be wrapped in a structure.

## Native Serialization
You can also encode and decode objects from and to native dart objects.
Values are considered native if they are serializable by the dart json encoder.

**Native Encode**
``` { .dart }
var person = Person("Alex", 22, {"developer", "dart"});
var json = dogs.convertObjectToNative(person, Person);
```

**Native Decode**
``` { .dart }
var encoded = {
  "name": "Alex",
  "age": 22,
  "tags": {"developer","dart"}
};
var person = dogs.convertObjectFromNative(encoded, Person);
```

[Continue Reading! :material-arrow-right:](/projection/){ .md-button .md-button--primary }