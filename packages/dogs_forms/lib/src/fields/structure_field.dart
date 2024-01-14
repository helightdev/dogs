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
class StructureFormFieldFactory extends AutoFormFieldFactory
    with CachedFactoryData<DogsFormRef> {
  /// The [DogStructure] to embed.
  final DogStructure structure;

  /// A [AutoFormFieldFactory] that embeds another [DogsForm] into the form.
  const StructureFormFieldFactory(this.structure);

  @override
  void prepareFormField(BuildContext context, DogsFormField field, bool firstPass) {
    if (!firstPass) return;
    var formKey = GlobalKey<FormBuilderState>();
    var ref = structure.consumeTypeArg(createRef, formKey);
    setCachedValue(field, ref);
  }

  @override
  Widget build(BuildContext context, DogsFormField field) =>
      structure.consumeTypeArg(createForm, (
        field: field,
        context: context,
      ));

  DogsFormRef createRef<T>(GlobalKey<FormBuilderState> formKey) {
    return DogsFormRef<T>(formKey);
  }

  Widget createForm<T>(({DogsFormField field, BuildContext context}) arg) {
    var reference = getCachedValue(arg.field) as DogsFormRef<T>;
    if (arg.field.delegate.optional) {
      return _buildOptional<T>(arg, reference);
    }

    bool isSelfUpdate = false;
    return InputDecorator(
      decoration: arg.field
          .buildInputDecoration(arg.context, DecorationPreference.container),
      child: FormBuilderField<T>(
        onChanged: (value) {
          if (isSelfUpdate) {
            isSelfUpdate = false;
          } else {
            reference.set(value);
          }
        },
        builder: (FormFieldState<T> formField) {
          var reference = getCachedValue(arg.field) as DogsFormRef<T>;
          return DogsForm<T>(
            reference: reference,
            initialValue: formField.value,
            onChanged: () {
              isSelfUpdate = true;
              formField.didChange(reference.read(false));
            },
          );
        },
        validator: $validator(arg.field, arg.context),
        name: arg.field.delegate.name,
      ),
    );
  }

  FormBuilderField<dynamic> _buildOptional<T>(({BuildContext context, DogsFormField field}) arg, DogsFormRef<dynamic> reference) {
    return FormBuilderField<T>(
      builder: (FormFieldState<T> formField) {
        return DogsFormOptional<T>(
          initialValue: formField.value,
          elementFactory: (context, name, callback) {
            return InputDecorator(
              decoration: arg.field.buildInputDecoration(
                  arg.context, DecorationPreference.container),
              child: FormBuilderField<T>(
                  name: name,
                  onChanged: callback,
                  validator: $validator(arg.field, context),
                  onReset: () {
                    context
                        .findAncestorStateOfType<DogsFormOptionalState>()!
                        .applyManually(formField.value);
                    reference.set(formField.value);
                    // This still doesn't work right, but most of the times:
                    // Load Value > Modify until Invalid > Disable > Load Value > !!!
                    // But since this is out of scope for the current project, I'll leave it as is.
                    // dogs_forms is not meant to actively reload values after the user modified them.
                    // TODO: Anyways, if someone wants to fix this, feel free to do so.
                  },
                  builder: (FormFieldState<T> innerField) {
                    var isEnabled = FormBuilder.of(context)!.enabled;
                    return ExcludeFocus(
                      excluding: !isEnabled,
                      child: Opacity(
                        opacity: isEnabled ? 1 : 0.5,
                        child: DogsForm<T>(
                          reference: reference,
                          initialValue: innerField.value,
                          onChanged: () {
                            innerField.didChange(reference.read(false));
                          },
                        ),
                      ),
                    );
                  }),
            );
          },
          onChanged: (value) {
            formField.didChange(value);
          },
        );
      },
      name: arg.field.delegate.name,
    );
  }
}
