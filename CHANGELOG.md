# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

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

