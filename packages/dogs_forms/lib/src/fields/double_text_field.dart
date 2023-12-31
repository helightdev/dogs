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
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

/// A [AutoFormFieldFactory] that creates [FormBuilderTextField]s for [double]s.
class DoubleTextFieldFormFieldFactory extends AutoFormFieldFactory {
  const DoubleTextFieldFormFieldFactory();

  @override
  Widget build(BuildContext context, DogsFormField field) {
    field.expectType(double);
    if (field.delegate.iterableKind != IterableKind.none) {
      return DogsFormList.field(
        field,
        elementFactory: (context, name, callback) => FormBuilderTextField(
          name: name,
          onChanged: callback,
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.numeric(),
            FormBuilderValidators.required()
          ]),
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      );
    }

    return FormBuilderTextField(
      name: field.delegate.name,
      decoration:
          field.buildInputDecoration(context, DecorationPreference.normal),
      autofillHints: field.formAnnotation?.autofillHints,
      autovalidateMode: field.autovalidateMode,
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.numeric(),
        $validator(field, context),
      ]),
    );
  }

  @override
  dynamic encode(dynamic value) => switch(value) {
    null => null,
    List() => value.map((e) => e.toString()).toList(),
    _ => value?.toString()
  };

  @override
  dynamic decode(dynamic value) => switch(value) {
    null => null,
    List() => value.map((e) => double.tryParse(e ?? "0.0")).toList(),
    _ => double.tryParse(value)
  };
}
