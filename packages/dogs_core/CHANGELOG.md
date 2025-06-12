## 10.0.0-dev.4

 - **FEAT**: enhance enum serialization with fallback and name overrides.
 - **FEAT**: add field and class level serialization hooks to exclude null values.

## 10.0.0-dev.3

> Note: This release has breaking changes.

 - **FIX**: Make operation field nullable to handle converters without validation.
 - **BREAKING** **FEAT**: various changes to the core system to support runtime generated structures.

## 10.0.0-dev.2

 - **REFACTOR**: remove the supplier argument.

## 10.0.0-dev.1

 - **REFACTOR**: add field map projections.

## 10.0.0-dev.0

> Note: This release has breaking changes.

 - **REFACTOR**: make the harbinger return bridge converters.
 - **REFACTOR**: adjust default validators and extensions for the upgraded validation system.
 - **REFACTOR**: use converter type argument as fallback.
 - **REFACTOR**: limited support for non qualified type trees.
 - **FIX**: throw proper exception when dog isn't currently initialized.
 - **FEAT**: add nullable converter resolver.
 - **FEAT**: add generator extension.
 - **FEAT**: Add new more explicit system for projection.
 - **FEAT**: add a way to override the global dog engine instance for custom call scopes.
 - **BREAKING** **REFACTOR**: make validation more generally usable.
 - **BREAKING** **FEAT**: remove the usage of iterable kinds for serialization.
 - **BREAKING** **FEAT**: replace the schema validation with custom implementation.
 - **BREAKING** **FEAT**: use context objects for structure native hooks.

## 9.4.1

 - **FIX**: Use entry list for non string key based maps serialized using MapNTreeArgConverter.

## 9.4.0

 - **FEAT**: add field serialization hook and the DefaultValue field annotation.

## 9.3.0

 - **FEAT**: add native property annotation to retain field values during serialization and deserialization.

## 9.2.0

 - **FEAT**: reimplement number primitive coercion and make it the default as a mitigation for common webserver interop problems.

## 9.1.0

 - **NOTE** We lost the changelog for this version, I was to dumb to use melos correctly. 

## 9.0.0

> Note: This release has breaking changes.

 - **REFACTOR**: use DogException instead of Exception.
 - **REFACTOR**: remove unused polymorphic converters which became obsolete with tree converters.
 - **FEAT**: add pre/post processors to native codec to clean up format implementations.
 - **DOCS**: add missing public member documentation and reformat code.
 - **DOCS**: update example.md and remove empty main.dart.
 - **DOCS**: add more documentation to public members.
 - **BREAKING** **FEAT**: fully remove the graph operation mode and other deprecations.

## 8.5.0

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

## 8.4.1

 - **FIX**: ups add trees back.

## 8.4.0

 - **FEAT**: add openapi scheme generation for nargs and iterable converters.

## 8.3.0

 - **FEAT**: add better error handling for projections.
 - **FEAT**: add projection transformers and tests for them.
 - **FEAT**: post rebuild hooks.

## 8.2.0

 - **REFACTOR**: some small refactoring changes and more api docs.
 - **REFACTOR**: apply prefer final locals.
 - **REFACTOR**: use double quote for dogs_core and add more lints.
 - **FIX**: make projection not shallow by default.
 - **FEAT**: add short and more uniform to<Format> methods for native and json.

## 8.1.1

 - **REFACTOR**: make projections use native serialization by default.

## 8.1.0

 - **REFACTOR**: use fieldmap as fallback if toString() using graph serialization fails.
 - **REFACTOR**: make the type discriminator codec configurable.
 - **FIX**: downgrade meta package.
 - **FEAT**: add RegExpConverter.
 - **FEAT**: dogs_orm and dogs_mongo_driver initial commit.

## 8.0.2

 - **REFACTOR**: improve error handling and add custom exceptions.

## 8.0.1

 - **REFACTOR**: rename internal firstWhereOrNull to firstWhereOrNullDogs to not clash with collections.

## 8.0.0

> Note: This release has breaking changes.

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

## 7.2.2

 - **REFACTOR**: reformat code and remove some unused variables.

## 7.2.1

 - **REFACTOR**: update pubspec.yaml.

## 7.2.0

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

## 7.1.1

 - **FIX**: remove unused parameter.

## 7.1.0

 - **REFACTOR**: use structure harbinger for findConverter instead of the outdated legacy algorithm.
 - **FEAT**: add instantiateFromFieldMap to the structure extensions.
 - **DOCS**: add some missing documentation.

## 7.0.0

> Note: This release has breaking changes.

 - **FIX**: only query serial converters for native collections.
 - **FEAT**: expand projection to allow for document projection.
 - **BREAKING** **REFACTOR**: Require explicit handling of polymorphic tree serialization.

## 6.1.1

 - **FIX**: handle null in serialization.

## 6.1.0

 - **FIX**: broken relative markdown link.
 - **FEAT**: add support for deeper polymorphic serialization involving primitive types.

## 6.0.3

 - **REFACTOR**: reformatted code and removed some unused imports.
 - **DOCS**: add example.md.

## 6.0.2

 - **FIX**: dogs_core tests.
 - **FIX**: add case for synthetic structures.
 - **FIX**: remove dart ffi import.

## 6.0.1

 - **FIX**: remove dart ffi import.
 - **FIX**: disable test that needs a rework.

## 6.0.0

 - incremental version

## 6.0.1

 - **FIX**: disable test that needs a rework.

## 6.0.0

> Note: This release has breaking changes.

 - **BREAKING** **REFACTOR**: fix new projection algorithm, finish operation mode refactoring.
 - **BREAKING** **REFACTOR**: cleanup structure, modify projection algorithm.
 - **BREAKING** **REFACTOR**: remove old non-operation methods.
 - **BREAKING** **FEAT**: prepare switch to operations.

## 5.0.3

 - **FIX**: findConverter extension now works as expected.

## 5.0.2

 - **REFACTOR**: fix common code style issues.
 - **FIX**: add native to graph visitor.

## 5.0.1

 - **FIX**: recursively visit entries of maps and lists.
 - **FIX**: handle null as empty collection if the field is not nullable.

## 5.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: major rework and removed deprecations.

## 4.2.1

 - **FIX**: add continue statement I accidentally deleted.

## 4.2.0

 - **REFACTOR**: export lyell.
 - **FIX**: nullable structure fields now allow for null values.
 - **FEAT**: add findStructureByType.
 - **FEAT**: add additional methods for encoding collections as json.

## 4.1.2

 - **FIX**: add item type name to the name of polymorphic schema fields if a cast is specified.

## 4.1.1

 - **FIX**: handle field visitor specified converters for api schema generation.

## 4.1.0

 - **FEAT**: add better error handling for api schema validation.

## 4.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: add new converter and polymorphic features.

## 3.0.0

> Note: This release has breaking changes.

 - **BREAKING** **REFACTOR**: change positive to exclude 0, add positiveOrNull, as well as negative versions.
 - **BREAKING** **FEAT**: add notBlank and email validators.

## 2.1.1

 - **REFACTOR**: auto reformat.
 - **REFACTOR**: remove unused import.
 - **FIX**: do not associate polymorphic converters with types anymore.

## 2.1.0

 - **REFACTOR**: move annotations to converter.
 - **REFACTOR**: move IterableKind to engine.
 - **REFACTOR**: move global dogs field to globals.dart.
 - **REFACTOR**: Use DogEngine.instance instead of dogs.
 - **REFACTOR**: Use DogEngine.instance instead of dogs.
 - **REFACTOR**: use instance instead of internalInstance everywhere and refactor internalInstance.
 - **REFACTOR**: use passed DogEngine reference instead of the static one.
 - **REFACTOR**: add @factory annotation.
 - **FIX**: make the PolymorphicConverter not associated with dynamic by default.
 - **FEAT**: add annotations parameters.
 - **FEAT**: add constant 'positive' accessor annotation to restrict numbers to be positive or zero.
 - **FEAT**: add DogEngine reference to validate calls.
 - **DOCS**: update polymorphic docs.
 - **DOCS**: add docs for structure proxy.
 - **DOCS**: add documentation for default converters.
 - **DOCS**: update documentation for Validatable and Copyable.

## 2.0.0

> Note: This release has breaking changes.

 - **REFACTOR**: Fix lints and reformatted code.
 - **REFACTOR**: fix some linter warnings.
 - **FIX**: engine ignoring isAssociated.
 - **FEAT**: add handler mechanism.
 - **BREAKING** **REFACTOR**: rename findConverterOrThrow.
 - **BREAKING** **FEAT**: added validation, refactored library.
 - **BREAKING** **FEAT**: switch to lyell generator utilities.
 - **BREAKING** **FEAT**: extend structure, openapi schema, rework structure converter.

## 1.0.0

> Note: This release has breaking changes.

 - **BREAKING** **FEAT**: polymorphic, serializer implementations, updated structure format.

## 1.0.0-alpha

 - Bump "dogs_core" to `1.0.0-alpha`.

## 1.0.0-alpha

 - **REFACTOR**: reformat dart code.
 - **FEAT**: initial commit.

## 1.0.0-alpha

 - Bump "dogs" to `1.0.0-alpha`.

## 1.0.0

 - **REFACTOR**: reformat dart code.
 - **FEAT**: initial commit.

## 1.0.0

- Initial version.
