import 'package:dogs_flutter/dogs_flutter.dart';
import 'package:flutter/foundation.dart';

/// Base class for field binding controllers that manage individual field bindings.
///
/// This class provides the foundation for binding individual form fields to their
/// corresponding data structure fields.
abstract class FieldBindingController<T> extends ChangeNotifier {
  /// The parent [StructureBindingController] that manages this field.
  final FieldBindingParent parent;

  /// The binding context containing field metadata and validation rules.
  final FieldBindingContext<T> bindingContext;

  /// The widget binder that handles the conversion between data and widgets.
  final FlutterWidgetBinder binder;

  /// Creates a new [FieldBindingController] with the given [parent], [binder], and [context].
  FieldBindingController(this.parent, this.binder, this.bindingContext);

  /// The validation trigger that determines when validation occurs.
  ValidationTrigger validationTrigger = ValidationTrigger.always;

  /// The initial value of this field, will be applied post construct and
  /// may change over the lifetime of the controller. Do not manually set this
  /// here, use the [StructureBindingController] to set or change initial values.
  T? initialValue;

  /// Indicates whether this field has any state errors.
  bool get hasStateError => false;

  /// Streaming error notifier for this field.
  ValueNotifier<AnnotationResult> errorListenable = ValueNotifier(AnnotationResult.empty());

  /// Disposes of any resources held by this controller.
  @override
  @mustCallSuper
  void dispose() {
    super.dispose();
    errorListenable.dispose();
  }

  /// Sets the value for this field.
  void setValue(T? value);

  /// Gets the current value of this field.
  T? getValue();

  /// Requests focus for this field.
  void focus() {}

  /// Resets this field to its initial state.
  void reset() {
    setValue(initialValue);
  }

  /// Handles validation errors for this field.
  void handleErrors(AnnotationResult result) {
    errorListenable.value = result;
  }

  void performValidation([ValidationTrigger? trigger]) {
    if (trigger != null && !validationTrigger.has(trigger)) {
      return;
    }
    final value = getValue();
    parent.requestFieldValidation(fieldName, value);
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    parent.notifyFieldValue(fieldName, getValue());
  }
}

/// Extension methods for [FieldBindingController].
extension FieldBindingControllerExtension on FieldBindingController {
  /// Gets the name of the field this controller is bound to.
  String get fieldName => bindingContext.field.name;
}
