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

import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_forms/dogs_forms.dart';
import 'package:dogs_forms/src/fields/list_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// A [AutoFormFieldFactory] that creates [FormBuilderDateTimePicker]s.
class DateTimeFormFieldFactory extends AutoFormFieldFactory<DateTime> {

  const DateTimeFormFieldFactory();

  @override
  Widget build(BuildContext context, DogsFormField field) {
    field.expectType(DateTime);
    if (field.delegate.iterableKind != IterableKind.none) {
      return DogsFormList.field<DateTime>(
        field,
        elementFactory: (context, name, callback) =>
            FormBuilderDateTimePicker(
              name: name,
              onChanged: callback,
              validator: FormBuilderValidators.required(),
              autovalidateMode: AutovalidateMode.onUserInteraction,
            ),
      );
    }

    if (field.delegate.optional) {
      return FormBuilderField<DateTime>(builder: (fieldState) => DogsFormOptional<DateTime?>(
          initialValue: fieldState.value,
          elementFactory: (context, name, callback) => FormBuilderDateTimePicker(
            name: name,
            decoration: field.buildInputDecoration(context, DecorationPreference.normal).copyWith(
              errorText: fieldState.errorText,
            ),
            onChanged: callback,
          ), onChanged: (v) => fieldState.didChange(v)),
          name: field.delegate.name,
        validator: $validator(field, context),
      );
    }

    return FormBuilderDateTimePicker(
      name: field.delegate.name,
      decoration: field.buildInputDecoration(context, DecorationPreference.normal),
      validator: $validator(field, context),
      autovalidateMode: field.autovalidateMode,
    );
  }
}
