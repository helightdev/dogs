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
