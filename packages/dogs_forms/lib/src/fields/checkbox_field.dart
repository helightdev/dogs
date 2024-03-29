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
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// A [AutoFormFieldFactory] that creates [FormBuilderCheckbox]s.
class CheckboxFormFieldFactory extends AutoFormFieldFactory {
  /// A [AutoFormFieldFactory] that creates [FormBuilderCheckbox]s.
  const CheckboxFormFieldFactory();

  @override
  Widget build(BuildContext context, DogsFormField field) {
    field.expectType(bool);
    field.expectNonIterable();
    return FormBuilderCheckbox(
      name: field.delegate.name,
      decoration:
          field.buildBorderDecoration(context, DecorationPreference.borderless),
      autovalidateMode: field.autovalidateMode,
      validator: $validator(field, context),
      title: Text(field.title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: field.subtitle == null ? null : Text(field.subtitle!),
    );
  }

  @override
  dynamic decode(dynamic value) => switch(value) {
    null => false,
    _ => value
  };
}
