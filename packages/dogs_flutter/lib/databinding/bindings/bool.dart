/*
 *    Copyright 2022, the DOGs authors
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License
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
import 'package:dogs_flutter/databinding/controller.dart';
import 'package:dogs_flutter/databinding/material/style.dart';
import 'package:dogs_flutter/databinding/opmode.dart';
import 'package:dogs_flutter/databinding/validation.dart';
import 'package:flutter/material.dart';

import '../widgets/field_widget.dart';

class BoolFlutterBinder extends FlutterWidgetBinder<bool>
    with TypeCaptureMixin<bool> implements StructureMetadata {

  const BoolFlutterBinder();

  @override
  Widget buildBindingField(
    BuildContext context,
    FieldBindingController<bool> controller,
  ) {
    return BoolBindingFieldWidget(
      key: Key(controller.fieldName),
      controller: controller as BoolBindingFieldController,
    );
  }

  @override
  FieldBindingController<bool> createBindingController(
    StructureBindingController parent,
    FieldBindingContext<bool> context,
  ) {
    return BoolBindingFieldController(parent, this, context);
  }

  @override
  void initialise(DogEngine engine) {}
}

class BoolBindingFieldController extends FieldBindingController<bool> {
  ValueNotifier<bool> valueListenable = ValueNotifier(false);

  BoolBindingFieldController(super.parent, super.binder, super.bindingContext) {
    valueListenable.addListener(_onChanged);
  }

  @override
  void dispose() {
    super.dispose();
    valueListenable.removeListener(_onChanged);
  }

  void _onChanged() {
    performValidation(ValidationTrigger.onInteraction);
  }

  @override
  bool? getValue() {
    return valueListenable.value;
  }

  @override
  void setValue(bool? value) {
    valueListenable.value = value ?? false;
  }
}

class BoolBindingFieldWidget extends StatelessWidget {
  final BoolBindingFieldController controller;

  const BoolBindingFieldWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = BindingTheme.of(context);
    final actualInputDecoration = theme.style.buildMaterialDecoration(
      context,
      includeLabel: true,
    );

    return ValueListenableBuilder(
      valueListenable: controller.errorListenable,
      builder: (context, error, _) {
        final outerDecoration = theme.style
            .buildMaterialDecoration(context, includeLabel: false, includeHint: false, includeHelper: false)
            .copyWith(
              errorText: theme.toErrorText(error),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            );
        return InputDecorator(
          decoration: outerDecoration,
          child: ValueListenableBuilder(
            valueListenable: controller.valueListenable,
            builder: (context, value, _) {
              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: value,
                title: theme.style.buildMaterialLabelText(context),
                subtitle: theme.style.buildMaterialHelperText(context),
                onChanged: (newValue) {
                  controller.valueListenable.value = newValue ?? false;
                },
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
          ),
        );
      },
    );
  }
}
