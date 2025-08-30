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

import 'dart:async';

import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_flutter/databinding/controller.dart';
import 'package:dogs_flutter/databinding/field_controller.dart';
import 'package:dogs_flutter/databinding/material/style.dart';
import 'package:dogs_flutter/databinding/opmode.dart';
import 'package:dogs_flutter/databinding/validation.dart';
import 'package:dogs_flutter/databinding/widgets/field_widget.dart';
import 'package:dogs_flutter/databinding/widgets/structure_widget.dart';
import 'package:flutter/material.dart';

class NestedStructureFlutterBinder extends FlutterWidgetBinder<dynamic>
    with TypeCaptureMixin<dynamic>
    implements StructureMetadata {
  final DogStructure structure;

  const NestedStructureFlutterBinder(this.structure);

  @override
  Widget buildBindingField(
    BuildContext context,
    FieldBindingController<dynamic> controller,
  ) {
    return NestedStructureBindingFieldWidget(
      key: Key(controller.fieldName),
      controller: controller as NestedStructureBindingFieldController,
    );
  }

  @override
  FieldBindingController<dynamic> createBindingController(
    FieldBindingParent parent,
    FieldBindingContext<dynamic> context,
  ) {
    return NestedStructureBindingFieldController(
      parent,
      this,
      context,
      structure,
    );
  }

  @override
  void initialise(DogEngine engine) {}

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NestedStructureFlutterBinder &&
          runtimeType == other.runtimeType &&
          structure == other.structure;

  @override
  int get hashCode => structure.hashCode;
}

class NestedStructureBindingFieldController
    extends FieldBindingController<dynamic> {
  late final StructureBindingController controller;

  StreamSubscription? _fieldValueChangeSubscription;

  NestedStructureBindingFieldController(
    super.parent,
    super.binder,
    super.bindingContext,
    DogStructure structure,
  ) {
    controller = StructureBindingController(structure, parent.engine);
    _fieldValueChangeSubscription = controller.fieldValueChangeStream.listen(
      _handleChange,
    );
  }

  void _handleChange(_) {
    notifyListeners();
    parent.notifyFieldValue(fieldName, getValue());
  }

  @override
  void dispose() {
    _fieldValueChangeSubscription?.cancel();
    super.dispose();
  }

  @override
  dynamic getValue() {
    return controller.read(true);
  }

  @override
  void setValue(dynamic value) {
    if (value == null) {
      controller.reset();
      return;
    }
    controller.load(value);
  }

  @override
  void performValidation([ValidationTrigger? trigger]) {
    if (trigger != null && trigger == ValidationTrigger.onSubmitGuard) {
      controller.read(false);
    }
  }
}

class NestedStructureBindingFieldWidget extends StatelessWidget {
  final NestedStructureBindingFieldController controller;

  const NestedStructureBindingFieldWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = BindingTheme.of(context);
    return ValueListenableBuilder(
      valueListenable: controller.errorListenable,
      builder: (context, error, _) {
        final outerDecoration = theme.style
            .buildMaterialDecoration(
              context,
              controller,
              includeLabel: false,
              includeHint: false,
              includeHelper: false,
            )
            .copyWith(
              errorText: theme.toErrorText(error),
              border: InputBorder.none,
            );
        return theme.style.wrapHeader(
            StructureBinding(
              controller: controller.controller,
              validationTrigger: controller.validationTrigger,
            ),
            context,
            errorText: error.errorText
        );
      },
    );
  }
}

class NestedStructureAutoFactory
    extends OperationModeFactory<FlutterWidgetBinder> {
  @override
  FlutterWidgetBinder? forConverter(
    DogConverter<dynamic> converter,
    DogEngine engine,
  ) {
    final struct = converter.struct;
    if (struct != null && !struct.isSynthetic) {
      return NestedStructureFlutterBinder(struct);
    }
    return null;
  }
}
