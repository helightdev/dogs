# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2024-04-23

### Changes

---

Packages with breaking changes:

 - [`dogs_firestore` - `v0.2.0`](#dogs_firestore---v020)
 - [`dogs_forms` - `v0.2.0`](#dogs_forms---v020)
 - [`dogs_generator` - `v6.0.0`](#dogs_generator---v600)

Packages with other changes:

 - [`dogs_cbor` - `v2.3.0`](#dogs_cbor---v230)
 - [`dogs_mongo_driver` - `v1.0.0-alpha.11`](#dogs_mongo_driver---v100-alpha11)
 - [`dogs_odm` - `v1.0.0-alpha.11`](#dogs_odm---v100-alpha11)
 - [`dogs_toml` - `v2.3.0`](#dogs_toml---v230)
 - [`dogs_yaml` - `v2.3.0`](#dogs_yaml---v230)

---

#### `dogs_firestore` - `v0.2.0`

 - **FIX**: rename example package to not have the same name as a dependency.
 - **FEAT**: add json dump/load functionality for the memory db.
 - **FEAT**: fakeable firestore and fixed rebuild copy to include transient fields.
 - **FEAT**: add more query methods and $store.
 - **FEAT**: changes, queries and snapshot system for document reference.
 - **FEAT**: first working version of dogs_firestore 🎉.
 - **BREAKING** **FEAT**: fully remove the graph operation mode and other deprecations.

#### `dogs_forms` - `v0.2.0`

 - **REFACTOR**: change to new field name.
 - **REFACTOR**: use custom preference.
 - **FIX**: correctly pass translations and attributes to child forms.
 - **FIX**: switches and checkboxes with null values should return false.
 - **FIX**: remove debug print and use instantValue instead of value.
 - **FIX**: persist latest form values and fix set not propagating to form fields.
 - **FEAT**: add json dump/load functionality for the memory db.
 - **FEAT**: reorderable lists, automatic structure lists.
 - **FEAT**: add optional factory and a whole lot of reworks.
 - **FEAT**: add hint and prefix, suffix fields.
 - **FEAT**: add mechanism for precaching form field data that is then.
 - **FEAT**: add first working version of dogs_forms 🎉.
 - **BREAKING** **FEAT**: make form fields persistent between form rebuild and add the firstPass parameter to prepareFormField.

#### `dogs_generator` - `v6.0.0`

 - **REFACTOR**: fix common code style issues.
 - **REFACTOR**: fix some linter warnings.
 - **REFACTOR**: update to lyell 0.1.0.
 - **REFACTOR**: remove long deprecated builder() method.
 - **REFACTOR**: Fix lints and reformatted code.
 - **REFACTOR**: use instance instead of internalInstance everywhere and refactor internalInstance.
 - **REFACTOR**: replace deprecated isDynamic with is DynamicType.
 - **REFACTOR**: apply builder only to the root package since.
 - **REFACTOR**: remove unused variable.
 - **REFACTOR**: auto reformat.
 - **FIX**: make the generator use escaped field getter names.
 - **FIX**: classes implementing core iterables shouldn't be treated as core iterables.
 - **FIX**: add missing whitespace for proper spacing.
 - **FIX**: use aliased identifier.
 - **FIX**: use actual field name instead of property name for generated builder setter.
 - **FIX**: required input now includes .conv.g.dart and runs_before keys are now valid.
 - **FIX**: support super formal fields.
 - **FIX**: log an severe error when a user tries to use class level generics.
 - **FIX**: re-added README.md, generated builders now also have nullable parameters if the field is nullable.
 - **FIX**: use cached alias counter for generating the reactor.
 - **FIX**: refer to the runtimeType of polymorphic.
 - **FIX**: generator linking.
 - **FEAT**: initial commit.
 - **FEAT**: add library option to code generation.
 - **FEAT**: add structure support for built_types.
 - **FEAT**: support non-formal constructor fields with backing fields or getters.
 - **FEAT**: add support for named parameters, fix wrong field identification.
 - **FEAT**: post rebuild hooks.
 - **BREAKING** **REFACTOR**: cleanup structure, modify projection algorithm.
 - **BREAKING** **FEAT**: prepare switch to operations.
 - **BREAKING** **FEAT**: add new converter and polymorphic features.
 - **BREAKING** **FEAT**: added validation, refactored library.
 - **BREAKING** **FEAT**: switch to lyell generator utilities.
 - **BREAKING** **FEAT**: extend structure, openapi schema, rework structure converter.
 - **BREAKING** **FEAT**: polymorphic, serializer implementations, updated structure format.
 - **BREAKING** **FEAT**: major rework and removed deprecations.

#### `dogs_cbor` - `v2.3.0`

 - **FEAT**: add pre/post processors to native codec to clean up format implementations.
 - **FEAT**: adapt all formats to the new toFormat fromFormat scheme and actually make them pass all tests.

#### `dogs_mongo_driver` - `v1.0.0-alpha.11`

 - **REFACTOR**: move pagination objects from dogs_odm to dogs_core.
 - **FEAT**: work on dogs_orm.
 - **FEAT**: cleanup and improve pagination api.
 - **FEAT**(negative): remove too specific query methods.
 - **FEAT**: add pagination and some tests.
 - **FEAT**: dogs_orm and dogs_mongo_driver initial commit.

#### `dogs_odm` - `v1.0.0-alpha.11`

 - **REFACTOR**: make MemoryOdmSystem optionally consume an engine instance or create an identified fork by default.
 - **REFACTOR**: move pagination objects from dogs_odm to dogs_core.
 - **REFACTOR**: rename @id to @idField.
 - **FIX**: change min sdk version to 3.0.0.
 - **FIX**: actually return the serialized page.
 - **FEAT**: add json dump/load functionality for the memory db.
 - **FEAT**: add openapi descriptor to pagination types.
 - **FEAT**: work on dogs_orm.
 - **FEAT**: add PageRequestConverter.
 - **FEAT**: cleanup and improve pagination api.
 - **FEAT**(negative): remove too specific query methods.
 - **FEAT**: add pagination and some tests.
 - **FEAT**: dogs_orm and dogs_mongo_driver initial commit.

#### `dogs_toml` - `v2.3.0`

 - **FEAT**: add pre/post processors to native codec to clean up format implementations.
 - **FEAT**: adapt all formats to the new toFormat fromFormat scheme and actually make them pass all tests.

#### `dogs_yaml` - `v2.3.0`

 - **FEAT**: add pre/post processors to native codec to clean up format implementations.
 - **FEAT**: adapt all formats to the new toFormat fromFormat scheme and actually make them pass all tests.


## 2024-04-23

### Changes

---

Packages with breaking changes:

 - [`dogs_built` - `v3.1.0`](#dogs_built---v310)

Packages with other changes:

 - There are no other changes in this release.

---

#### `dogs_built` - `v3.1.0`

 - **REFACTOR**: use new renamed methods.
 - **REFACTOR**: reformatted code and removed some unused imports.
 - **FIX**: add analysis_options.yaml.
 - **FEAT**: add structure support for built_types.
 - **FEAT**: add dogs_built.
 - **BREAKING** **FEAT**: fully remove the graph operation mode and other deprecations.
 - **BREAKING** **FEAT**: implement the improved built_value support library.


## 2024-04-23

### Changes

---

Packages with breaking changes:

 - [`dogs_core` - `v9.1.0`](#dogs_core---v910)

Packages with other changes:

 - [`dogs_odm` - `v1.0.0-alpha.11`](#dogs_odm---v100-alpha11)
 - [`dogs_built` - `v3.0.1`](#dogs_built---v301)
 - [`dogs_generator` - `v5.3.6`](#dogs_generator---v536)
 - [`dogs_forms` - `v0.1.1+5`](#dogs_forms---v0115)
 - [`dogs_firestore` - `v0.1.0+1`](#dogs_firestore---v0101)
 - [`dogs_toml` - `v2.2.1`](#dogs_toml---v221)
 - [`dogs_cbor` - `v2.2.1`](#dogs_cbor---v221)
 - [`dogs_mongo_driver` - `v1.0.0-alpha.11`](#dogs_mongo_driver---v100-alpha11)
 - [`dogs_yaml` - `v2.2.1`](#dogs_yaml---v221)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_odm` - `v1.0.0-alpha.11`
 - `dogs_built` - `v3.0.1`
 - `dogs_generator` - `v5.3.6`
 - `dogs_forms` - `v0.1.1+5`
 - `dogs_firestore` - `v0.1.0+1`
 - `dogs_toml` - `v2.2.1`
 - `dogs_cbor` - `v2.2.1`
 - `dogs_mongo_driver` - `v1.0.0-alpha.11`
 - `dogs_yaml` - `v2.2.1`

---

#### `dogs_core` - `v9.1.0`

 - **REFACTOR**: make the type discriminator codec configurable.
 - **REFACTOR**: reformat dart code.
 - **REFACTOR**: remove unused polymorphic converters which became obsolete with tree converters.
 - **REFACTOR**: fix some linter warnings.
 - **REFACTOR**: reformat code.
 - **REFACTOR**: support serialization of nullable values.
 - **REFACTOR**: move pagination objects from dogs_odm to dogs_core.
 - **REFACTOR**: Use DogEngine.instance instead of dogs.
 - **REFACTOR**: some small refactoring changes and more api docs.
 - **REFACTOR**: apply prefer final locals.
 - **REFACTOR**: use double quote for dogs_core and add more lints.
 - **REFACTOR**: make projections use native serialization by default.
 - **REFACTOR**: use fieldmap as fallback if toString() using graph serialization fails.
 - **REFACTOR**: auto reformat.
 - **REFACTOR**: improve error handling and add custom exceptions.
 - **REFACTOR**: rename internal firstWhereOrNull to firstWhereOrNullDogs to not clash with collections.
 - **REFACTOR**: reformat code.
 - **REFACTOR**: Fix lints and reformatted code.
 - **REFACTOR**: add @factory annotation.
 - **REFACTOR**: append runtime time to error message for easier debugging.
 - **REFACTOR**: use DogException instead of Exception.
 - **REFACTOR**: export hooks.
 - **REFACTOR**: reformat code and remove some unused variables.
 - **REFACTOR**: update pubspec.yaml.
 - **REFACTOR**: use passed DogEngine reference instead of the static one.
 - **REFACTOR**: remove unused import.
 - **REFACTOR**: use final more often, add some docs along the way.
 - **REFACTOR**: use instance instead of internalInstance everywhere and refactor internalInstance.
 - **REFACTOR**: make fields final and add some docs.
 - **REFACTOR**: add EnumConverter mixin for better readability when used in external packages.
 - **REFACTOR**: use structure harbinger for findConverter instead of the outdated legacy algorithm.
 - **REFACTOR**: reformatted code and removed some unused imports.
 - **REFACTOR**: Use DogEngine.instance instead of dogs.
 - **REFACTOR**: move global dogs field to globals.dart.
 - **REFACTOR**: move IterableKind to engine.
 - **REFACTOR**: fix common code style issues.
 - **REFACTOR**: move annotations to converter.
 - **REFACTOR**: export lyell.
 - **REFACTOR**: use the new mode factories in operation mode resolution.
 - **FIX**: handle null as empty collection if the field is not nullable.
 - **FIX**: use qualified type for native check, not the serial type.
 - **FIX**: broken relative markdown link.
 - **FIX**: replace the wrongly used typeMapping with converterMapping.
 - **FIX**: pass on type argument.
 - **FIX**: make projection not shallow by default.
 - **FIX**: remove unused parameter.
 - **FIX**: downgrade meta package.
 - **FIX**: make the PolymorphicConverter not associated with dynamic by default.
 - **FIX**: only query serial converters for native collections.
 - **FIX**: handle null in serialization.
 - **FIX**: dogs_core tests.
 - **FIX**: add case for synthetic structures.
 - **FIX**: remove dart ffi import.
 - **FIX**: disable test that needs a rework.
 - **FIX**: do not associate polymorphic converters with types anymore.
 - **FIX**: engine ignoring isAssociated.
 - **FIX**: findConverter extension now works as expected.
 - **FIX**: add native to graph visitor.
 - **FIX**: recursively visit entries of maps and lists.
 - **FIX**: ups add trees back.
 - **FIX**: add continue statement I accidentally deleted.
 - **FIX**: nullable structure fields now allow for null values.
 - **FIX**: add item type name to the name of polymorphic schema fields if a cast is specified.
 - **FIX**: handle field visitor specified converters for api schema generation.
 - **FEAT**: add RegExpConverter.
 - **FEAT**: implement native coercion in codec.
 - **FEAT**: add projection transformers and tests for them.
 - **FEAT**: cleanup DogEngine, fully implement child converters.
 - **FEAT**: add support for deeper polymorphic serialization involving primitive types.
 - **FEAT**: dogs_orm and dogs_mongo_driver initial commit.
 - **FEAT**: add constant 'positive' accessor annotation to restrict numbers to be positive or zero.
 - **FEAT**: add serializable library.
 - **FEAT**: add short and more uniform to<Format> methods for native and json.
 - **FEAT**(partial): add handler mechanism.
 - **FEAT**: add simple createIterableFactory api method.
 - **FEAT**: add annotations parameters.
 - **FEAT**: add pre/post processors to native codec to clean up format implementations.
 - **FEAT**: add metadata mixin and use it for the engine.
 - **FEAT**: add mechanism for identifying and retrieving forked engine instances making them reusable.
 - **FEAT**: add opmode factories for extending converter opmodes externally.
 - **FEAT**: add annotations for validators in preparation for dogs_forms.
 - **FEAT**: add pagination objects to dogs_core from dogs_odm.
 - **FEAT**: add better error handling for projections.
 - **FEAT**: initial commit.
 - **FEAT**: add native serializer hooks.
 - **FEAT**: adapt all formats to the new toFormat fromFormat scheme and actually make them pass all tests.
 - **FEAT**: add openapi scheme generation for nargs and iterable converters.
 - **FEAT**: add instantiateFromFieldMap to the structure extensions.
 - **FEAT**: add findStructureByType.
 - **FEAT**: add additional methods for encoding collections as json.
 - **FEAT**: post rebuild hooks.
 - **FEAT**: expand projection to allow for document projection.
 - **FEAT**: add better error handling for api schema validation.
 - **FEAT**: add DogEngine reference to validate calls.
 - **FEAT**: add utils for non graph serializers.
 - **FEAT**: add canSerializeNull for non-structure converters.
 - **FEAT**: add SimpleDogConverter to reduce a bit of boilerplate code.
 - **DOCS**: update polymorphic docs.
 - **DOCS**: add some missing documentation.
 - **DOCS**: add docs for structure proxy.
 - **DOCS**: add documentation for default converters.
 - **DOCS**: add example.md.
 - **DOCS**: add docs comment.
 - **DOCS**: update documentation for Validatable and Copyable.
 - **DOCS**: add missing documentation.
 - **DOCS**: add missing documentation for new methods.
 - **DOCS**: add docs for SimpleDogConverter.
 - **DOCS**: add more documentation to public members.
 - **DOCS**: update example.md and remove empty main.dart.
 - **DOCS**: add missing public member documentation and reformat code.
 - **BREAKING** **REFACTOR**: change positive to exclude 0, add positiveOrNull, as well as negative versions.
 - **BREAKING** **REFACTOR**: remove old non-operation methods.
 - **BREAKING** **REFACTOR**: cleanup structure, modify projection algorithm.
 - **BREAKING** **REFACTOR**: fix new projection algorithm, finish operation mode refactoring.
 - **BREAKING** **REFACTOR**: Require explicit handling of polymorphic tree serialization.
 - **BREAKING** **REFACTOR**: rename findConverterOrThrow.
 - **BREAKING** **FEAT**: add new converter and polymorphic features.
 - **BREAKING** **FEAT**: major rework and removed deprecations.
 - **BREAKING** **FEAT**: prepare switch to operations.
 - **BREAKING** **FEAT**: add simplified type tree system and remove old internal implementations.
 - **BREAKING** **FEAT**: added validation, refactored library.
 - **BREAKING** **FEAT**: switch to lyell generator utilities.
 - **BREAKING** **FEAT**: fully remove the graph operation mode and other deprecations.
 - **BREAKING** **FEAT**: extend structure, openapi schema, rework structure converter.
 - **BREAKING** **FEAT**: polymorphic, serializer implementations, updated structure format.
 - **BREAKING** **FEAT**: add notBlank and email validators.


## 2024-02-27

### Changes

---

Packages with breaking changes:

 - [`dogs_built` - `v3.0.0`](#dogs_built---v300)
 - [`dogs_core` - `v9.0.0`](#dogs_core---v900)
 - [`dogs_firestore` - `v0.1.0`](#dogs_firestore---v010)

Packages with other changes:

 - [`dogs_cbor` - `v2.2.0`](#dogs_cbor---v220)
 - [`dogs_toml` - `v2.2.0`](#dogs_toml---v220)
 - [`dogs_yaml` - `v2.2.0`](#dogs_yaml---v220)
 - [`dogs_generator` - `v5.3.5`](#dogs_generator---v535)
 - [`dogs_forms` - `v0.1.1+4`](#dogs_forms---v0114)
 - [`dogs_odm` - `v1.0.0-alpha.10`](#dogs_odm---v100-alpha10)
 - [`dogs_mongo_driver` - `v1.0.0-alpha.10`](#dogs_mongo_driver---v100-alpha10)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_generator` - `v5.3.5`
 - `dogs_forms` - `v0.1.1+4`
 - `dogs_odm` - `v1.0.0-alpha.10`
 - `dogs_mongo_driver` - `v1.0.0-alpha.10`

---

#### `dogs_built` - `v3.0.0`

 - **BREAKING** **FEAT**: fully remove the graph operation mode and other deprecations.

#### `dogs_core` - `v9.0.0`

 - **REFACTOR**: use DogException instead of Exception.
 - **REFACTOR**: remove unused polymorphic converters which became obsolete with tree converters.
 - **FEAT**: add pre/post processors to native codec to clean up format implementations.
 - **DOCS**: add missing public member documentation and reformat code.
 - **DOCS**: update example.md and remove empty main.dart.
 - **DOCS**: add more documentation to public members.
 - **BREAKING** **FEAT**: fully remove the graph operation mode and other deprecations.

#### `dogs_firestore` - `v0.1.0`

 - **BREAKING** **FEAT**: fully remove the graph operation mode and other deprecations.

#### `dogs_cbor` - `v2.2.0`

 - **FEAT**: add pre/post processors to native codec to clean up format implementations.

#### `dogs_toml` - `v2.2.0`

 - **FEAT**: add pre/post processors to native codec to clean up format implementations.

#### `dogs_yaml` - `v2.2.0`

 - **FEAT**: add pre/post processors to native codec to clean up format implementations.


## 2024-02-25

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_cbor` - `v2.1.0`](#dogs_cbor---v210)
 - [`dogs_core` - `v8.5.0`](#dogs_core---v850)
 - [`dogs_mongo_driver` - `v1.0.0-alpha.9`](#dogs_mongo_driver---v100-alpha9)
 - [`dogs_odm` - `v1.0.0-alpha.9`](#dogs_odm---v100-alpha9)
 - [`dogs_toml` - `v2.1.0`](#dogs_toml---v210)
 - [`dogs_yaml` - `v2.1.0`](#dogs_yaml---v210)
 - [`dogs_generator` - `v5.3.4`](#dogs_generator---v534)
 - [`dogs_firestore` - `v0.0.3+3`](#dogs_firestore---v0033)
 - [`dogs_built` - `v2.0.9`](#dogs_built---v209)
 - [`dogs_forms` - `v0.1.1+3`](#dogs_forms---v0113)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_generator` - `v5.3.4`
 - `dogs_firestore` - `v0.0.3+3`
 - `dogs_built` - `v2.0.9`
 - `dogs_forms` - `v0.1.1+3`

---

#### `dogs_cbor` - `v2.1.0`

 - **FEAT**: adapt all formats to the new toFormat fromFormat scheme and actually make them pass all tests.

#### `dogs_core` - `v8.5.0`

 - **REFACTOR**: reformat code.
 - **REFACTOR**: support serialization of nullable values.
 - **REFACTOR**: move pagination objects from dogs_odm to dogs_core.
 - **FIX**: pass on type argument.
 - **FEAT**: adapt all formats to the new toFormat fromFormat scheme and actually make them pass all tests.
 - **FEAT**: add utils for non graph serializers.
 - **FEAT**: add mechanism for identifying and retrieving forked engine instances making them reusable.
 - **FEAT**: add canSerializeNull for non-structure converters.
 - **FEAT**: add metadata mixin and use it for the engine.
 - **FEAT**: add pagination objects to dogs_core from dogs_odm.

#### `dogs_mongo_driver` - `v1.0.0-alpha.9`

 - **REFACTOR**: move pagination objects from dogs_odm to dogs_core.

#### `dogs_odm` - `v1.0.0-alpha.9`

 - **REFACTOR**: make MemoryOdmSystem optionally consume an engine instance or create an identified fork by default.
 - **REFACTOR**: move pagination objects from dogs_odm to dogs_core.

#### `dogs_toml` - `v2.1.0`

 - **FEAT**: adapt all formats to the new toFormat fromFormat scheme and actually make them pass all tests.

#### `dogs_yaml` - `v2.1.0`

 - **FEAT**: adapt all formats to the new toFormat fromFormat scheme and actually make them pass all tests.


## 2024-02-22

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_generator` - `v5.3.3`](#dogs_generator---v533)
 - [`dogs_odm` - `v1.0.0-alpha.8`](#dogs_odm---v100-alpha8)
 - [`dogs_mongo_driver` - `v1.0.0-alpha.8`](#dogs_mongo_driver---v100-alpha8)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_mongo_driver` - `v1.0.0-alpha.8`

---

#### `dogs_generator` - `v5.3.3`

 - **REFACTOR**: apply builder only to the root package since.

#### `dogs_odm` - `v1.0.0-alpha.8`

 - **FEAT**: add openapi descriptor to pagination types.


## 2024-02-21

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_core` - `v8.4.1`](#dogs_core---v841)
 - [`dogs_generator` - `v5.3.2`](#dogs_generator---v532)
 - [`dogs_firestore` - `v0.0.3+2`](#dogs_firestore---v0032)
 - [`dogs_forms` - `v0.1.1+2`](#dogs_forms---v0112)
 - [`dogs_built` - `v2.0.8`](#dogs_built---v208)
 - [`dogs_odm` - `v1.0.0-alpha.7`](#dogs_odm---v100-alpha7)
 - [`dogs_cbor` - `v2.0.36`](#dogs_cbor---v2036)
 - [`dogs_toml` - `v2.0.36`](#dogs_toml---v2036)
 - [`dogs_mongo_driver` - `v1.0.0-alpha.7`](#dogs_mongo_driver---v100-alpha7)
 - [`dogs_yaml` - `v2.0.36`](#dogs_yaml---v2036)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_generator` - `v5.3.2`
 - `dogs_firestore` - `v0.0.3+2`
 - `dogs_forms` - `v0.1.1+2`
 - `dogs_built` - `v2.0.8`
 - `dogs_odm` - `v1.0.0-alpha.7`
 - `dogs_cbor` - `v2.0.36`
 - `dogs_toml` - `v2.0.36`
 - `dogs_mongo_driver` - `v1.0.0-alpha.7`
 - `dogs_yaml` - `v2.0.36`

---

#### `dogs_core` - `v8.4.1`

 - **FIX**: ups add trees back.


## 2024-02-21

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_core` - `v8.4.0`](#dogs_core---v840)
 - [`dogs_generator` - `v5.3.1`](#dogs_generator---v531)
 - [`dogs_firestore` - `v0.0.3+1`](#dogs_firestore---v0031)
 - [`dogs_forms` - `v0.1.1+1`](#dogs_forms---v0111)
 - [`dogs_odm` - `v1.0.0-alpha.6`](#dogs_odm---v100-alpha6)
 - [`dogs_built` - `v2.0.7`](#dogs_built---v207)
 - [`dogs_mongo_driver` - `v1.0.0-alpha.6`](#dogs_mongo_driver---v100-alpha6)
 - [`dogs_cbor` - `v2.0.35`](#dogs_cbor---v2035)
 - [`dogs_toml` - `v2.0.35`](#dogs_toml---v2035)
 - [`dogs_yaml` - `v2.0.35`](#dogs_yaml---v2035)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_firestore` - `v0.0.3+1`
 - `dogs_forms` - `v0.1.1+1`
 - `dogs_odm` - `v1.0.0-alpha.6`
 - `dogs_built` - `v2.0.7`
 - `dogs_mongo_driver` - `v1.0.0-alpha.6`
 - `dogs_cbor` - `v2.0.35`
 - `dogs_toml` - `v2.0.35`
 - `dogs_yaml` - `v2.0.35`

---

#### `dogs_core` - `v8.4.0`

 - **FEAT**: add openapi scheme generation for nargs and iterable converters.

#### `dogs_generator` - `v5.3.1`

 - **FIX**: add missing whitespace for proper spacing.


## 2024-02-14

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_forms` - `v0.1.1`](#dogs_forms---v011)

---

#### `dogs_forms` - `v0.1.1`

 - **FIX**: correctly pass translations and attributes to child forms.
 - **FIX**: switches and checkboxes with null values should return false.
 - **FEAT**: reorderable lists, automatic structure lists.


## 2024-02-02

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_core` - `v8.3.0`](#dogs_core---v830)
 - [`dogs_firestore` - `v0.0.3`](#dogs_firestore---v003)
 - [`dogs_generator` - `v5.3.0`](#dogs_generator---v530)
 - [`dogs_odm` - `v1.0.0-alpha.5`](#dogs_odm---v100-alpha5)
 - [`dogs_forms` - `v0.1.0+9`](#dogs_forms---v0109)
 - [`dogs_built` - `v2.0.6`](#dogs_built---v206)
 - [`dogs_cbor` - `v2.0.34`](#dogs_cbor---v2034)
 - [`dogs_toml` - `v2.0.34`](#dogs_toml---v2034)
 - [`dogs_mongo_driver` - `v1.0.0-alpha.5`](#dogs_mongo_driver---v100-alpha5)
 - [`dogs_yaml` - `v2.0.34`](#dogs_yaml---v2034)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_forms` - `v0.1.0+9`
 - `dogs_built` - `v2.0.6`
 - `dogs_cbor` - `v2.0.34`
 - `dogs_toml` - `v2.0.34`
 - `dogs_mongo_driver` - `v1.0.0-alpha.5`
 - `dogs_yaml` - `v2.0.34`

---

#### `dogs_core` - `v8.3.0`

 - **FEAT**: add better error handling for projections.
 - **FEAT**: add projection transformers and tests for them.
 - **FEAT**: post rebuild hooks.

#### `dogs_firestore` - `v0.0.3`

 - **FEAT**: fakeable firestore and fixed rebuild copy to include transient fields.

#### `dogs_generator` - `v5.3.0`

 - **FEAT**: post rebuild hooks.

#### `dogs_odm` - `v1.0.0-alpha.5`

 - **REFACTOR**: rename @id to @idField.


## 2024-01-31

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_core` - `v8.2.0`](#dogs_core---v820)
 - [`dogs_firestore` - `v0.0.2+8`](#dogs_firestore---v0028)
 - [`dogs_generator` - `v5.2.4`](#dogs_generator---v524)
 - [`dogs_forms` - `v0.1.0+8`](#dogs_forms---v0108)
 - [`dogs_odm` - `v1.0.0-alpha.4`](#dogs_odm---v100-alpha4)
 - [`dogs_built` - `v2.0.5`](#dogs_built---v205)
 - [`dogs_mongo_driver` - `v1.0.0-alpha.4`](#dogs_mongo_driver---v100-alpha4)
 - [`dogs_cbor` - `v2.0.33`](#dogs_cbor---v2033)
 - [`dogs_toml` - `v2.0.33`](#dogs_toml---v2033)
 - [`dogs_yaml` - `v2.0.33`](#dogs_yaml---v2033)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_firestore` - `v0.0.2+8`
 - `dogs_generator` - `v5.2.4`
 - `dogs_forms` - `v0.1.0+8`
 - `dogs_odm` - `v1.0.0-alpha.4`
 - `dogs_built` - `v2.0.5`
 - `dogs_mongo_driver` - `v1.0.0-alpha.4`
 - `dogs_cbor` - `v2.0.33`
 - `dogs_toml` - `v2.0.33`
 - `dogs_yaml` - `v2.0.33`

---

#### `dogs_core` - `v8.2.0`

 - **REFACTOR**: some small refactoring changes and more api docs.
 - **REFACTOR**: apply prefer final locals.
 - **REFACTOR**: use double quote for dogs_core and add more lints.
 - **FIX**: make projection not shallow by default.
 - **FEAT**: add short and more uniform to<Format> methods for native and json.


## 2024-01-28

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_odm` - `v1.0.0-alpha.3`](#dogs_odm---v100-alpha3)
 - [`dogs_mongo_driver` - `v1.0.0-alpha.3`](#dogs_mongo_driver---v100-alpha3)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_mongo_driver` - `v1.0.0-alpha.3`

---

#### `dogs_odm` - `v1.0.0-alpha.3`

 - **FIX**: change min sdk version to 3.0.0.


## 2024-01-28

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_odm` - `v1.0.0-alpha.2`](#dogs_odm---v100-alpha2)
 - [`dogs_mongo_driver` - `v1.0.0-alpha.2`](#dogs_mongo_driver---v100-alpha2)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_mongo_driver` - `v1.0.0-alpha.2`

---

#### `dogs_odm` - `v1.0.0-alpha.2`

 - **FIX**: actually return the serialized page.


## 2024-01-27

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_core` - `v8.1.1`](#dogs_core---v811)
 - [`dogs_generator` - `v5.2.3`](#dogs_generator---v523)
 - [`dogs_firestore` - `v0.0.2+7`](#dogs_firestore---v0027)
 - [`dogs_odm` - `v1.0.0-alpha.1`](#dogs_odm---v100-alpha1)
 - [`dogs_forms` - `v0.1.0+7`](#dogs_forms---v0107)
 - [`dogs_built` - `v2.0.4`](#dogs_built---v204)
 - [`dogs_cbor` - `v2.0.32`](#dogs_cbor---v2032)
 - [`dogs_mongo_driver` - `v1.0.0-alpha.1`](#dogs_mongo_driver---v100-alpha1)
 - [`dogs_toml` - `v2.0.32`](#dogs_toml---v2032)
 - [`dogs_yaml` - `v2.0.32`](#dogs_yaml---v2032)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_generator` - `v5.2.3`
 - `dogs_firestore` - `v0.0.2+7`
 - `dogs_odm` - `v1.0.0-alpha.1`
 - `dogs_forms` - `v0.1.0+7`
 - `dogs_built` - `v2.0.4`
 - `dogs_cbor` - `v2.0.32`
 - `dogs_mongo_driver` - `v1.0.0-alpha.1`
 - `dogs_toml` - `v2.0.32`
 - `dogs_yaml` - `v2.0.32`

---

#### `dogs_core` - `v8.1.1`

 - **REFACTOR**: make projections use native serialization by default.


## 2024-01-27

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_mongo_driver` - `v1.0.0-alpha.0`](#dogs_mongo_driver---v100-alpha0)
 - [`dogs_odm` - `v1.0.0-alpha.0`](#dogs_odm---v100-alpha0)

---

#### `dogs_mongo_driver` - `v1.0.0-alpha.0`

 - Readme & License

#### `dogs_odm` - `v1.0.0-alpha.0`

 - Readme & License


## 2024-01-27

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_mongo_driver` - `v1.0.0-alpha.0`](#dogs_mongo_driver---v100-alpha0)
 - [`dogs_odm` - `v1.0.0-alpha.0`](#dogs_odm---v100-alpha0)
 - [`dogs_core` - `v8.1.0`](#dogs_core---v810)
 - [`dogs_firestore` - `v0.0.2+6`](#dogs_firestore---v0026)
 - [`dogs_generator` - `v5.2.2`](#dogs_generator---v522)
 - [`dogs_forms` - `v0.1.0+6`](#dogs_forms---v0106)
 - [`dogs_built` - `v2.0.3`](#dogs_built---v203)
 - [`dogs_cbor` - `v2.0.31`](#dogs_cbor---v2031)
 - [`dogs_toml` - `v2.0.31`](#dogs_toml---v2031)
 - [`dogs_yaml` - `v2.0.31`](#dogs_yaml---v2031)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_firestore` - `v0.0.2+6`
 - `dogs_generator` - `v5.2.2`
 - `dogs_forms` - `v0.1.0+6`
 - `dogs_built` - `v2.0.3`
 - `dogs_cbor` - `v2.0.31`
 - `dogs_toml` - `v2.0.31`
 - `dogs_yaml` - `v2.0.31`

---

#### `dogs_mongo_driver` - `v1.0.0-alpha.0`

 - **FEAT**: work on dogs_orm.
 - **FEAT**: cleanup and improve pagination api.
 - **FEAT**(negative): remove too specific query methods.
 - **FEAT**: add pagination and some tests.
 - **FEAT**: dogs_orm and dogs_mongo_driver initial commit.

#### `dogs_odm` - `v1.0.0-alpha.0`

 - **FEAT**: work on dogs_orm.
 - **FEAT**: add PageRequestConverter.
 - **FEAT**: cleanup and improve pagination api.
 - **FEAT**(negative): remove too specific query methods.
 - **FEAT**: add pagination and some tests.
 - **FEAT**: dogs_orm and dogs_mongo_driver initial commit.

#### `dogs_core` - `v8.1.0`

 - **REFACTOR**: use fieldmap as fallback if toString() using graph serialization fails.
 - **REFACTOR**: make the type discriminator codec configurable.
 - **FIX**: downgrade meta package.
 - **FEAT**: add RegExpConverter.
 - **FEAT**: dogs_orm and dogs_mongo_driver initial commit.


## 2024-01-25

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_core` - `v8.0.2`](#dogs_core---v802)
 - [`dogs_firestore` - `v0.0.2+5`](#dogs_firestore---v0025)
 - [`dogs_forms` - `v0.1.0+5`](#dogs_forms---v0105)
 - [`dogs_generator` - `v5.2.1`](#dogs_generator---v521)
 - [`dogs_cbor` - `v2.0.30`](#dogs_cbor---v2030)
 - [`dogs_toml` - `v2.0.30`](#dogs_toml---v2030)
 - [`dogs_built` - `v2.0.2`](#dogs_built---v202)
 - [`dogs_yaml` - `v2.0.30`](#dogs_yaml---v2030)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_firestore` - `v0.0.2+5`
 - `dogs_forms` - `v0.1.0+5`
 - `dogs_generator` - `v5.2.1`
 - `dogs_cbor` - `v2.0.30`
 - `dogs_toml` - `v2.0.30`
 - `dogs_built` - `v2.0.2`
 - `dogs_yaml` - `v2.0.30`

---

#### `dogs_core` - `v8.0.2`

 - **REFACTOR**: improve error handling and add custom exceptions.


## 2024-01-24

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_core` - `v8.0.1`](#dogs_core---v801)
 - [`dogs_generator` - `v5.2.0`](#dogs_generator---v520)
 - [`dogs_firestore` - `v0.0.2+4`](#dogs_firestore---v0024)
 - [`dogs_cbor` - `v2.0.29`](#dogs_cbor---v2029)
 - [`dogs_forms` - `v0.1.0+4`](#dogs_forms---v0104)
 - [`dogs_toml` - `v2.0.29`](#dogs_toml---v2029)
 - [`dogs_built` - `v2.0.1`](#dogs_built---v201)
 - [`dogs_yaml` - `v2.0.29`](#dogs_yaml---v2029)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_firestore` - `v0.0.2+4`
 - `dogs_cbor` - `v2.0.29`
 - `dogs_forms` - `v0.1.0+4`
 - `dogs_toml` - `v2.0.29`
 - `dogs_built` - `v2.0.1`
 - `dogs_yaml` - `v2.0.29`

---

#### `dogs_core` - `v8.0.1`

 - **REFACTOR**: rename internal firstWhereOrNull to firstWhereOrNullDogs to not clash with collections.

#### `dogs_generator` - `v5.2.0`

 - **FEAT**: support non-formal constructor fields with backing fields or getters.


## 2024-01-23

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_generator` - `v5.1.2`](#dogs_generator---v512)

---

#### `dogs_generator` - `v5.1.2`


## 2024-01-23

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_generator` - `v5.1.1`](#dogs_generator---v511)

---

#### `dogs_generator` - `v5.1.1`

 - **REFACTOR**: remove long deprecated builder() method.
 - **FIX**: support super formal fields.


## 2024-01-23

### Changes

---

Packages with breaking changes:

 - [`dogs_built` - `v2.0.0`](#dogs_built---v200)
 - [`dogs_core` - `v8.0.0`](#dogs_core---v800)

Packages with other changes:

 - [`dogs_forms` - `v0.1.0+3`](#dogs_forms---v0103)
 - [`dogs_generator` - `v5.1.0`](#dogs_generator---v510)
 - [`dogs_firestore` - `v0.0.2+3`](#dogs_firestore---v0023)
 - [`dogs_cbor` - `v2.0.28`](#dogs_cbor---v2028)
 - [`dogs_toml` - `v2.0.28`](#dogs_toml---v2028)
 - [`dogs_yaml` - `v2.0.28`](#dogs_yaml---v2028)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_firestore` - `v0.0.2+3`
 - `dogs_cbor` - `v2.0.28`
 - `dogs_toml` - `v2.0.28`
 - `dogs_yaml` - `v2.0.28`

---

#### `dogs_built` - `v2.0.0`

 - **FEAT**: add structure support for built_types.
 - **BREAKING** **FEAT**: implement the improved built_value support library.

#### `dogs_core` - `v8.0.0`

 - **REFACTOR**: reformat code.
 - **REFACTOR**: append runtime time to error message for easier debugging.
 - **REFACTOR**: export hooks.
 - **FIX**: use qualified type for native check, not the serial type.
 - **FEAT**: add SimpleDogConverter to reduce a bit of boilerplate code.
 - **FEAT**: add serializable library.
 - **FEAT**: add simple createIterableFactory api method.
 - **FEAT**: add native serializer hooks.
 - **DOCS**: add docs for SimpleDogConverter.
 - **DOCS**: add missing documentation for new methods.
 - **BREAKING** **FEAT**: add simplified type tree system and remove old internal implementations.

#### `dogs_forms` - `v0.1.0+3`

 - **REFACTOR**: change to new field name.

#### `dogs_generator` - `v5.1.0`

 - **FIX**: log an severe error when a user tries to use class level generics.
 - **FIX**: classes implementing core iterables shouldn't be treated as core iterables.
 - **FIX**: use aliased identifier.
 - **FEAT**: add structure support for built_types.


## 2024-01-14

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_forms` - `v0.1.0+2`](#dogs_forms---v0102)

---

#### `dogs_forms` - `v0.1.0+2`

 - **FIX**: remove debug print and use instantValue instead of value.


## 2024-01-14

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_forms` - `v0.1.0+1`](#dogs_forms---v0101)

---

#### `dogs_forms` - `v0.1.0+1`

 - **FIX**: persist latest form values and fix set not propagating to form fields.


## 2024-01-14

### Changes

---

Packages with breaking changes:

 - [`dogs_forms` - `v0.1.0`](#dogs_forms---v010)

Packages with other changes:

 - There are no other changes in this release.

---

#### `dogs_forms` - `v0.1.0`

 - **BREAKING** **FEAT**: make form fields persistent between form rebuild and add the firstPass parameter to prepareFormField.


## 2024-01-13

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_core` - `v7.2.2`](#dogs_core---v722)
 - [`dogs_firestore` - `v0.0.2+2`](#dogs_firestore---v0022)
 - [`dogs_forms` - `v0.0.1+2`](#dogs_forms---v0012)
 - [`dogs_generator` - `v5.0.13`](#dogs_generator---v5013)
 - [`dogs_cbor` - `v2.0.27`](#dogs_cbor---v2027)
 - [`dogs_toml` - `v2.0.27`](#dogs_toml---v2027)
 - [`dogs_built` - `v1.0.9`](#dogs_built---v109)
 - [`dogs_yaml` - `v2.0.27`](#dogs_yaml---v2027)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_firestore` - `v0.0.2+2`
 - `dogs_forms` - `v0.0.1+2`
 - `dogs_generator` - `v5.0.13`
 - `dogs_cbor` - `v2.0.27`
 - `dogs_toml` - `v2.0.27`
 - `dogs_built` - `v1.0.9`
 - `dogs_yaml` - `v2.0.27`

---

#### `dogs_core` - `v7.2.2`

 - **REFACTOR**: reformat code and remove some unused variables.


## 2024-01-13

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_core` - `v7.2.1`](#dogs_core---v721)
 - [`dogs_firestore` - `v0.0.2+1`](#dogs_firestore---v0021)
 - [`dogs_generator` - `v5.0.12`](#dogs_generator---v5012)
 - [`dogs_forms` - `v0.0.1+1`](#dogs_forms---v0011)
 - [`dogs_cbor` - `v2.0.26`](#dogs_cbor---v2026)
 - [`dogs_toml` - `v2.0.26`](#dogs_toml---v2026)
 - [`dogs_built` - `v1.0.8`](#dogs_built---v108)
 - [`dogs_yaml` - `v2.0.26`](#dogs_yaml---v2026)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_firestore` - `v0.0.2+1`
 - `dogs_generator` - `v5.0.12`
 - `dogs_forms` - `v0.0.1+1`
 - `dogs_cbor` - `v2.0.26`
 - `dogs_toml` - `v2.0.26`
 - `dogs_built` - `v1.0.8`
 - `dogs_yaml` - `v2.0.26`

---

#### `dogs_core` - `v7.2.1`

 - **REFACTOR**: update pubspec.yaml.


## 2024-01-13

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_firestore` - `v0.0.2`](#dogs_firestore---v002)

---

#### `dogs_firestore` - `v0.0.2`

 - **FIX**: rename example package to not have the same name as a dependency.
 - **FEAT**: add more query methods and $store.


## 2024-01-12

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_built` - `v1.0.7`](#dogs_built---v107)
 - [`dogs_core` - `v7.2.0`](#dogs_core---v720)
 - [`dogs_firestore` - `v0.0.1`](#dogs_firestore---v001)
 - [`dogs_forms` - `v0.0.1`](#dogs_forms---v001)
 - [`dogs_generator` - `v5.0.11`](#dogs_generator---v5011)
 - [`dogs_yaml` - `v2.0.25`](#dogs_yaml---v2025)
 - [`dogs_cbor` - `v2.0.25`](#dogs_cbor---v2025)
 - [`dogs_toml` - `v2.0.25`](#dogs_toml---v2025)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_cbor` - `v2.0.25`
 - `dogs_toml` - `v2.0.25`

---

#### `dogs_built` - `v1.0.7`

 - **REFACTOR**: use new renamed methods.

#### `dogs_core` - `v7.2.0`

 - **REFACTOR**: use the new mode factories in operation mode resolution.
 - **REFACTOR**: use final more often, add some docs along the way.
 - **REFACTOR**: make fields final and add some docs.
 - **REFACTOR**: add EnumConverter mixin for better readability when used in external packages.
 - **FIX**: replace the wrongly used typeMapping with converterMapping.
 - **FEAT**: implement native coercion in codec.
 - **FEAT**: cleanup DogEngine, fully implement child converters.
 - **FEAT**: add opmode factories for extending converter opmodes externally.
 - **FEAT**: add annotations for validators in preparation for dogs_forms.
 - **DOCS**: add missing documentation.
 - **DOCS**: add docs comment.

#### `dogs_firestore` - `v0.0.1`

 - **FEAT**: changes, queries and snapshot system for document reference.
 - **FEAT**: first working version of dogs_firestore 🎉.

#### `dogs_forms` - `v0.0.1`

 - **REFACTOR**: use custom preference.
 - **FEAT**: add optional factory and a whole lot of reworks.
 - **FEAT**: add hint and prefix, suffix fields.
 - **FEAT**: add mechanism for precaching form field data that is then.
 - **FEAT**: add first working version of dogs_forms 🎉.

#### `dogs_generator` - `v5.0.11`

 - **REFACTOR**: replace deprecated isDynamic with is DynamicType.

#### `dogs_yaml` - `v2.0.25`

 - **FIX**: Handle empty string for yaml serializer and add test case.


## 2023-11-23

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_core` - `v7.1.1`](#dogs_core---v711)
 - [`dogs_generator` - `v5.0.10`](#dogs_generator---v5010)
 - [`dogs_toml` - `v2.0.24`](#dogs_toml---v2024)
 - [`dogs_cbor` - `v2.0.24`](#dogs_cbor---v2024)
 - [`dogs_built` - `v1.0.6`](#dogs_built---v106)
 - [`dogs_yaml` - `v2.0.24`](#dogs_yaml---v2024)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_generator` - `v5.0.10`
 - `dogs_toml` - `v2.0.24`
 - `dogs_cbor` - `v2.0.24`
 - `dogs_built` - `v1.0.6`
 - `dogs_yaml` - `v2.0.24`

---

#### `dogs_core` - `v7.1.1`

 - **FIX**: remove unused parameter.


## 2023-11-23

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_core` - `v7.1.0`](#dogs_core---v710)
 - [`dogs_generator` - `v5.0.9`](#dogs_generator---v509)
 - [`dogs_cbor` - `v2.0.23`](#dogs_cbor---v2023)
 - [`dogs_toml` - `v2.0.23`](#dogs_toml---v2023)
 - [`dogs_built` - `v1.0.5`](#dogs_built---v105)
 - [`dogs_yaml` - `v2.0.23`](#dogs_yaml---v2023)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_generator` - `v5.0.9`
 - `dogs_cbor` - `v2.0.23`
 - `dogs_toml` - `v2.0.23`
 - `dogs_built` - `v1.0.5`
 - `dogs_yaml` - `v2.0.23`

---

#### `dogs_core` - `v7.1.0`

 - **REFACTOR**: use structure harbinger for findConverter instead of the outdated legacy algorithm.
 - **FEAT**: add instantiateFromFieldMap to the structure extensions.
 - **DOCS**: add some missing documentation.


## 2023-09-29

### Changes

---

Packages with breaking changes:

 - [`dogs_core` - `v7.0.0`](#dogs_core---v700)

Packages with other changes:

 - [`dogs_generator` - `v5.0.8`](#dogs_generator---v508)
 - [`dogs_cbor` - `v2.0.22`](#dogs_cbor---v2022)
 - [`dogs_toml` - `v2.0.22`](#dogs_toml---v2022)
 - [`dogs_built` - `v1.0.4`](#dogs_built---v104)
 - [`dogs_yaml` - `v2.0.22`](#dogs_yaml---v2022)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_cbor` - `v2.0.22`
 - `dogs_toml` - `v2.0.22`
 - `dogs_built` - `v1.0.4`
 - `dogs_yaml` - `v2.0.22`

---

#### `dogs_core` - `v7.0.0`

 - **FIX**: only query serial converters for native collections.
 - **FEAT**: expand projection to allow for document projection.
 - **BREAKING** **REFACTOR**: Require explicit handling of polymorphic tree serialization.

#### `dogs_generator` - `v5.0.8`

 - **REFACTOR**: remove unused variable.
 - **FIX**: make the generator use escaped field getter names.


## 2023-09-14

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_core` - `v6.1.1`](#dogs_core---v611)
 - [`dogs_generator` - `v5.0.7`](#dogs_generator---v507)
 - [`dogs_toml` - `v2.0.21`](#dogs_toml---v2021)
 - [`dogs_cbor` - `v2.0.21`](#dogs_cbor---v2021)
 - [`dogs_built` - `v1.0.3`](#dogs_built---v103)
 - [`dogs_yaml` - `v2.0.21`](#dogs_yaml---v2021)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_generator` - `v5.0.7`
 - `dogs_toml` - `v2.0.21`
 - `dogs_cbor` - `v2.0.21`
 - `dogs_built` - `v1.0.3`
 - `dogs_yaml` - `v2.0.21`

---

#### `dogs_core` - `v6.1.1`

 - **FIX**: handle null in serialization.


## 2023-09-14

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_core` - `v6.1.0`](#dogs_core---v610)
 - [`dogs_generator` - `v5.0.6`](#dogs_generator---v506)
 - [`dogs_cbor` - `v2.0.20`](#dogs_cbor---v2020)
 - [`dogs_toml` - `v2.0.20`](#dogs_toml---v2020)
 - [`dogs_built` - `v1.0.2`](#dogs_built---v102)
 - [`dogs_yaml` - `v2.0.20`](#dogs_yaml---v2020)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_generator` - `v5.0.6`
 - `dogs_cbor` - `v2.0.20`
 - `dogs_toml` - `v2.0.20`
 - `dogs_built` - `v1.0.2`
 - `dogs_yaml` - `v2.0.20`

---

#### `dogs_core` - `v6.1.0`

 - **FIX**: broken relative markdown link.
 - **FEAT**: add support for deeper polymorphic serialization involving primitive types.


## 2023-09-08

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_built` - `v1.0.1`](#dogs_built---v101)
 - [`dogs_core` - `v6.0.3`](#dogs_core---v603)
 - [`dogs_generator` - `v5.0.5`](#dogs_generator---v505)
 - [`dogs_cbor` - `v2.0.19`](#dogs_cbor---v2019)
 - [`dogs_toml` - `v2.0.19`](#dogs_toml---v2019)
 - [`dogs_yaml` - `v2.0.19`](#dogs_yaml---v2019)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_generator` - `v5.0.5`
 - `dogs_cbor` - `v2.0.19`
 - `dogs_toml` - `v2.0.19`
 - `dogs_yaml` - `v2.0.19`

---

#### `dogs_built` - `v1.0.1`

 - **REFACTOR**: reformatted code and removed some unused imports.

#### `dogs_core` - `v6.0.3`

 - **REFACTOR**: reformatted code and removed some unused imports.
 - **DOCS**: add example.md.


## 2023-09-08

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`dogs_built` - `v1.0.0`](#dogs_built---v100)
 - [`dogs_core` - `v6.0.2`](#dogs_core---v602)
 - [`dogs_generator` - `v5.0.4`](#dogs_generator---v504)
 - [`dogs_cbor` - `v2.0.18`](#dogs_cbor---v2018)
 - [`dogs_toml` - `v2.0.18`](#dogs_toml---v2018)
 - [`dogs_yaml` - `v2.0.18`](#dogs_yaml---v2018)

Packages with dependency updates only:

> Packages listed below depend on other packages in this workspace that have had changes. Their versions have been incremented to bump the minimum dependency versions of the packages they depend upon in this project.

 - `dogs_generator` - `v5.0.4`
 - `dogs_cbor` - `v2.0.18`
 - `dogs_toml` - `v2.0.18`
 - `dogs_yaml` - `v2.0.18`

---

#### `dogs_built` - `v1.0.0`

 - **FIX**: add analysis_options.yaml.
 - **FEAT**: add dogs_built.

#### `dogs_core` - `v6.0.2`

 - **FIX**: dogs_core tests.
 - **FIX**: add case for synthetic structures.
 - **FIX**: remove dart ffi import.

