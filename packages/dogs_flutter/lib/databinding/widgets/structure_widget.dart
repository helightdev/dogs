import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_flutter/databinding/controller.dart';
import 'package:dogs_flutter/databinding/validation.dart';
import 'package:flutter/widgets.dart';

class StructureBinding<T> extends StatefulWidget {
  final StructureBindingController<T>? controller;
  final Widget? child;
  final ValidationTrigger? validationTrigger;
  final AnnotationTransformer? annotationTransformer;

  const StructureBinding({super.key, this.controller, this.child, this.validationTrigger, this.annotationTransformer});

  @override
  State<StructureBinding<T>> createState() => _StructureBindingState<T>();
}

class _StructureBindingState<T> extends State<StructureBinding<T>> {
  late StructureBindingController<T> controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.controller == null) {
      final structure = DogEngine.instance.findStructureByType(T);
      if (structure == null) {
        throw DogException('Structure not found for type $T');
      }
      controller = StructureBindingController<T>(structure, DogEngine.instance);
    } else {
      controller = widget.controller!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StructureBindingProvider(
      controller: controller,
      validationTrigger: widget.validationTrigger,
      annotationTransformer: widget.annotationTransformer,
      child: widget.child ?? Placeholder(),
    );
  }
}
