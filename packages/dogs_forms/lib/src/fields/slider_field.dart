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

import 'package:dogs_forms/dogs_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

/// A [AutoFormFieldFactory] that creates [FormBuilderSlider]s.
class DoubleSliderFormFieldFactory extends AutoFormFieldFactory {
  /// A [AutoFormFieldFactory] that creates [FormBuilderSlider]s.
  const DoubleSliderFormFieldFactory();

  @override
  Widget build(BuildContext context, DogsFormField field) {
    field.expectType(double);
    field.expectNonIterable();
    var min = field.delegate.getInclusiveMin();
    var max = field.delegate.getMaxInclusive();
    return Builder(builder: (context) {
      var form = FormBuilder.of(context)!;
      return FormBuilderSlider(
        name: field.delegate.name,
        decoration: field.buildInputDecoration(
            context, DecorationPreference.borderless),
        autovalidateMode: field.autovalidateMode,
        validator: $validator(field, context),
        min: min,
        max: max,
        initialValue: form.initialValue[field.delegate.name] ?? min,
      );
    });
  }
}

/// A [AutoFormFieldFactory] that creates [FormBuilderSlider]s.
class IntSliderFormFieldFactory extends AutoFormFieldFactory {
  /// A [AutoFormFieldFactory] that creates [FormBuilderSlider]s.
  const IntSliderFormFieldFactory();

  @override
  Widget build(BuildContext context, DogsFormField field) {
    field.expectType(int);
    field.expectNonIterable();
    var min = field.delegate.getInclusiveMinInt();
    var max = field.delegate.getMaxInclusiveInt();
    return Builder(builder: (context) {
      var form = FormBuilder.of(context)!;
      return FormBuilderSlider(
        name: field.delegate.name,
        decoration: field.buildInputDecoration(
            context, DecorationPreference.borderless),
        autovalidateMode: field.autovalidateMode,
        validator: $validator(field, context),
        numberFormat: NumberFormat("###"),
        min: min.toDouble(),
        max: max.toDouble(),
        initialValue: form.initialValue[field.delegate.name] ?? min.toDouble(),
      );
    });
  }

  @override
  dynamic decode(dynamic value) => (value as double).round();

  @override
  dynamic encode(dynamic value) => (value as int?)?.toDouble();
}
