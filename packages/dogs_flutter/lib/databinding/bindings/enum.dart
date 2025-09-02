import 'package:dogs_flutter/dogs_flutter.dart';
import 'package:flutter/material.dart';

class EnumFlutterBinder extends FlutterWidgetBinder<String>
    with TypeCaptureMixin<String>
    implements StructureMetadata {
  final EnumConverter converter;

  const EnumFlutterBinder(this.converter);

  @override
  Widget buildBindingField(
    BuildContext context,
    FieldBindingController<String> controller,
  ) {
    return EnumBindingFieldWidget(
      key: Key(controller.fieldName),
      controller: controller as EnumBindingFieldController,
    );
  }

  @override
  FieldBindingController<String> createBindingController(
    FieldBindingParent parent,
    FieldBindingContext<String> context,
  ) {
    return EnumBindingFieldController(parent, this, context, converter);
  }

  @override
  void initialise(DogEngine engine) {}

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnumFlutterBinder &&
          runtimeType == other.runtimeType &&
          converter == other.converter;

  @override
  int get hashCode => converter.hashCode;
}

class EnumBindingFieldController extends FieldBindingController<String> {
  final FocusNode focusNode = FocusNode();
  String? value;
  final EnumConverter converter;

  EnumBindingFieldController(
    super.parent,
    super.binder,
    super.bindingContext,
    this.converter,
  ) {
    focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
  }

  void _onFocusChanged() {
    if (!focusNode.hasFocus) {
      performValidation(ValidationTrigger.onUnfocus);
    }
  }

  @override
  String? getValue() {
    return value;
  }

  @override
  void setValue(String? value) {
    this.value = value;
    notifyListeners();
  }
}

class EnumBindingFieldWidget extends StatelessWidget {
  final EnumBindingFieldController controller;

  const EnumBindingFieldWidget({super.key, required this.controller});

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
              isDense: true,
            );
        return InputDecorator(
          decoration: outerDecoration,
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, child) => DropdownButton<String>(
              value: controller.value,
              items: controller.converter.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              isExpanded: true,
              hint: theme.style.buildMaterialLabelText(context),
              onChanged: (String? value) {
                controller.setValue(value);
              },
            ),
          ),
        );
      },
    );
  }
}

class EnumAutoFactory extends OperationModeFactory<FlutterWidgetBinder> {
  @override
  FlutterWidgetBinder? forConverter(
    DogConverter<dynamic> converter,
    DogEngine engine,
  ) {
    if (converter is EnumConverter) {
      return EnumFlutterBinder(converter);
    }
    return null;
  }
}
