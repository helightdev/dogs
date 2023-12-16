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

import 'dart:collection';

import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_forms/dogs_forms.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

typedef PreferenceDecorationMutator = InputDecoration? Function(
    InputDecoration decoration, DecorationPreference)?;

/// Marks a dog structure as a form.
/// Additionally allows to specify form specific attributes.
class AutoForm implements StructureMetadata {
  /// The [FormDecorator] to use layout and decorate the form.
  final FormDecorator decorator;

  /// The [CrossAxisAlignment] to used by some [FormDecorators].
  final CrossAxisAlignment crossAxisAlignment;

  /// The [MainAxisAlignment] to used by some [FormDecorators].
  final MainAxisAlignment mainAxisAlignment;

  const AutoForm({
    this.decorator = const DefaultFormDecorator(),
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });
}

/// Decorator for a [GlobalKey<FormBuilderState>] that also tracks the [DogsForm]
/// instance that is associated with the key, to allow for easy access to the
/// form data.
class DogsFormRef<T> {
  late GlobalKey<FormBuilderState> formKey;
  late DogsForm form;

  DogsFormRef([GlobalKey<FormBuilderState>? formKey]) {
    this.formKey = formKey ?? GlobalKey<FormBuilderState>();
  }

  T? read([bool saveAndValidate = true]) => form.readValue(saveAndValidate);
}

/// Auto-generated form for a dog managed data structure,
/// identified by its type [T].
class DogsForm<T> extends StatelessWidget {
  /// The structure of the data type [T].
  final DogStructure<T> structure;
  /// The fields of the form.
  final List<DogsFormField> fields;
  /// The initial value of the form. If not specified, the form will be
  /// initialized with [createInitialValue] using the [Initializer]s of the
  /// fields.
  final T? initialValue;
  /// The key of the form. If not specified, a new [GlobalKey<FormBuilderState>]
  /// will be created.
  late final GlobalKey<FormBuilderState> formKey;
  /// Additional attributes for the form.
  /// May be used to provide additional non constant context dependent data
  /// to [AutoFormFieldFactory]s.
  late final Map<Symbol, dynamic> attributes;
  /// Callback that is called when the form data changes.
  late final Function()? onChanged;
  /// The [TranslationResolver] to use for the form.

  final TranslationResolver translationResolver;
  /// The [PreferenceDecorationMutator] to use for the form.
  final PreferenceDecorationMutator? preferenceDecorationMutator;
  /// Override for the [FormDecorator] specified by [AutoForm].
  final FormDecorator<T>? decorator;

  DogsForm._(
      {super.key,
      GlobalKey<FormBuilderState>? formKey,
      Map<Symbol, dynamic>? attributes,
      required this.structure,
      required this.fields,
      required this.translationResolver,
      this.initialValue,
      this.preferenceDecorationMutator,
      this.onChanged,
      this.decorator}) {
    this.formKey = formKey ?? GlobalKey<FormBuilderState>();
    this.attributes = attributes ?? {};
  }

  late final AutoForm formAnnotation =
      structure.annotationsOf<AutoForm>().firstOrNull ?? const AutoForm();

  /// Auto-generated form for a dog managed data structure,
  /// identified by its type [T].
  factory DogsForm({
    T? initialValue,
    Map<Symbol, dynamic>? attributes,
    TranslationResolver translationResolver =
        const DefaultTranslationResolver(),
    PreferenceDecorationMutator? preferenceResolver,
    FormDecorator<T>? decorator,
    Function()? onChanged,
    required DogsFormRef reference,
  }) {
    var structure = dogs.findStructureByType(T)!;
    var fields2 = structure.fields
        .map((e) => DogsFormField(structure, e))
        .toList();
    var form = DogsForm<T>._(
      structure: structure as DogStructure<T>,
      fields: fields2,
      initialValue: initialValue,
      formKey: reference.formKey,
      attributes: attributes ?? {},
      translationResolver: translationResolver,
      preferenceDecorationMutator: preferenceResolver,
      onChanged: onChanged,
      decorator: decorator,
    );
    reference.form = form;
    return form;
  }

  DogsFormField findField(String name) => fields
      .firstWhere((element) => element.delegate.name == name);

  T? readValue([bool saveAndValidate = true]) {
    var isValid = saveAndValidate
        ? formKey.currentState!.saveAndValidate()
        : formKey.currentState!.validate(
            focusOnInvalid: false, autoScrollWhenFocusOnInvalid: false);
    if (!isValid) return null;
    try {
      var map = formKey.currentState!.instantValue;
      var fieldMap = {
        for (var e in fields)
          e.delegate.name: e.factory.decode(map[e.delegate.name])
      };
      var instantiated = structure.instantiateFromFieldMap(fieldMap);
      if (!dogs.validateObject(instantiated, T)) return null;
      return instantiated;
    } on Exception catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error trying to parse form field: $e\n$stackTrace");
      }
      return null;
    }
  }

  Map<String, dynamic> createInitialValue(T? obj) {
    if (obj != null) {
      var fieldValues = structure.getFieldMap(obj);
      return {
        for (var e in fields)
          e.delegate.name: e.factory.encode(fieldValues[e.delegate.name])
      };
    } else {
      return {
        for (var e in fields) e.delegate.name: e.factory.encode(e.initializer())
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    var decorator = this.decorator ?? formAnnotation.decorator;
    return FormBuilder(
        key: formKey,
        initialValue: createInitialValue(initialValue),
        onChanged: () => onChanged?.call(),
        child: DogsFormProvider(
          formKey: formKey,
          form: this,
          child: Builder(builder: (context) {
            return decorator.run(context, this);
          }),
        ));
  }
}

class DogsFormProvider extends InheritedWidget {
  final GlobalKey<FormBuilderState> formKey;
  final DogsForm form;

  const DogsFormProvider(
      {super.key,
      required this.formKey,
      required this.form,
      required Widget child})
      : super(child: child);

  static DogsForm? formOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DogsFormProvider>()?.form;
  }

  static GlobalKey<FormBuilderState>? keyOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DogsFormProvider>()
        ?.formKey;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}
