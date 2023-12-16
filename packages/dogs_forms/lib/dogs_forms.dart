library dogs_forms;

import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_core/dogs_validation.dart';
import 'package:flutter/material.dart';

export 'src/decorator.dart';
export 'src/factories.dart';
export 'src/field.dart';
export 'src/form.dart';
export 'src/initializer.dart';
export 'src/selection.dart';
export 'src/translator.dart';

export 'package:canister/canister.dart';

String capitalizeString(String s) {
  return s[0].toUpperCase() + s.substring(1);
}

const InputDecoration borderlessInput = InputDecoration(
  border: InputBorder.none,
  enabledBorder: InputBorder.none,
  errorBorder: InputBorder.none,
  disabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
);

const InputDecoration outlineInput = InputDecoration(
  border: OutlineInputBorder(),
);

extension DogFieldExt on DogStructureField {

  double getInclusiveMin() {
    var value = -double.maxFinite;
    var minimum = annotationsOf<Minimum>().firstOrNull;
    if (minimum != null) {
      value = minimum.min!.toDouble();
      if (minimum.minExclusive == true) {
        value += 0.0000000000000001;
      }
    }
    var range = annotationsOf<Range>().firstOrNull;
    if (range != null) {
      value = range.min!.toDouble();
      if (range.minExclusive == true) {
        value += 0.0000000000000001;
      }
    }
    return value;
  }

  int getInclusiveMinInt() {
    var value = (-double.maxFinite).toInt();
    var minimum = annotationsOf<Minimum>().firstOrNull;
    if (minimum != null) {
      value = minimum.min!.toInt();
      if (minimum.minExclusive == true) {
        value += 1;
      }
    }
    var range = annotationsOf<Range>().firstOrNull;
    if (range != null) {
      value = range.min!.toInt();
      if (range.minExclusive == true) {
        value += 1;
      }
    }
    return value.toInt();
  }

  double getMaxInclusive() {
    var value = double.maxFinite;
    var maximum = annotationsOf<Maximum>().firstOrNull;
    if (maximum != null) {
      value = maximum.max!.toDouble();
      if (maximum.maxExclusive == true) {
        value -= 0.0000000000000001;
      }
    }
    var range = annotationsOf<Range>().firstOrNull;
    if (range != null) {
      value = range.max!.toDouble();
      if (range.maxExclusive == true) {
        value -= 0.0000000000000001;
      }
    }
    return value;
  }

  int getMaxInclusiveInt() {
    var value = double.maxFinite.toInt();
    var maximum = annotationsOf<Maximum>().firstOrNull;
    if (maximum != null) {
      value = maximum.max!.toInt();
      if (maximum.maxExclusive == true) {
        value -= 1;
      }
    }
    var range = annotationsOf<Range>().firstOrNull;
    if (range != null) {
      value = range.max!.toInt();
      if (range.maxExclusive == true) {
        value -= 1;
      }
    }
    return value;
  }

}