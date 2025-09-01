/*
 *    Copyright 2022, the DOGs authors
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

import "package:collection/collection.dart";
import "package:dogs_core/dogs_core.dart";
import "package:meta/meta.dart";

/// Property level validator for annotations of [DogStructureField]s.
abstract class FieldValidator<T> {
  /// Property level validator for annotations of [DogStructureField]s.
  const FieldValidator();

  /// Verifies the usage of this validator in [field].
  void verifyUsage(DogStructureField field) {}

  /// Returns a cached value for this validator. Will be passed to [validate]
  /// on every validation.
  T getCachedValue(DogStructureField field) => null as T;

  /// Validates [value] against this validator.
  bool validate(T cached, dynamic value, DogEngine engine);

  /// Annotates [value] with this validator returning an [AnnotationResult].
  /// This mechanic is used to provide more information about the validation
  /// error.
  AnnotationResult annotate(T cached, dynamic value, DogEngine engine) =>
      AnnotationResult.empty();
}

/// Class level validator for annotations of [ClassValidator]s.
abstract class ClassValidator<T> {
  /// Class level validator for annotations of [ClassValidator]s.
  const ClassValidator();

  /// Verifies the usage of this validator in [structure].
  void verifyUsage(DogStructure structure) {}

  /// Returns a cached value for this validator. Will be passed to [validate]
  T getCachedValue(DogStructure structure) => null as T;

  /// Validates [value] against this validator.
  bool validate(T cached, dynamic value, DogEngine engine);

  /// Annotates [value] with this validator returning an [AnnotationResult].
  /// This mechanic is used to provide more information about the validation
  /// error.
  AnnotationResult annotate(T cached, dynamic value, DogEngine engine) =>
      AnnotationResult.empty();
}

/// Field level validator that has access to the whole class instance.
abstract class ContextFieldValidator<T> {

  /// Field level validator that has access to the whole class instance.
  const ContextFieldValidator();

  /// Field level validator that has access to the whole class instance.
  void verifyUsage(DogStructure structure, DogStructureField field) {}

  /// Returns a cached value for this validator. Will be passed to [validate]
  T getCachedValue(DogStructure structure, DogStructureField field) =>
      null as T;

  /// Validates [instance] against this validator, where [instance] is not
  /// the field value but the whole class instance.
  bool validate(T cached, dynamic instance, DogEngine engine);

  /// Annotates [instance] with this validator returning an [AnnotationResult].
  /// This mechanic is used to provide more information about the validation
  /// error.
  AnnotationResult annotate(T cached, dynamic instance, DogEngine engine) =>
      AnnotationResult.empty();
}

/// A [ValidationMode] that provides validation for [DogStructure]s.
class StructureValidation<T> extends ValidationMode<T>
    with TypeCaptureMixin<T> {
  /// The structure this validator is for.
  DogStructure<T> structure;

  /// Creates a new [StructureValidation] for the supplied [structure].
  StructureValidation(this.structure);

  bool _hasValidation = false;
  late IsolatedClassValidator _validator;

  @override
  void initialise(DogEngine engine) {
    _validator = structure.getClassValidator(engine: engine);
    _hasValidation = _validator.validatorCount > 0;
  }

  @override
  bool validate(T value, DogEngine engine) {
    if (!_hasValidation) return true;
    return _validator.isValid(value);
  }

  @override
  AnnotationResult annotate(T value, DogEngine engine) {
    if (!_hasValidation) return AnnotationResult.empty();
    return _validator.annotate(value);
  }
}

/// Validates a single field independent of the whole structure.
class IsolatedFieldValidator {
  final DogEngine _engine;
  final DogStructureField _field;
  final List<dynamic> _fieldValidatorCacheData;
  final List<FieldValidator> _fieldValidators;
  final bool _hasGuardValidator;

  /// The number of validators in this instance.
  late final int validatorCount = _fieldValidators.length;

  @internal
  // ignore: public_member_api_docs
  IsolatedFieldValidator({
    required DogEngine engine,
    required DogStructureField field,
    required List<dynamic> fieldValidatorCacheData,
    required List<FieldValidator> fieldValidators,
    required bool hasGuardValidator,
  })  : _fieldValidators = fieldValidators,
        _fieldValidatorCacheData = fieldValidatorCacheData,
        _field = field,
        _engine = engine,
        _hasGuardValidator = hasGuardValidator;

  /// Checks if the field validators are valid for the given [value].
  bool isValid(dynamic value) {
    for (var i = 0; i < _fieldValidators.length; i++) {
      final validator = _fieldValidators[i];
      final cacheData = _fieldValidatorCacheData[i];
      if (!validator.validate(cacheData, value, _engine)) {
        return false;
      }
    }
    return true;
  }

  /// Returns the [AnnotationResult] for the validation of [value].
  /// Messages are already translated using the initially provided [DogEngine].
  AnnotationResult annotate(dynamic value) {
    final results = <AnnotationResult>[];
    for (var i = 0; i < _fieldValidators.length; i++) {
      final validator = _fieldValidators[i];
      final cacheData = _fieldValidatorCacheData[i];
      final result = validator.annotate(cacheData, value, _engine);
      if (result.messages.isNotEmpty && i == 0 && _hasGuardValidator) {
        return result.withTarget(_field.name).translate(_engine);
      }
      results.add(result);
    }
    return AnnotationResult.combine(results)
        .withTarget(_field.name)
        .translate(_engine);
  }

  /// Returns the [AnnotationResult] for each individual validator of the field.
  /// The position of the result corresponds to the position of the validator and
  /// will remain consistent between calls.
  ///
  /// Null values indicate that the validator hasn't been evaluated in this call,
  /// this occurs if the guard validator fails.
  (List<AnnotationResult?> results, bool isGuard) annotateExtended(
      dynamic value) {
    final results =
        List<AnnotationResult?>.filled(_fieldValidators.length, null);
    for (var i = 0; i < _fieldValidators.length; i++) {
      final validator = _fieldValidators[i];
      final cacheData = _fieldValidatorCacheData[i];
      final result = validator
          .annotate(cacheData, value, _engine)
          .withTarget(_field.name)
          .translate(_engine);
      results[i] = result;
      if (result.hasErrors && i == 0 && _hasGuardValidator) {
        return (results, true);
      }
    }
    return (results, false);
  }
}

/// Validates whole structure instances.
class IsolatedClassValidator {
  final DogEngine _engine;
  final DogStructure _structure;
  final List<dynamic> _classValidatorCacheData;
  final List<ClassValidator> _classValidators;
  final List<ContextFieldValidator> _contextValidators;
  final List<dynamic> _contextValidatorCacheData;

  final List<IsolatedFieldValidator> _fieldValidators;
  final List<dynamic Function(dynamic)> _fieldAccessors;

  /// The number of top-level validators in this instance.
  late final int toplevelValidatorCount =
      _classValidators.length + _contextValidators.length;

  /// The number of field-level validators in this instance.
  late final int fieldValidatorCount =
      _fieldValidators.map((e) => e.validatorCount).sum;

  /// The number of validators in this instance.
  late final int validatorCount = toplevelValidatorCount + fieldValidatorCount;

  /// Maps field names to their index in [_fieldValidators] and the offset
  final Map<String, (int index, int offset)> fieldIndices = {};

  @internal
  // ignore: public_member_api_docs
  IsolatedClassValidator({
    required DogEngine engine,
    required DogStructure<dynamic> structure,
    required List<dynamic> classValidatorCacheData,
    required List<ClassValidator> classValidators,
    required List<ContextFieldValidator> contextValidators,
    required List<dynamic> contextValidatorCacheData,
    required List<IsolatedFieldValidator> fieldValidators,
    required List<dynamic Function(dynamic)> fieldAccessors,
  })  : _classValidators = classValidators,
        _classValidatorCacheData = classValidatorCacheData,
        _contextValidators = contextValidators,
        _contextValidatorCacheData = contextValidatorCacheData,
        _fieldValidators = fieldValidators,
        _fieldAccessors = fieldAccessors,
        _structure = structure,
        _engine = engine {
    var offset = 0;
    for (var i = 0; i < _structure.fields.length; i++) {
      fieldIndices[_structure.fields[i].name] = (i, offset);
      offset += _fieldValidators[i].validatorCount;
    }
  }

  /// Checks if the class validators are valid for the given [value].
  bool isValid(dynamic value) {
    for (var i = 0; i < _fieldValidators.length; i++) {
      final fieldValue = _fieldAccessors[i](value);
      if (!_fieldValidators[i].isValid(fieldValue)) {
        return false;
      }
    }
    for (var i = 0; i < _classValidators.length; i++) {
      final validator = _classValidators[i];
      final cacheData = _classValidatorCacheData[i];
      if (!validator.validate(cacheData, value, _engine)) {
        return false;
      }
    }
    for (var i = 0; i < _contextValidators.length; i++) {
      final validator = _contextValidators[i];
      final cacheData = _contextValidatorCacheData[i];
      if (!validator.validate(cacheData, value, _engine)) {
        return false;
      }
    }
    return true;
  }

  /// Returns the [AnnotationResult] for the validation of [value].
  /// Messages are already translated using the initially provided [DogEngine].
  AnnotationResult annotate(dynamic value) {
    final results = <AnnotationResult>[];
    for (var i = 0; i < _fieldValidators.length; i++) {
      final fieldValue = _fieldAccessors[i](value);
      results.add(_fieldValidators[i].annotate(fieldValue));
    }
    for (var i = 0; i < _classValidators.length; i++) {
      final validator = _classValidators[i];
      final cacheData = _classValidatorCacheData[i];
      results.add(
          validator.annotate(cacheData, value, _engine).translate(_engine));
    }
    for (var i = 0; i < _contextValidators.length; i++) {
      final validator = _contextValidators[i];
      final cacheData = _contextValidatorCacheData[i];
      results.add(
          validator.annotate(cacheData, value, _engine).translate(_engine));
    }
    // Do not translate here since the field validators already are translated
    return AnnotationResult.combine(results);
  }

  /// Returns the [AnnotationResult] for each individual validator of this class.
  /// The position of the result corresponds to the position of the validator and
  /// will remain consistent between calls.
  List<AnnotationResult?> annotateExtended(dynamic value) {
    final results = List<AnnotationResult?>.filled(fieldValidatorCount, null,
        growable: true);
    for (var i = 0; i < _classValidators.length; i++) {
      final validator = _classValidators[i];
      final cacheData = _classValidatorCacheData[i];
      results.add(
          validator.annotate(cacheData, value, _engine).translate(_engine));
    }
    for (var i = 0; i < _contextValidators.length; i++) {
      final validator = _contextValidators[i];
      final cacheData = _contextValidatorCacheData[i];
      results.add(
          validator.annotate(cacheData, value, _engine).translate(_engine));
    }
    return results;
  }

  /// Runs [annotateExtended] only for the field with the given [fieldName]
  /// without any [ClassValidator] or [ContextFieldValidator] validation.
  ///
  /// The resulting list's format is consistent with the one returned by
  /// [annotateExtended].
  (List<AnnotationResult?>, bool isGuard) annotateFieldExtended(
      String fieldName, dynamic fieldValue) {
    final (fieldIndex, fieldOffset) = fieldIndices[fieldName]!;
    final buffer = List<AnnotationResult?>.filled(validatorCount, null);
    final (annotationResults, isGuard) =
        _fieldValidators[fieldIndex].annotateExtended(fieldValue);
    for (var i = 0; i < annotationResults.length; i++) {
      buffer[fieldOffset + i] = annotationResults[i];
    }
    return (buffer, isGuard);
  }
}
