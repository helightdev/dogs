/*
 *    Copyright 2022, the DOGs authors
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
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
import 'package:dogs_forms/dogs_forms.dart';
import 'package:dogs_forms/src/fields/date_time_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

export 'fields/checkbox_field.dart';
export 'fields/data_choicechip.dart';
export 'fields/data_dropdown.dart';
export 'fields/data_radiogroup.dart';
export 'fields/double_text_field.dart';
export 'fields/enum_dropdown.dart';
export 'fields/int_text_field.dart';
export 'fields/list_field.dart';
export 'fields/slider_field.dart';
export 'fields/structure_field.dart';
export 'fields/text_field.dart';

/// A composition of default [OperationModeFactory]s that are implemented by
/// the dogs_forms package. To add your own [OperationModeFactory]s, you can
/// use [OperationModeFactory.compose] to compose your own [OperationModeFactory]
/// with this one. To override the defaults, you can specify them before the
/// [defaultFormFactories].
final defaultFormFactories = OperationModeFactory.compose<AutoFormFieldFactory>(
  [
    OperationModeFactory.converterSingleton<NativeRetentionConverter<String>, AutoFormFieldFactory>(const TextFieldFormFieldFactory()),
    OperationModeFactory.converterSingleton<NativeRetentionConverter<int>, AutoFormFieldFactory>(const IntTextFieldFormFieldFactory()),
    OperationModeFactory.converterSingleton<NativeRetentionConverter<double>, AutoFormFieldFactory>(const DoubleTextFieldFormFieldFactory()),
    OperationModeFactory.converterSingleton<NativeRetentionConverter<bool>, AutoFormFieldFactory>(const CheckboxFormFieldFactory()),
    OperationModeFactory.typeSingleton<DateTime, AutoFormFieldFactory>(const DateTimeFormFieldFactory()),
    ListFieldOperationModeFactory<String>(const TextFieldFormFieldFactory()),
    ListFieldOperationModeFactory<int>(const IntTextFieldFormFieldFactory()),
    ListFieldOperationModeFactory<double>(const DoubleTextFieldFormFieldFactory()),
    ListFieldOperationModeFactory<DateTime>(const DateTimeFormFieldFactory()),
    EnumOpmodeFactory(),
    StructureOpmodeFactory(),
  ]
);

class ListFieldOperationModeFactory<T> extends OperationModeFactory<AutoFormFieldFactory> {

  AutoFormFieldFactory mode;

  ListFieldOperationModeFactory(this.mode);

  static OperationModeFactory<AutoFormFieldFactory> get defaults => defaultFormFactories;

  @override
  AutoFormFieldFactory? forConverter(DogConverter converter, DogEngine engine) {
    if (converter is IterableTreeBaseConverterMixin && converter.tree.qualified.typeArgument == T) {
      return mode;
    }
    return null;
  }
}

class EnumOpmodeFactory extends OperationModeFactory<AutoFormFieldFactory> {

  @override
  AutoFormFieldFactory? forConverter(DogConverter converter, DogEngine engine) {
    if (converter is EnumConverter) {
      return EnumDropdownFormFieldFactory(converter);
    }
    return null;
  }
}

class StructureOpmodeFactory extends OperationModeFactory<AutoFormFieldFactory> {

  @override
  AutoFormFieldFactory? forConverter(DogConverter converter, DogEngine engine) {
    if (converter.struct != null) {
      var structure = converter.struct!;
      if (structure.isSynthetic) return null;
      return StructureFormFieldFactory(structure);
    }
    return null;
  }

}

abstract class AutoFormFieldFactory<T> with TypeCaptureMixin<T> implements OperationMode<T> {

  const AutoFormFieldFactory();

  @override
  void initialise(DogEngine engine) {}

  dynamic encode(dynamic value) => value;

  dynamic decode(dynamic value) => value;

  void prepareFormField(BuildContext context, DogsFormField field) {}

  Widget build(BuildContext context, DogsFormField field);
  
  String? Function(dynamic obj) $validator(DogsFormField field, BuildContext context) => (o) =>
      field.buildValidator(context)(decode(o));
}

abstract class DecoratingAutoFormFieldFactory extends AutoFormFieldFactory {
  final AutoFormFieldFactory delegate;

  const DecoratingAutoFormFieldFactory(this.delegate);

  @override
  dynamic encode(dynamic value) => delegate.encode(value);

  @override
  dynamic decode(dynamic value) => delegate.decode(value);

  @override
  Widget build(BuildContext context, DogsFormField field) => delegate.build(context, field);
}

mixin CachedFactoryData<T> on AutoFormFieldFactory {

  void setCachedValue(DogsFormField field, T value) {
    field.factoryData = value;
  }

  T getCachedValue(DogsFormField field) {
    return field.factoryData as T;
  }

}