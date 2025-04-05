import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_flutter/databinding/controller.dart';
import 'package:dogs_flutter/databinding/opmode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../validation.dart';

class FallbackFlutterBinder extends FlutterWidgetBinder<dynamic>
    with TypeCaptureMixin<dynamic> {

  static final FallbackFlutterBinder shared = FallbackFlutterBinder();

  @override
  Widget buildBindingField(
    BuildContext context,
    FieldBindingController controller,
  ) {
    return FallbackBindingFieldWidget(
      key: Key(controller.fieldName),
      controller: controller,
    );
  }

  @override
  FieldBindingController createBindingController(
    StructureBindingController parent,
    FieldBindingContext context,
  ) {
    return FallbackBindingFieldController(parent, this, context);
  }

  @override
  void initialise(DogEngine engine) {}
}

class FallbackBindingFieldController extends FieldBindingController<dynamic> {
  FallbackBindingFieldController(
    super.parent,
    super.binder,
    super.bindingContext,
  );

  final ValueNotifier<dynamic> valueListenable = ValueNotifier(null);

  @override
  dynamic getValue() {
    return valueListenable.value;
  }

  @override
  void setValue(dynamic value) {
    valueListenable.value = value;
    notifyListeners();
    performValidation(ValidationTrigger.onInteraction);
  }
}

class FallbackBindingFieldWidget extends StatelessWidget {
  final FieldBindingController controller;

  const FallbackBindingFieldWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ErrorWidget("No binding available for field ${controller.fieldName}");
  }
}
