import 'package:dogs_core/dogs_core.dart';
import 'package:flutter/foundation.dart';

class BindingsErrorBuffer {
  final DogStructure _structure;
  final IsolatedClassValidator _classValidator;
  final List<AnnotationResult> _customErrors = [];
  late final List<AnnotationResult> _results;
  late final Map<String, AnnotationResult> fieldErrors;
  final VoidCallback onChanged;

  AnnotationResult classErrors = AnnotationResult.empty();
  bool hasErrors = false;

  BindingsErrorBuffer(
    DogStructure structure,
    IsolatedClassValidator classValidator,
    this.onChanged,
  ) : _structure = structure,
      _classValidator = classValidator {
    _results = List.filled(
      _classValidator.validatorCount,
      AnnotationResult.empty(),
    );
    fieldErrors = Map.fromEntries(
      _structure.fields.map((e) => MapEntry(e.name, AnnotationResult.empty())),
    );
  }

  void put(int index, AnnotationResult result) {
    _results[index] = result;
  }

  void putAll(List<AnnotationResult?> results) {
    for (var i = 0; i < results.length; i++) {
      final result = results[i];
      if (result == null) continue;
      _results[i] = result;
    }
  }

  void putCustom(AnnotationResult result) {
    _customErrors.add(result);
  }

  void clearCustom() {
    _customErrors.clear();
  }

  void recalculateFieldErrors() {
    final fieldErrorAcc = <String, List<AnnotationMessage>>{};
    for (var field in _structure.fields) {
      fieldErrorAcc[field.name] = [];
    }
    final classErrorAcc = <AnnotationMessage>[];
    hasErrors = false;
    for (var i = 0; i < _results.length; i++) {
      final result = _results[i];
      for (var message in result.messages) {
        hasErrors = true;
        if (message.target == null) {
          classErrorAcc.add(message);
        } else {
          fieldErrorAcc[message.target!]!.add(message);
        }
      }
    }
    for (var error in _customErrors) {
      for (var message in error.messages) {
        hasErrors = true;
        if (message.target == null) {
          classErrorAcc.add(message);
        } else {
          fieldErrorAcc[message.target!]!.add(message);
        }
      }
    }

    classErrors = AnnotationResult(messages: classErrorAcc);
    fieldErrorAcc.forEach((key, value) {
      fieldErrors[key] = AnnotationResult(messages: value);
    });
    onChanged();
  }
}

extension type ValidationTrigger(int value) {
  static final never = ValidationTrigger(0);
  static final onInteraction = ValidationTrigger(1);
  static final onUnfocus = ValidationTrigger(2);
  static final onSubmit = ValidationTrigger(4);
  static final onSubmitGuard = ValidationTrigger(8);

  static final ValidationTrigger always = onInteraction | onUnfocus | onSubmit;

  operator |(ValidationTrigger other) {
    return ValidationTrigger(value | other.value);
  }

  bool has(ValidationTrigger other) {
    return (value & other.value) == other.value;
  }
}
