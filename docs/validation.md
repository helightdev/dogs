# Validation

By default, all objects and structures are considered valid. You can change this behavior for
all your serializable classes by using class and field validators. All validators have to
be applied as annotations to their corresponding class or field.

``` { .dart .annotate }
@serializable
class User {  
  
  String name;

  @positive/*(1)!*/
  double age;

  @SizeRange(min: 0, max: 16)/*(2)!*/
  @Minimum(1)/*(3)!*/
  List<int>?/*(4)!*/ claims;

  @polymorphic/*(5)!*/
  Object? attachment;

  User(this.name, this.age, this.claims, this.attachment);
}
```

1. The `@positive` annotation is a shorthand for `Range(min: 0, minExclusive: true)`.
2. Requires the fields iterable to have a size between 0 and 16.
3. Requires all elements of the iterable to be >=1.
4. Nullable fields are considered valid if they are null.
5. The `@polymorphic` annotation is not a validator, but it is required for polymorphic
   serialization.

=== "Any"

    * `@validated`  
    Requires the annotated field to also validate its properties. By default only the
    properties of the root object are validated.

    !!! warning "Validating Nested Objects"
        Deep validation only works with non-tree based fields. Respectively, this works for all fields with direct
        converters and Lists, Sets and Iterables of those.
        
        Refer to [Structures](/advanced/structures/#field-serialization)
        for more details on field serialization.

=== "Strings"

    * `@LengthRange()`  
    Specify upper and lower bounds for the string length using the min and max properties.
    * `@Regex()`  
    Specify a regex that the string will be matched against. The string is deemed invalid if
    it doesn't fully match the regex.
    * `@email`  
    Requires a valid email address as per a reduced form of RFC 5322 where ip addresses,
    double quotes and square brackets are omitted.
    * `@notBlank`  
    Requires a string that not only consists of whitespace.

=== "Numbers"

    * `@Range()`  
    Specify upper and lower bounds for the number using the min and max properties.
    The exclusiveness of the range can be specified by the corresponding properties.
    * `@Minimum()`  
    Defines a lower bound for the number. The exclusiveness can be configured using minExclusive.
    * `@Maximum()`  
    Defines a upper bound for the number. The exclusiveness can be configured using maxExclusive.
    * `@postive`  
    Requires numbers to be greater than zero.
    * `@positiveOrZero`  
    Requires numbers to be greater or equal to zero.
    * `@negative`  
    Requires numbers to be smaller than zero.
    * `@negativeOrZero`  
    Requires numbers to be smaller or equal to zero.

=== "Iterable"

    * `@SizeRange()`  
    Specify upper and lower bounds for the iterables length using the min and max properties.