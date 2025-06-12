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
import 'package:dogs_flutter/databinding/material/list.dart';
import 'package:dogs_flutter/databinding/material/style.dart';
import 'package:dogs_flutter/databinding/opmode.dart';
import 'package:dogs_flutter/databinding/validation.dart';
import 'package:dogs_flutter/databinding/widgets/field_widget.dart';
import 'package:flutter/material.dart';

class ListFlutterBinder extends FlutterWidgetBinder<dynamic>
    with TypeCaptureMixin<dynamic>
    implements StructureMetadata {
  final TypeTree childType;
  final FlutterWidgetBinder childBinder;

  const ListFlutterBinder(this.childBinder, this.childType);

  @override
  Widget buildBindingField(
    BuildContext context,
    FieldBindingController<dynamic> controller,
  ) {
    return ListBindingFieldWidget(
      key: Key(controller.fieldName),
      controller: controller as ListBindingFieldController,
    );
  }

  @override
  FieldBindingController<dynamic> createBindingController(
    FieldBindingParent parent,
    FieldBindingContext<dynamic> context,
  ) {
    return ListBindingFieldController(
      parent,
      this,
      context,
      childBinder,
      childType,
    );
  }

  @override
  void initialise(DogEngine engine) {}

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListFlutterBinder &&
          runtimeType == other.runtimeType &&
          childType == other.childType &&
          childBinder == other.childBinder;

  @override
  int get hashCode => Object.hash(childType, childBinder);
}

class ListBindingFieldController extends FieldBindingController<dynamic>
    implements FieldBindingParent {
  final FlutterWidgetBinder childBinder;
  final TypeTree typeTree;

  Map<String, FieldBindingController> fields = {};
  List<String> fieldOrder = [];

  StreamSubscription? _fieldValueChangeSubscription;

  ListBindingFieldController(
    super.parent,
    super.binder,
    super.bindingContext,
    this.childBinder,
    this.typeTree,
  );

  int _nextId = 0;

  String _createNewField() {
    final id = (_nextId++).toString();
    final field = DogStructureField(typeTree, null, id, false, true, []);
    final converter =
        field.findConverter(null, engine: engine, nativeConverters: true)!;
    final serializerMode = engine.modeRegistry.nativeSerialization.forConverter(
      converter,
      engine,
    );
    final validator = field.getFieldValidator(engine: engine);
    FieldBindingContext creator<CAPTURE>() => FieldBindingContext<CAPTURE>(
      engine: engine,
      converter: converter,
      field: field,
      serializerMode: serializerMode,
      fieldValidator: validator,
    );

    final context = field.type.qualifiedOrBase.consumeType(creator);
    final controller = childBinder.createBindingController(this, context);
    fields[id] = controller;
    fieldOrder.add(id);
    return id;
  }

  void _removeField(String id) {
    if (fields.containsKey(id)) {
      fields.remove(id);
      fieldOrder.remove(id);
    }
  }

  void _changeToSize(int size) {
    if (size < 0) {
      throw ArgumentError('Size cannot be negative');
    }
    if (size == fieldOrder.length) {
      return; // No change needed
    }

    if (size > fieldOrder.length) {
      for (var i = fieldOrder.length; i < size; i++) {
        _createNewField();
      }
    } else {
      for (var i = fieldOrder.length - 1; i >= size; i--) {
        final id = fieldOrder[i];
        _removeField(id);
      }
    }
  }

  void addField() {
    final _ = _createNewField();
    notifyListeners();
    parent.notifyFieldValue(fieldName, getValue());
  }

  void reorderFields(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final fieldName = fieldOrder.removeAt(oldIndex);
    fieldOrder.insert(newIndex, fieldName);
    notifyFieldValue(fieldName, getValue());
  }

  void removeFieldAt(int index) {
    if (index < 0 || index >= fieldOrder.length) {
      throw RangeError.index(index, fieldOrder, 'index');
    }
    final id = fieldOrder[index];
    _removeField(id);
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
    final result = <dynamic>[];
    for (var id in fieldOrder) {
      final field = fields[id];
      if (field != null) {
        final value = field.getValue();
        if (value != null) {
          result.add(value);
          continue;
        }
      }
      result.add(null);
    }
    return result;
  }

  @override
  void setValue(dynamic value) {
    if (value == null) {
      return;
    }
    if (value is List) {
      _changeToSize(value.length);
      for (var i = 0; i < value.length; i++) {
        final item = value[i];
        final id = fieldOrder[i];
        fields[id]?.setValue(item);
      }
    }
  }

  @override
  void performValidation([ValidationTrigger? trigger]) {
    for (final field in fields.values) {
      field.performValidation(trigger);
    }
  }

  @override
  DogEngine get engine => parent.engine;

  @override
  FieldBindingController field(String name) {
    if (fields.containsKey(name)) {
      return fields[name]!;
    } else {
      throw ArgumentError('Field $name does not exist in this binding');
    }
  }

  @override
  void notifyFieldValue(String fieldName, dynamic fieldValue) {
    // Notify listeners about the field value change
    notifyListeners();
  }
}

class ListBindingFieldWidget extends StatelessWidget {
  final ListBindingFieldController controller;

  const ListBindingFieldWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = BindingTheme.of(context);
    final listStyle =
        theme.style.getExtension<ListBindingStyle>() ?? ListBindingStyle();
    final viewFactory =
        listStyle.viewFactory ?? DefaultListBindingViewFactory();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
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
                  isDense: true,
                );

            return theme.style.wrapHeaderLabelSection(
              InputDecorator(
                decoration: outerDecoration,
                child: viewFactory.buildListView(
                  context,
                  listStyle,
                  controller,
                ),
              ),
              context,
            );
          },
        );
      },
    );
  }
}

class ListAutoFactory extends OperationModeFactory<FlutterWidgetBinder> {
  @override
  FlutterWidgetBinder? forConverter(
    DogConverter<dynamic> converter,
    DogEngine engine,
  ) {
    if (converter is IterableTreeBaseConverterMixin) {
      final itemBinder = engine.modeRegistry.getConverter<FlutterWidgetBinder>(
        converter.converter,
        engine,
      );
      return ListFlutterBinder(itemBinder, converter.itemSubtree);
    }
    return null;
  }
}
