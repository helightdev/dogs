# Encoding and Decoding

You can use the global variable `dogs` to easily access any dogs related functionality.
All default encoders, decoders and opmodes expose extension methods on the `DogEngine` class
in the schema of `to{Format}<T>` and `to{Format}<T>`.

!!! abstract "Common Method Signature"
    `<T>` The return type parameter, which by default is used to lookup the converter.  
    `kind:` Serialize lists and sets without specifying a type tree.  
    `type:` Specify a type other than the return type parameter to be used for serialization.  
    `tree:` Use a tree base converter resolution. Refer to 
    [Tree Converters](/basics/converters/#tree-converters) for more information.

    > If the type is **overridden** by `type` or `tree`, the **type parameter** will **only** be 
    be used **for casting**.


## JSON Serialization
### Encoding
=== "Single"
    ``` { .dart title="Json Encode" .focus hl_lines="2" }
    var person = Person("Alex", 22, {"developer", "dart"});
    var json = dogs.toJson<Person>(person);
    ```

=== "List"
    ``` { .dart title="Encode List" .focus hl_lines="2-5" }
    var persons = [Person(...), Person(...)];
    var json = dogs.toJson(persons,
        type: Person,
        kind: IterableKind.list
    );
    ```

=== "Map"
    ``` { .dart title="Encode Map" .focus hl_lines="2-4"}
    var personMap = {"a": Person(...)};
    var json = dogs.toJson(personMap,
        tree: QualifiedTypeTree.map<String,Person>()
    );
    ```

    !!! example "This is a general example for TypeTrees"
        This can also be used for custom collections, wrappers, etc.  
        For more information, refer to [Tree Converters](/basics/converters/#tree-converters) and
        [Structures](/advanced/structures/#type-tree-resolution).

=== "Runtime Type"
    ``` { .dart title="Json Encode Dynamic Type" .focus hl_lines="2-4" }
    var person = Person("Alex", 22, {"developer", "dart"});
    var json = dogs.toJson(person,
        type: PersonSupertype
    );
    ```

=== "Nullable"
    ``` { .dart title="Json Encode Nullable"}
    var json = dogs.toJson<Person?>(null,
        type: Person,
    );
    ```

    !!! example "Syntax"
        To support nullable types without Optional wrappers, you need to explicitly specify a nullable
        type parameter. Since most of the time no converter is bound to the nullable type, you also
        need to specify the type explicitly using the named 'type' parameter. You can also use a tree
        to resolve the type.

### Decoding

=== "Single"
    ``` { .dart title="Json Decode" .focus hl_lines="2"  }
    var json = """{"name":"Alex","age":22,"tags":["developer","dart"]}""";
    var person = dogs.fromJson<Person>(json);
    ```
    !!! tip "Type Parameter required!"
        Even when the type is inferred, you should always specify the type
        to avoid unexpected behavior.

=== "List"
    ``` { .dart .annotate title="Json Decode List" .focus hl_lines="2-5"  }
    var json = """[{"name":"Alex","age":22,"tags":["developer","dart"]}]""";
    var persons = dogs.fromJson<List>(json,
        type: Person,
        kind: IterableKind.list
    ).cast<Person>();
    ```
    !!! example "Type Parameter not required!"
        In this case, the type parameter is **not required**, as type tree already dictates the type.  
        It is just specified here so you **don't have to cast** the resulting type.

=== "Map"
    ``` { .dart .annotate title="Json Decode Map" .focus hl_lines="2-4"  }
    var json = """{"a":{"name":"Alex","age":22,"tags":["developer","dart"]}}""";
    var map = dogs.fromJson<Map<String,Person>>(json,
        tree: QualifiedTypeTree.map<String,Person>()
    );
    ```
    !!! example "Type Parameter not required!" 
        In this case, the type parameter is **not required**, as type tree already dictates the type.  
        It is just specified here so you **don't have to cast** the resulting type.

=== "Runtime Type"
    ``` { .dart title="Json Decode Dynamic Type" .focus hl_lines="2-4"  }
    var json = """{"name":"Alex","age":22,"tags":["developer","dart"]}""";
    var person = dogs.fromJson(json,
        type: PersonSupertype
    );
    ```
    !!! example "Type Parameter not required!"
        In this case, the type parameter is **not required**, as type tree already dictates the type.  
        It is just specified here so you **don't have to cast** the resulting type.#

=== "Nullable"
    ``` { .dart title="Json Decode Nullable" .focus hl_lines="2-4"  }
    var json = """null""";
    var person = dogs.fromJson<Person?>(json,
        type: Person,
    );
    ```

## Native Serialization

You can also encode and decode objects from and to native dart objects.
Values are considered native if they are serializable by the dart json encoder.
All examples from the previous section can be used with native serialization as well by just
changing the method name from `toJson` to `toNative` and `fromJson` to `fromNative`.

``` { .dart title="Native Encode"}
var person = Person("Alex", 22, {"developer", "dart"});
var json = dogs.toNative<Person>(person);
```

``` { .dart title="Native Decode"}
var encoded = {
  "name": "Alex",
  "age": 22,
  "tags": {"developer","dart"}
};
var person = dogs.fromNative<Person>(encoded);
```
