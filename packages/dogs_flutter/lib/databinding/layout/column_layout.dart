import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_flutter/databinding/controller.dart';
import 'package:dogs_flutter/databinding/field_controller.dart';
import 'package:dogs_flutter/databinding/widgets/field_widget.dart';
import 'package:dogs_flutter/databinding/widgets/structure_widget.dart';
import 'package:flutter/material.dart';

class ColumnAutoStructureBindingLayout extends StructureMetadata
    implements AutoStructureBindingLayout {
  final double spacing;
  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final Widget? header;
  final Widget? footer;

  const ColumnAutoStructureBindingLayout({
    this.spacing = 8.0,
    this.mainAxisSize = MainAxisSize.min,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.header,
    this.footer,
  });

  @override
  Widget buildStructureWidget(BuildContext context, StructureBindingController controller) {
    final fields = controller.fields.map((e) {
      return FieldBinding(field: e.fieldName);
    }).toList();
    return Column(
      spacing: spacing,
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: [if (header != null) header!, ...fields, if (footer != null) footer!],
    );
  }
}
