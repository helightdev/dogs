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
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// A [AutoFormFieldFactory] that embeds another [DogsForm] into the form.
class StructureFormFieldFactory extends AutoFormFieldFactory {

  /// The [DogStructure] to embed.
  final DogStructure structure;

  /// A [AutoFormFieldFactory] that embeds another [DogsForm] into the form.
  const StructureFormFieldFactory(this.structure);

  @override
  Widget build(BuildContext context, DogsFormField field) {
    var formKey = GlobalKey<FormBuilderState>();
    var form = structure.consumeTypeArg(createForm, (
      formKey: formKey,
      field: field,
      context: context,
    ));
    return form;
  }

  Widget createForm<T>(
      ({
        GlobalKey<FormBuilderState> formKey,
        DogsFormField field,
        BuildContext context
      }) arg) {
    return InputDecorator(
      decoration: arg.field.buildInputDecoration(arg.context, DecorationPreference.container),
      child: FormBuilderField<T>(
        builder: (FormFieldState<T> field) {
          var reference = DogsFormRef<T>(arg.formKey);
          return DogsForm<T>(
            reference: reference,
            initialValue: field.value,
            onChanged: () {
              field.didChange(reference.read(false));
            },
          );
        },
        validator: $validator(arg.field, arg.context),
        name: arg.field.delegate.name,
      ),
    );
  }
}
