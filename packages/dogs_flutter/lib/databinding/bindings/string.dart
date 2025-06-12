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
import 'package:dogs_flutter/databinding/field_controller.dart';
import 'package:dogs_flutter/databinding/material/style.dart';
import 'package:dogs_flutter/databinding/opmode.dart';
import 'package:dogs_flutter/databinding/text_field_style.dart';
import 'package:dogs_flutter/databinding/validation.dart';
import 'package:dogs_flutter/databinding/widgets/field_widget.dart';
import 'package:flutter/material.dart';

class StringFlutterBinder extends FlutterWidgetBinder<String>
    with TypeCaptureMixin<String>
    implements StructureMetadata {
  const StringFlutterBinder();

  @override
  Widget buildBindingField(
    BuildContext context,
    FieldBindingController<String> controller,
  ) {
    return StringBindingFieldWidget(
      key: Key(controller.fieldName),
      controller: controller as StringBindingFieldController,
    );
  }

  @override
  FieldBindingController<String> createBindingController(
    FieldBindingParent parent,
    FieldBindingContext<String> context,
  ) {
    return StringBindingFieldController(parent, this, context);
  }

  @override
  void initialise(DogEngine engine) {}

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StringFlutterBinder && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class StringBindingFieldController extends FieldBindingController<String> {
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  String _lastText = "";

  StringBindingFieldController(
    super.parent,
    super.binder,
    super.bindingContext,
  ) {
    textController.addListener(_onTextChanged);
    focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
    focusNode.dispose();
  }

  void _onTextChanged() {
    if (textController.text == _lastText) return;
    _lastText = textController.text;
    notifyListeners();
    performValidation(ValidationTrigger.onInteraction);
  }

  void _onFocusChanged() {
    if (!focusNode.hasFocus) {
      performValidation(ValidationTrigger.onUnfocus);
    }
  }

  @override
  String? getValue() {
    if (textController.text.isEmpty) return null;
    return textController.text;
  }

  @override
  void setValue(String? value) {
    if (value == null) {
      textController.clear();
    } else {
      textController.text = value;
    }
  }
}

class StringBindingFieldWidget extends StatelessWidget {
  final StringBindingFieldController controller;

  const StringBindingFieldWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = BindingTheme.of(context);
    final inputDecoration = theme.style.buildMaterialDecoration(context, controller);
    final textFieldStyle = theme.style.getTextFieldStyle();

    return ValueListenableBuilder(
      valueListenable: controller.errorListenable,
      builder: (context, error, _) {
        return TextField(
          controller: controller.textController,
          focusNode: controller.focusNode,
          decoration: inputDecoration.copyWith(
            errorText: theme.toErrorText(error),
          ),

          // Apply all the text field properties directly from the TextFieldStyle
          obscureText: textFieldStyle.obscureText ?? false,
          keyboardType: textFieldStyle.keyboardType,
          maxLines: textFieldStyle.maxLines ?? 1,
          minLines: textFieldStyle.minLines,
          maxLength: textFieldStyle.maxLength,
          textAlign: textFieldStyle.textAlign ?? TextAlign.start,
          style: textFieldStyle.textStyle,
          textCapitalization:
              textFieldStyle.textCapitalization ?? TextCapitalization.none,
          enabled: textFieldStyle.enabled,
          readOnly: textFieldStyle.readOnly ?? false,
          autofocus: textFieldStyle.autofocus ?? false,
          inputFormatters: textFieldStyle.inputFormatters,
        );
      },
    );
  }
}
