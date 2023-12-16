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
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:uuid/uuid.dart';

/// Utility [AutoFormFieldFactory] that creates a [List] of [ITEM_TYPE]s.
class ListFieldFactory<ITEM_TYPE> extends AutoFormFieldFactory {
  /// The [TypeCapture] of the [ITEM_TYPE].
  final TypeCapture itemType;

  /// The default [Initializer] for the [ITEM_TYPE].
  final Initializer itemInitializer;

  /// The [Function] that creates the widgets for list elements.
  final Widget Function(
          BuildContext context, String name, Function(dynamic) callback)
      elementFactory;

  /// Utility [AutoFormFieldFactory] that creates a [List] of [ITEM_TYPE]s.
  const ListFieldFactory(this.itemType, this.elementFactory, [this.itemInitializer = defaultInitializer]);

  @override
  Widget build(BuildContext context, DogsFormField field) {
    final GlobalKey<FormBuilderState> formKey = GlobalKey();
    var rootFormKey = DogsFormProvider.keyOf(context)!;
    return InputDecorator(
      decoration: field.buildInputDecoration(context, DecorationPreference.container),
      child: FormBuilderField(
        name: field.delegate.name,
        builder: (formField) => ListFieldWidget(
          fieldState: formField,
          parent: this,
          formKey: formKey,
          rootFormKey: rootFormKey,
          dogField: field,
        ),
        validator: FormBuilderValidators.compose([
          $validator(field, context),
          (v) => formKey.currentState!.isValid
              ? null
              : "Individual fields are invalid."
        ]),
      ),
    );
  }

  @override
  dynamic decode(dynamic value) =>
      value == null ? null : (value as Iterable).toList();

  @override
  dynamic encode(dynamic value) =>
      value == null ? null : (value as List).toList();
}

class ListFieldWidget extends StatefulWidget {
  final FormFieldState fieldState;
  final ListFieldFactory parent;
  final GlobalKey<FormBuilderState> formKey;
  final GlobalKey<FormBuilderState> rootFormKey;
  final DogsFormField dogField;

  const ListFieldWidget(
      {super.key,
      required this.fieldState,
      required this.parent,
      required this.formKey,
      required this.rootFormKey,
      required this.dogField});

  @override
  State<ListFieldWidget> createState() => _ListFieldWidgetState();
}

class _ListFieldWidgetState extends State<ListFieldWidget> {
  List<String> children = [];
  Map<String, dynamic> initialData = {};

  @override
  void initState() {
    var initialData = widget.rootFormKey.currentState!.fields[widget.dogField.delegate.name]?.initialValue as List?;
    if (initialData != null) {
      children = initialData.map((e) => const Uuid().v4()).toList();
      for (var i = 0; i < children.length; i++) {
        this.initialData["item-${children[i]}"] = initialData[i];
      }
    }
    
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return FormBuilder(
        key: widget.formKey,
        initialValue: initialData,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++)
              Row(
                key: ValueKey(children[i]),
                children: [
                  Expanded(
                      child: widget.parent.elementFactory(
                          context, "item-${children[i]}", (newValue) {
                    widget.fieldState.didChange(buildList());
                  })),
                  IconButton(
                      onPressed: () => setState(() {
                            var id = children[i];
                            children.removeAt(i);
                            widget.formKey.currentState!.fields["item-$id"]!
                                .setValue(null);
                            WidgetsBinding.instance
                                .addPostFrameCallback((timeStamp) {
                              widget.fieldState.didChange(buildList());
                            });
                          }),
                      icon: const Icon(Icons.delete)),
                ],
              ),
            IconButton(
                onPressed: () {
                  var id = const Uuid().v4();
                  children.add(id);
                  setState(() {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      var initializer = widget.dogField.itemInitializer;
                      if (initializer is DefaultInitializer) {
                        initializer = widget.parent.itemInitializer;
                      }
                      widget.formKey.currentState!.fields["item-$id"]!.didChange(
                          widget.dogField.factory.encode(initializer())
                      );
                      widget.fieldState.didChange(buildList());
                    });
                  });
                },
                icon: const Icon(Icons.add)),
          ],
        ));
  }

  List buildList() => widget.parent.itemType.castList(children
      .map((e) => widget.formKey.currentState!.instantValue["item-$e"])
      .toList());
}
