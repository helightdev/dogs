/*
 *    Copyright 2022, the DOGs authors
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

import 'dart:async';

import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_flutter/databinding/validation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'opmode.dart';

/// A controller that manages the binding between a data structure and Flutter widgets.
///
/// This controller handles field validation, error states, and value management for
/// a structured data type [T]. It provides a way to bind form fields to a data structure
/// while maintaining validation and error handling.
class StructureBindingController<T> {
  /// The underlying data structure definition that describes the shape of the data.
  final DogStructure structure;

  /// Initial values to populate the controller with when it is first created.
  final Map<String, dynamic> initialValues;

  /// Controls whether the controller checks for state errors before returning submitted values.
  ///
  /// State errors are invalid user inputs that are not related to the structure validation
  /// itself where they are just reported as null values.
  final bool checkErrorStates = true;

  /// The DOGs engine instance used for validation and structure operations.
  late final DogEngine engine;

  /// A list of widget binders that handle the conversion between data and widgets for each field.
  final List<FlutterWidgetBinder> factories = [];

  /// A list of controllers that manage the binding state for each individual field.
  final List<FieldBindingController> fields = [];

  /// A notifier that holds all currently reported class errors.
  final ValueNotifier<AnnotationResult> classErrorListenable = ValueNotifier(
    AnnotationResult.empty(),
  );

  final List<String> _fieldNames = [];
  late final IsolatedClassValidator _classValidator;
  late final BindingsErrorBuffer _errorBuffer;

  /// Creates a new [StructureBindingController] with the given [structure] and [engine].
  ///
  /// The controller will be initialized with the provided structure and engine, and
  /// optionally populated with [initialValues].
  StructureBindingController(
    this.structure,
    this.engine, {
    this.initialValues = const {},
  }) {
    for (var e in structure.fields) {
      final (binder, context) = FlutterWidgetBinder.resolveBinder(
        this.engine,
        structure,
        e,
      );
      final controller = binder.createBindingController(this, context);
      factories.add(binder);
      fields.add(controller);
      _fieldNames.add(e.name);
    }
    _classValidator = structure.getClassValidator(
      engine: engine,
      fieldValidators:
          fields.map((e) => e.bindingContext.fieldValidator).toList(),
    );
    _errorBuffer = BindingsErrorBuffer(structure, _classValidator, () {
      classErrorListenable.value = _errorBuffer.classErrors;
    });
    setInitialValues(initialValues);
    reset();
  }

  /// Creates a new [StructureBindingController] for type [T].
  ///
  /// This factory method provides a convenient way to create a controller for a specific
  /// type, optionally with [initialValues] or an [initialValue] of type [T].
  static StructureBindingController<T> create<T>({
    Map<String, dynamic>? initialValues,
    T? initialValue,
    DogEngine? engine,
  }) {
    engine ??= DogEngine.instance;
    final structure = engine.findStructureByType(T)!;
    Map<String, dynamic> initial = {};
    if (initialValue != null) {
      initial.addAll(structure.getFieldMap(initialValue));
    }
    if (initialValues != null) {
      initial.addAll(initialValues);
    }
    return StructureBindingController<T>(
      structure,
      engine,
      initialValues: initial,
    );
  }

  /// Sets the initial values for the fields in this controller.
  ///
  /// This does change the current value of the fields, those will only occur
  /// once [FieldBindingController.reset] is called.
  void setInitialValues(Map<String, dynamic> values) {
    for (var i = 0; i < fields.length; i++) {
      final field = fields[i];
      final fieldValue = values[field.fieldName];
      field.initialValue = fieldValue;
    }
  }

  /// Resets the state of all fields in this controller,
  /// loading the initial values.
  ///
  /// This method calls the [FieldBindingController.reset] method on all fields,
  /// the exact behavior of this method is dependent on the implementation
  /// of the [FieldBindingController] and may be different to normal
  /// [FieldBindingController.setValue] calls.
  void reset() {
    for (var i = 0; i < fields.length; i++) {
      final field = fields[i];
      field.reset();
    }
  }

  /// Notifies the controller of a field value change.
  ///
  /// This method updates the validation state and error handling for the field named [fieldName]
  /// with the new [fieldValue].
  void notifyFieldValue(String fieldName, dynamic fieldValue) {
    final (results, isGuard) = _classValidator.annotateFieldExtended(
      fieldName,
      fieldValue,
    );
    _errorBuffer.putAll(results);
    _errorBuffer.recalculateFieldErrors();
    field(fieldName).handleErrors(_errorBuffer.fieldErrors[fieldName]!);
  }

  /// Gets the binding controller for a specific field.
  ///
  /// Returns the [FieldBindingController] for the specified [name]. Throws an
  /// [ArgumentError] if no field with the given name exists.
  FieldBindingController field(String name) {
    final index = _fieldNames.indexOf(name);
    if (index == -1) {
      throw ArgumentError("No field with name $name");
    }
    return fields[index];
  }

  /// Reads the current state of all fields without validation.
  ///
  /// Returns the instantiated object of type [T] if all required fields are present,
  /// or null if any required field is missing.
  T? _readSilent() {
    final fieldValues = <String, dynamic>{};
    for (var i = 0; i < fields.length; i++) {
      final field = fields[i];
      final fieldValue = field.getValue();
      if (!field.bindingContext.field.optional && fieldValue == null) {
        // Guard would be hit here, so we just skip
        return null;
      }
      fieldValues[field.fieldName] = fieldValue;
    }
    final instantiated = structure.instantiateFromFieldMap(fieldValues);
    if (!_classValidator.isValid(instantiated)) return null;
    return instantiated;
  }

  /// Reads the current state of all fields with full validation.
  ///
  /// Returns the instantiated object of type [T] if all validations pass, or null
  /// if any validation fails or if there are state errors.
  T? _readSound() {
    final fieldValues = <String, dynamic>{};
    bool hasGuardMatched = false;
    bool hasStateError = false;
    for (var i = 0; i < fields.length; i++) {
      final field = fields[i];
      if (field.hasStateError) {
        hasStateError = true;
      }
      // Silent because we annotate later
      final fieldValue = field.getValue();
      final (results, isGuard) = _classValidator.annotateFieldExtended(
        field.fieldName,
        fieldValue,
      );
      _errorBuffer.putAll(results);
      if (isGuard) {
        hasGuardMatched = true;
      }
      fieldValues[field.fieldName] = fieldValue;
    }
    if (hasGuardMatched) {
      _errorBuffer.recalculateFieldErrors();
      for (var value in fields) {
        value.handleErrors(_errorBuffer.fieldErrors[value.fieldName]!);
      }
      return null;
    }
    final instantiated = structure.instantiateFromFieldMap(fieldValues);
    _errorBuffer.putAll(_classValidator.annotateExtended(instantiated));
    _errorBuffer.recalculateFieldErrors();
    // Propagate errors to fields
    for (var value in fields) {
      value.handleErrors(_errorBuffer.fieldErrors[value.fieldName]!);
    }
    if (_errorBuffer.hasErrors) return null;
    if (checkErrorStates && hasStateError) return null;
    return instantiated;
  }

  /// Reads the current state of all fields.
  ///
  /// When [silent] is true, performs minimal validation. When false, performs full
  /// validation including state error checking.
  T? read(bool silent) {
    if (silent) {
      return _readSilent();
    } else {
      return _readSound();
    }
  }
}

/// Base class for field binding controllers that manage individual field bindings.
///
/// This class provides the foundation for binding individual form fields to their
/// corresponding data structure fields.
abstract class FieldBindingController<T> extends ChangeNotifier {
  /// The parent [StructureBindingController] that manages this field.
  final StructureBindingController parent;

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
  ValueNotifier<AnnotationResult> errorListenable = ValueNotifier(
    AnnotationResult.empty(),
  );

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
    parent.notifyFieldValue(fieldName, value);
  }
}

/// Extension methods for [FieldBindingController].
extension FieldBindingControllerExtension on FieldBindingController {
  /// Gets the name of the field this controller is bound to.
  String get fieldName => bindingContext.field.name;
}

typedef AnnotationTransformer =
    AnnotationResult Function(AnnotationResult result);
typedef MessageTransformer =
    AnnotationMessage Function(AnnotationMessage message);

/// Extension methods for [AnnotationResult].
extension AnnotationResultExtensions on AnnotationResult {
  /// Gets the error message if there are any errors, or null if there are no errors.
  String? get errorText => hasErrors ? buildMessages().join("\n") : null;

  AnnotationResult maybeTransform(AnnotationTransformer? func) {
    if (func == null) return this;
    return func(this);
  }

  AnnotationResult replace(
    String id, {
    MessageTransformer? func,
    String? message,
  }) {
    final newMessages =
        messages.map((e) {
          if (e.id == id) {
            if (func != null) {
              return func(e);
            } else if (message != null) {
              return e.withMessage(message);
            }
          }
          return e;
        }).toList();
    return AnnotationResult(messages: newMessages);
  }

  AnnotationResult remove(String id) {
    final newMessages = messages.where((e) => e.id != id).toList();
    return AnnotationResult(messages: newMessages);
  }
}

/// An [InheritedWidget] that provides a [StructureBindingController] to the widget tree.
///
/// This widget makes the binding controller available to all descendant widgets
/// in the tree.
class StructureBindingProvider extends InheritedWidget {
  /// The binding controller being provided to the widget tree.
  final StructureBindingController controller;
  final ValidationTrigger? validationTrigger;
  final AnnotationTransformer? annotationTransformer;

  /// Creates a new [StructureBindingProvider] with the given [controller] and [child].
  const StructureBindingProvider({
    super.key,
    required Widget child,
    required this.controller,
    this.validationTrigger,
    this.annotationTransformer,
  }) : super(child: child);

  /// Gets the nearest [StructureBindingProvider] in the widget tree.
  ///
  /// Throws an assertion error if no provider is found in the [context].
  static StructureBindingProvider of(BuildContext context) {
    final StructureBindingProvider? result =
        context.dependOnInheritedWidgetOfExactType<StructureBindingProvider>();
    assert(result != null, 'No StructureBindingProvider found in context');
    return result!;
  }

  static StructureBindingProvider? maybeOf(BuildContext context) {
    final StructureBindingProvider? result =
        context.dependOnInheritedWidgetOfExactType<StructureBindingProvider>();
    return result;
  }

  @override
  bool updateShouldNotify(StructureBindingProvider old) {
    return controller != old.controller;
  }
}

class StructureViewer<T> {
  final DogEngine engine;
  final DogStructure structure;

  late List<FlutterWidgetBinder> factories;

  StructureViewer(this.engine, this.structure) {
    factories =
        structure.fields.map((e) {
          final (binder, context) = FlutterWidgetBinder.resolveBinder(
            engine,
            structure,
            e,
          );
          return binder;
        }).toList();
  }

  static StructureViewer<T> create<T>({DogEngine? engine}) {
    engine ??= DogEngine.instance;
    final structure = engine.findStructureByType(T);
    if (structure == null) {
      throw ArgumentError("No structure found for type $T");
    }
    return StructureViewer<T>(engine, structure);
  }

  Iterable<Widget> buildRow(T value) sync* {
    final fieldValues = structure.proxy.getFieldValues(value);
    for (var i = 0; i < factories.length; i++) {
      final factory = factories[i];
      final value = fieldValues[i];
      yield factory.buildView(value);
    }
  }

  Iterable<Widget> buildHeaderRow() sync* {
    for (var i = 0; i < factories.length; i++) {
      var field = structure.fields[i];
      yield Text(field.name);
    }
  }

  Widget fieldAt(T value, int index) {
    if (index < 0 || index >= factories.length) {
      throw ArgumentError("No field with index $index");
    }
    return factories[index].buildView(structure.proxy.getFieldValues(value)[index]);
  }

  Widget fieldNamed(T value, String name) {
    final index = structure.fields.indexWhere((e) => e.name == name);
    if (index == -1) {
      throw ArgumentError("No field with name $name");
    }
    return fieldAt(value, index);
  }

  Widget headerAt(int index) {
    if (index < 0 || index >= factories.length) {
      throw ArgumentError("No field with index $index");
    }
    return Text(structure.fields[index].name);
  }
}
