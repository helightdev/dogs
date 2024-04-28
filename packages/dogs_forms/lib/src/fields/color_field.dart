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
import 'package:dogs_forms/src/fields/list_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_extra_fields/form_builder_extra_fields.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class ColorFormFieldUtils {

  static String encodeColor(Color color) {
    return '#${color.value.toRadixString(16)}';
  }

  static Color decodeColor(String color) {
    if (color.length == 7 || color.length == 9) {
      color = color.substring(1);
    }
    if (color.length == 6) {
      color = 'FF$color';
    }
    return Color(int.parse(color, radix: 16));
  }

}

/// A [AutoFormFieldFactory] that creates [FormBuilderColorPickerField]s.
class ColorFormFieldFactory extends AutoFormFieldFactory<String> {

  const ColorFormFieldFactory();

  @override
  Widget build(BuildContext context, DogsFormField field) {
    return FormBuilderColorPickerField(
      name: field.delegate.name,
      decoration: field.buildInputDecoration(context, const DecorationPreference(
        contentPadding: EdgeInsets.zero,
      )),
      validator: $validator(field, context),
      autovalidateMode: field.autovalidateMode,
    );
  }

  @override
  dynamic decode(dynamic value) => value == null ? null : ColorFormFieldUtils.encodeColor(value);

  @override
  dynamic encode(dynamic value) => value == null ? null : ColorFormFieldUtils.decodeColor(value);
}
