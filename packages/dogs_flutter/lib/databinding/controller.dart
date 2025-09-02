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
import 'package:dogs_flutter/databinding/field_controller.dart';
import 'package:dogs_flutter/databinding/opmode.dart';
import 'package:dogs_flutter/databinding/validation.dart';
import 'package:flutter/widgets.dart';

/// A controller that manages the binding between a data structure and Flutter widgets.
///
/// This controller handles field validation, error states, and value management for
/// a structured data type [T]. It provides a way to bind form fields to a data structure
/// while maintaining validation and error handling.
class StructureBindingController<T>
    with MetadataMixin
    implements FieldBindingParent {
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
  @override
  late final DogEngine engine;

  /// A list of widget binders that handle the conversion between data and widgets for each field.
  final List<FlutterWidgetBinder> factories = [];

  /// A list of controllers that manage the binding state for each individual field.
  final List<FieldBindingController> fields = [];

  /// A notifier that holds all currently reported class errors.
  final ValueNotifier<AnnotationResult> classErrorListenable = ValueNotifier(
    AnnotationResult.empty(),
  );

  final StreamController<(String, dynamic)> _fieldValueChangeController =
      StreamController.broadcast(sync: true);

  Stream<(String, dynamic)> get fieldValueChangeStream =>
      _fieldValueChangeController.stream;

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
        engine,
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
      fieldValidators: fields
          .map((e) => e.bindingContext.fieldValidator)
          .toList(),
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

  /// Creates a new [StructureBindingController] from a [SchemaType].
  static StructureBindingController schema({
    required SchemaType schema,
    DogEngine? engine,
    Map<String, dynamic>? initialValue,
  }) {
    engine ??= DogEngine.instance;
    final materialized = engine.materialize(schema);
    return StructureBindingController(
      materialized.structure,
      materialized.engineFork,
      initialValues: initialValue ?? {},
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
      _fieldValueChangeController.add((field.fieldName, field.getValue()));
      field.handleErrors(AnnotationResult.empty());
    }
    _errorBuffer.clearAll();
    _errorBuffer.recalculateFieldErrors();
  }

  /// Notifies the controller of a field value change.
  ///
  /// This method updates the validation state and error handling for the field named [fieldName]
  /// with the new [fieldValue].
  @override
  void notifyFieldValue(String fieldName, dynamic fieldValue) {
    _fieldValueChangeController.add((fieldName, fieldValue));
  }

  @override
  void requestFieldValidation(String fieldName, dynamic fieldValue) {
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
  @override
  FieldBindingController field(String name) {
    final index = _fieldNames.indexOf(name);
    if (index == -1) {
      throw ArgumentError("No field with name $name");
    }
    return fields[index];
  }

  /// Swaps out a field's binding controller with a new one while preserving its current value.
  ///
  /// This method allows dynamically replacing how a field is handled at runtime by
  /// switching to a different controller implementation. The current value of the field
  /// is preserved during the swap.
  void swapController(
    String fieldName,
    FieldBindingController controller, {
    FlutterWidgetBinder? binder,
  }) {
    final index = _fieldNames.indexOf(fieldName);
    if (index == -1) {
      throw ArgumentError("No field with name $fieldName");
    }
    if (binder != null) {
      factories[index] = binder;
    }
    final currentValue = fields[index].getValue();
    fields[index] = controller;
    controller.setValue(currentValue);
  }

  /// Rebinds a field to use a different widget binder.
  ///
  /// This method allows changing how a field is rendered and bound to widgets at runtime.
  /// It preserves the current value of the field while switching to the new binding.
  void rebindField(String fieldName, FlutterWidgetBinder binder) {
    final index = _fieldNames.indexOf(fieldName);
    if (index == -1) {
      throw ArgumentError("No field with name $fieldName");
    }
    var field = fields[index];
    final currentValue = field.getValue();
    final controller = binder.createBindingController(
      this,
      field.bindingContext,
    );
    factories[index] = binder;
    fields[index] = controller;
    controller.setValue(currentValue);
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
    final (result, current) = runValidation(ValidationTrigger.onSubmit);
    if (!result) return null;
    return current;
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

  T? submit() => read(false);

  (bool result, T? current) runValidation(ValidationTrigger? trigger) {
    bool hasGuardMatched = false;
    bool hasStateError = false;
    T? current;
    for (var i = 0; i < fields.length; i++) {
      final field = fields[i];
      field.performValidation(trigger);

      final fieldValue = field.getValue();
      final (results, isGuard) = _classValidator.annotateFieldExtended(
        field.fieldName,
        fieldValue,
      );
      _errorBuffer.putAll(results);

      if (field.hasStateError) {
        hasStateError = true;
      }
      if (isGuard) {
        hasGuardMatched = true;
      }
    }

    if (!hasGuardMatched) {
      current = _readSilent();
      if (current != null) {
        final results = _classValidator.annotateExtended(current);
        _errorBuffer.putAll(results);
      }
    }

    _errorBuffer.recalculateFieldErrors();

    for (var value in fields) {
      value.handleErrors(_errorBuffer.fieldErrors[value.fieldName]!);
    }

    if (checkErrorStates && hasStateError) return (false, current);
    return (!_errorBuffer.hasErrors, current);
  }

  void load(T value) {
    final fieldValues = structure.getFieldMap(value);
    for (var i = 0; i < fields.length; i++) {
      final field = fields[i];
      final fieldValue = fieldValues[field.fieldName];
      field.setValue(fieldValue);
      _fieldValueChangeController.add((field.fieldName, fieldValue));
    }
    _errorBuffer.clearCustom();
    _errorBuffer.recalculateFieldErrors();

    runValidation(
      ValidationTrigger.onInteraction,
    ); // Loading counts as an interaction
  }

  /// Adds a custom runtime error to the error buffer and recalculates field errors.
  void addRuntimeError(AnnotationResultLike error) {
    _errorBuffer.putCustom(error.asAnnotationResult());
    _errorBuffer.recalculateFieldErrors();
  }
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
    final newMessages = messages.map((e) {
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
    required super.child,
    required this.controller,
    this.validationTrigger,
    this.annotationTransformer,
  });

  /// Gets the nearest [StructureBindingProvider] in the widget tree.
  ///
  /// Throws an assertion error if no provider is found in the [context].
  static StructureBindingProvider of(BuildContext context) {
    final StructureBindingProvider? result = context
        .dependOnInheritedWidgetOfExactType<StructureBindingProvider>();
    assert(result != null, 'No StructureBindingProvider found in context');
    return result!;
  }

  static StructureBindingProvider? maybeOf(BuildContext context) {
    final StructureBindingProvider? result = context
        .dependOnInheritedWidgetOfExactType<StructureBindingProvider>();
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
    factories = structure.fields.map((e) {
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
    return factories[index].buildView(
      structure.proxy.getFieldValues(value)[index],
    );
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

abstract interface class FieldBindingParent {
  /// The dogs engine instance associated with this binding parent.
  DogEngine get engine;

  /// Notifies the controller of a field value change.
  void notifyFieldValue(String fieldName, dynamic fieldValue) {}

  /// Requests validation for a specific field.
  /// The result of the validation will be pushed to the field's [ValueNotifier].
  void requestFieldValidation(String fieldName, dynamic fieldValue) {}

  /// Gets the binding controller for a specific field.
  ///
  /// Returns the [FieldBindingController] for the specified [name]. Throws an
  /// [ArgumentError] if no field with the given name exists.
  FieldBindingController field(String name);
}
