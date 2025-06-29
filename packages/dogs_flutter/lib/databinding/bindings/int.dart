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

import 'package:dogs_flutter/dogs_flutter.dart';
import 'package:flutter/material.dart';

class IntFlutterBinder extends FlutterWidgetBinder<int>
    with TypeCaptureMixin<int>
    implements StructureMetadata {
  const IntFlutterBinder();

  @override
  Widget buildBindingField(
    BuildContext context,
    FieldBindingController<int> controller,
  ) {
    return IntBindingFieldWidget(
      key: Key(controller.fieldName),
      controller: controller as IntBindingFieldController,
    );
  }

  @override
  FieldBindingController<int> createBindingController(
    FieldBindingParent parent,
    FieldBindingContext<int> context,
  ) {
    return IntBindingFieldController(parent, this, context);
  }

  @override
  void initialise(DogEngine engine) {}

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntFlutterBinder && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class IntBindingFieldController extends FieldBindingController<int> {
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  String _lastText = "";
  AnnotationResult? _formatError;

  IntBindingFieldController(super.parent, super.binder, super.bindingContext) {
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
    _validateFormat();
    notifyListeners();
    performValidation(ValidationTrigger.onInteraction);
  }

  void _validateFormat() {
    if (textController.text.isEmpty) {
      _formatError = null;
      return;
    }
    try {
      int.parse(textController.text);
      _formatError = null;
    } catch (e) {
      _formatError = AnnotationResult(
        messages: [FormatMessages.invalidNumberFormat.withTarget(fieldName)],
      );
    }
  }

  void _onFocusChanged() {
    if (!focusNode.hasFocus) {
      performValidation(ValidationTrigger.onUnfocus);
    }
  }

  @override
  int? getValue() {
    if (textController.text.isEmpty) return null;
    try {
      return int.parse(textController.text);
    } catch (e) {
      return null;
    }
  }

  @override
  void setValue(int? value) {
    if (value == null) {
      textController.clear();
    } else {
      textController.text = value.toString();
    }
  }

  @override
  void handleErrors(AnnotationResult result) {
    if (_formatError != null) {
      result = result.remove(DatabindRequiredGuard.messageId) + _formatError!;
    }
    super.handleErrors(result);
  }
}

class IntBindingFieldWidget extends StatelessWidget {
  final IntBindingFieldController controller;

  const IntBindingFieldWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = BindingTheme.of(context);
    final inputDecoration = theme.style.buildMaterialDecoration(
      context,
      controller,
    );
    final textFieldStyle = theme.style.getTextFieldStyle();

    // For int fields, we default to number keyboard
    final defaultKeyboardType = TextInputType.number;

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
          keyboardType: textFieldStyle.keyboardType ?? defaultKeyboardType,
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
