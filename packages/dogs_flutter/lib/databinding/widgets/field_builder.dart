import 'package:dogs_flutter/databinding/controller.dart';
import 'package:dogs_flutter/databinding/field_controller.dart';
import 'package:flutter/widgets.dart';

class FieldBindingBuilder<T extends FieldBindingController> extends StatefulWidget {
  final String? fieldName;
  final Widget Function(BuildContext context, T controller) builder;

  const FieldBindingBuilder({super.key, this.fieldName, required this.builder});

  @override
  State<FieldBindingBuilder> createState() => _FieldBindingBuilderState<T>();
}

class _FieldBindingBuilderState<T extends FieldBindingController> extends State<FieldBindingBuilder<T>> {

  T? controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.fieldName != null) {
      var rootProvider = StructureBindingProvider.of(context);
      final structureController = rootProvider.controller;
      final fieldName = widget.fieldName;
      if (fieldName == null) {
        throw ArgumentError("Field name cannot be null when controller is not provided");
      }
      final resolvedController = structureController.field(fieldName);
      if (resolvedController is! T) {
        throw ArgumentError("Controller for field '$fieldName' is not of type ${T.runtimeType} but ${resolvedController.runtimeType}");
      }
      controller = resolvedController;
    } else {
      throw ArgumentError("Field name cannot be null when controller is not provided");
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, controller!);
  }
}
