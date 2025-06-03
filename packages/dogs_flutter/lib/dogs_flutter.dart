library;

import 'package:dogs_flutter/databinding/bindings/enum.dart';

import 'dogs_flutter.dart';
import 'dogs.g.dart';

// Export dogs_core and dogs_validation
export 'package:dogs_core/dogs_core.dart'
    hide LinkSerializer, isPolymorphicField, compareTypeHashcodes;
export 'package:dogs_core/dogs_validation.dart';

// Databinding exports
export 'databinding/bindings/bool.dart';
export 'databinding/bindings/double.dart';
export 'databinding/bindings/fallback.dart';
export 'databinding/bindings/int.dart';
export 'databinding/bindings/list.dart';
export 'databinding/bindings/nested_structure.dart';
export 'databinding/bindings/string.dart';

// Databinding Widgets
export 'databinding/widgets/field_builder.dart';
export 'databinding/widgets/field_widget.dart';
export 'databinding/widgets/structure_widget.dart';

// Other Databinding exports
export 'databinding/layout/column_layout.dart';
export 'databinding/material/style.dart';
export 'databinding/validators/format.dart';
export 'databinding/validators/required.dart';
export 'databinding/controller.dart';
export 'databinding/field_controller.dart';
export 'databinding/opmode.dart';
export 'databinding/style.dart';
export 'databinding/text_field_style.dart';
export 'databinding/validation.dart';

// Flutter-specific converters
export 'converters/auto.dart';
export 'converters/geometric.dart';
export 'converters/various.dart';

// Schema utilities
export 'schema/custom_tags.dart';
export 'schema/binding_style_contributor.dart';

final defaultFactories = OperationModeFactory.compose<FlutterWidgetBinder>([
  ListAutoFactory(),
  EnumAutoFactory(),
  NestedStructureAutoFactory(),
  OperationModeFactory.typeSingleton<String, FlutterWidgetBinder>(StringFlutterBinder()),
  OperationModeFactory.typeSingleton<int, FlutterWidgetBinder>(IntFlutterBinder()),
  OperationModeFactory.typeSingleton<double, FlutterWidgetBinder>(DoubleFlutterBinder()),
  OperationModeFactory.typeSingleton<bool, FlutterWidgetBinder>(BoolFlutterBinder()),
]);

void configureDogsFlutter({
  List<OperationModeFactory<FlutterWidgetBinder>>? binders,
  bool addSchemaContributors = true,
}) {
  installDogsFlutterConverters();
  final modeFactory = OperationModeFactory.compose<FlutterWidgetBinder>([
    ...?binders,
    defaultFactories
  ]);
  dogs.registerModeFactory(modeFactory, type: FlutterWidgetBinder);

  if (addSchemaContributors) {
    DogsMaterializer.get().contributors.add(SchemaBindingStyleContributor());
  }
}
