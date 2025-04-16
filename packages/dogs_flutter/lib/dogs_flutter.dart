library;

import 'package:dogs_flutter/databinding/bindings/int.dart';
import 'package:flutter/material.dart';

import 'databinding/bindings/bool.dart';
import 'databinding/bindings/double.dart';
import 'dogs_flutter.dart';
import 'dogs.g.dart';

// Export dogs_core and dogs_validation
export 'package:dogs_core/dogs_core.dart'
    hide LinkSerializer, isPolymorphicField, compareTypeHashcodes;
export 'package:dogs_core/dogs_validation.dart';

// dogs flutter exports
export 'databinding/widgets/field_widget.dart';
export 'databinding/widgets/structure_widget.dart';
export 'databinding/widgets/field_builder.dart';
export 'databinding/controller.dart';
export 'databinding/opmode.dart';
export 'databinding/bindings/string.dart';
export 'databinding/text_field_style.dart';

final defaultFactories = OperationModeFactory.compose<FlutterWidgetBinder>([
  OperationModeFactory.typeSingleton<String, FlutterWidgetBinder>(StringFlutterBinder()),
  OperationModeFactory.typeSingleton<int, FlutterWidgetBinder>(IntFlutterBinder()),
  OperationModeFactory.typeSingleton<double, FlutterWidgetBinder>(DoubleFlutterBinder()),
  OperationModeFactory.typeSingleton<bool, FlutterWidgetBinder>(BoolFlutterBinder()),
]);

void configureDogsFlutter({
  List<OperationModeFactory<FlutterWidgetBinder>>? binders
}) {
  installDogsFlutterConverters();
  final modeFactory = OperationModeFactory.compose<FlutterWidgetBinder>([
    ...?binders,
    defaultFactories
  ]);
  dogs.registerModeFactory(modeFactory, type: FlutterWidgetBinder);
}
