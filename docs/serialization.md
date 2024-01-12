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
var person = dogs.jsonDecode<Person/*(1)!*/>(person);
```

1. The type parameter is technically optional and can be inferred by the compiler.
    When you have a variable or field of type `Person` you can safely 
    use `dogs.jsonDecode(person)`. Still:

    !!! tip "Always specify the type parameter" 
        Even though the type parameter here is optional, it is recommended to always specify it
        as it makes the code more readable and helps in preventing easily avoidable errors.

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