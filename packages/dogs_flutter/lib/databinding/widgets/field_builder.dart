import 'package:dogs_flutter/databinding/controller.dart';
import 'package:dogs_flutter/databinding/widgets/field_widget.dart';
import 'package:flutter/widgets.dart';

class FieldBindingBuilder extends StatefulWidget {
  final String? fieldName;
  final Widget Function(BuildContext context, FieldBindingController controller)
  builder;

  const FieldBindingBuilder({super.key, this.fieldName, required this.builder});

  @override
  State<FieldBindingBuilder> createState() => _FieldBindingBuilderState();
}

class _FieldBindingBuilderState extends State<FieldBindingBuilder> {

  FieldBindingController? controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.fieldName != null) {
      var rootProvider = StructureBindingProvider.of(context);
      final structureController = rootProvider.controller;
      final fieldName = widget.fieldName;
      if (fieldName == null) {
        throw ArgumentError('Field name cannot be null when controller is not provided');
      }
      controller = structureController.field(fieldName);
    } else {
      throw ArgumentError('Field name cannot be null when controller is not provided');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, controller!);
  }
}
