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

import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_flutter/databinding/bindings/fallback.dart';
import 'package:dogs_flutter/databinding/controller.dart';
import 'package:dogs_flutter/databinding/field_controller.dart';
import 'package:dogs_flutter/databinding/validators/required.dart';
import 'package:flutter/widgets.dart';

abstract class FlutterWidgetBinder<T> implements OperationMode<T> {
  const FlutterWidgetBinder();

  static (FlutterWidgetBinder, FieldBindingContext context) resolveBinder(
    DogEngine engine,
    DogStructure structure,
    DogStructureField field,
  ) {
    var binder = field.firstAnnotationOf<FlutterWidgetBinder>();
    final converter =
        field.findConverter(structure, engine: engine, nativeConverters: true)!;
    binder ??= engine.modeRegistry
        .entry<FlutterWidgetBinder>()
        .forConverterNullable(converter, engine);
    binder ??= FallbackFlutterBinder.shared;
    FieldBindingContext creator<CAPTURE>() => FieldBindingContext<CAPTURE>(
      engine: engine,
      converter: converter,
      field: field,
      serializerMode: engine.modeRegistry.nativeSerialization.forConverter(
        converter,
        engine,
      ),
      fieldValidator: field.getFieldValidator(
        guardValidator: field.optional ? null : DatabindRequiredGuard(),
      ),
    );

    final context = field.type.qualifiedOrBase.consumeType(creator);
    return (binder, context);
  }

  FieldBindingController<T> createBindingController(
    FieldBindingParent parent,
    FieldBindingContext<T> context,
  );

  Widget buildBindingField(
    BuildContext context,
    FieldBindingController<T> controller,
  );

  Widget buildView(T? value) {
    if (value == null) return SizedBox.shrink();
    return Text(value.toString());
  }
}

class FieldBindingContext<T> with TypeCaptureMixin<T> {
  DogEngine engine;
  DogConverter converter;
  DogStructureField field;

  NativeSerializerMode serializerMode;
  IsolatedFieldValidator fieldValidator;

  FieldBindingContext({
    required this.engine,
    required this.converter,
    required this.field,
    required this.serializerMode,
    required this.fieldValidator,
  });
}
