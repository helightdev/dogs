import 'package:dogs_flutter/dogs_flutter.dart';
import 'package:flutter/widgets.dart';

class StructureBinding<T> extends StatefulWidget {
  final StructureBindingController<T>? controller;
  final Widget? child;
  final ValidationTrigger? validationTrigger;
  final AnnotationTransformer? annotationTransformer;
  final AutoStructureBindingLayout autoLayout;

  const StructureBinding({
    super.key,
    this.controller,
    this.child,
    this.validationTrigger,
    this.annotationTransformer,
    this.autoLayout = const ColumnAutoStructureBindingLayout(),
  });

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
    final Widget child;
    if (widget.child == null) {
      child = widget.autoLayout.buildStructureWidget(context, controller);
    } else {
      child = widget.child!;
    }

    return StructureBindingProvider(
      controller: controller,
      validationTrigger: widget.validationTrigger,
      annotationTransformer: widget.annotationTransformer,
      child: child,
    );
  }
}

abstract interface class AutoStructureBindingLayout {
  Widget buildStructureWidget(BuildContext context, StructureBindingController controller);
}
