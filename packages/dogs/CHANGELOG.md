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
