---
icon: octicons/book-16
---

# Annotation Catalog
## Serialization Annotations
<div class="grid cards" markdown>

-   ![](https://img.shields.io/badge/class-seagreen){ .lg .middle }
    ![](https://img.shields.io/badge/enum-orange){ .lg .middle }
    __Structure__

    ---
    Generates a structure for the target. `serialName` can be specified to change the identifier used.
    `serializable: false` can be used to only generate structures.

-   ![](https://img.shields.io/badge/class-seagreen){ .lg .middle }
    ![](https://img.shields.io/badge/enum-orange){ .lg .middle }
    __Serializable / serializable__

    ---
    Aliases for serializable `Structures`. `serialName` can be specified to change the identifier used.

-   ![](https://img.shields.io/badge/enum--constant-orange){ .lg .middle }
    __EnumProperty__

    ---
    The name of the enum constant can be overridden using the `name` parameter. Additionally,
    a single constant can be marked as `fallback` to handle invalid enum values.

-   ![](https://img.shields.io/badge/property-blue){ .lg .middle }
    __polymorphic__

    ---
    Marks a field as polymorphic so that the actual runtime type is used for serialization.

-   ![](https://img.shields.io/badge/property-blue){ .lg .middle }
    __PropertySerializer__

    ---
    Specifies the type of custom converter to be used for this fields' serialization.

-   ![](https://img.shields.io/badge/property-blue){ .lg .middle }
    __PropertyName__

    ---
    Changes the name of the property used in serialization.

-   ![](https://img.shields.io/badge/property-blue){ .lg .middle }
    __DefaultValue__

    ---
    Sets a default value for the field. If `keep` is `false`, the field will be omitted in serialization if it has the default value.

-   ![](https://img.shields.io/badge/class-seagreen){ .lg .middle }
    ![](https://img.shields.io/badge/property-blue){ .lg .middle }
    __excludeNull__

    ---
    If applied to a member, direct null values will be excluded from serialization.

-   ![](https://img.shields.io/badge/class-seagreen){ .lg .middle }
    __LightweightMigration__

    ---
    Applies a list of functions on deserialization to migrate data from older versions.

-   ![](https://img.shields.io/badge/class-seagreen){ .lg .middle }
    __RevisionMigration__

    ---
    Applies migrations based on the revision number added to the map output.

</div>

## Validation Annotations
<div class="grid cards" markdown>

-   ![](https://img.shields.io/badge/string-seagreen){ .lg .middle }
    ![](https://img.shields.io/badge/or-many-slategray){ .lg .middle }
    __LengthRange__
-   ![](https://img.shields.io/badge/string-seagreen){ .lg .middle }
    ![](https://img.shields.io/badge/or-many-slategray){ .lg .middle }
    __Regex__
-   ![](https://img.shields.io/badge/string-seagreen){ .lg .middle }
    ![](https://img.shields.io/badge/or-many-slategray){ .lg .middle }
    __email__
-   ![](https://img.shields.io/badge/string-seagreen){ .lg .middle }
    ![](https://img.shields.io/badge/or-many-slategray){ .lg .middle }
    __notBlank__

-   ![](https://img.shields.io/badge/num-blue){ .lg .middle }
    ![](https://img.shields.io/badge/or-many-slategray){ .lg .middle }
    __Range__
-   ![](https://img.shields.io/badge/num-blue){ .lg .middle }
    ![](https://img.shields.io/badge/or-many-slategray){ .lg .middle }
    __Minimum__
-   ![](https://img.shields.io/badge/num-blue){ .lg .middle }
    ![](https://img.shields.io/badge/or-many-slategray){ .lg .middle }
    __Maximum__
-   ![](https://img.shields.io/badge/num-blue){ .lg .middle }
    ![](https://img.shields.io/badge/or-many-slategray){ .lg .middle }
    __positive__
-   ![](https://img.shields.io/badge/num-blue){ .lg .middle }
    ![](https://img.shields.io/badge/or-many-slategray){ .lg .middle }
    __positiveOrZero__
-   ![](https://img.shields.io/badge/num-blue){ .lg .middle }
    ![](https://img.shields.io/badge/or-many-slategray){ .lg .middle }
    __negative__
-   ![](https://img.shields.io/badge/num-blue){ .lg .middle }
    ![](https://img.shields.io/badge/or-many-slategray){ .lg .middle }
    __negativeOrZero__
-   ![](https://img.shields.io/badge/iterable-slategray){ .lg .middle }
    __SizeRange__
-   ![](https://img.shields.io/badge/any-red){ .lg .middle }
    ![](https://img.shields.io/badge/or-many-slategray){ .lg .middle }
    __validated__

</div>