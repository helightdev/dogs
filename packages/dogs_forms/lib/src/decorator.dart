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

import 'dart:collection';

import 'package:dogs_forms/dogs_forms.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

abstract interface class FormDecorator<T> {
  const FormDecorator();

  Widget run(BuildContext context, DogsForm<T> form);

}

/// A [FormDecorator] that layouts a form by wrapping it in a [Column].
abstract class FormColumnDecorator<T> implements FormDecorator<T> {

  const FormColumnDecorator();

  /// Performs the decoration run.
  /// Implementations can call [super] to perform the default decoration for
  /// all not handled fields.
  void decorate(BuildContext context, FormStackConfigurator configurator) {
    while (configurator.remainingFields.isNotEmpty) {
      var field = configurator.popFirstField()!;
      configurator.push(field.build(context));
    }
  }

  @override
  Widget run(BuildContext context, DogsForm<T> form) {
    var remainingFields = LinkedHashMap<String, DogsFormField>.fromIterable(
        form.fields,
        key: (e) => e.delegate.name,
        value: (e) => e);
    var configurator = FormStackConfigurator(remainingFields, context);
    decorate(context, configurator);
    return Column(
      mainAxisAlignment: form.formAnnotation.mainAxisAlignment,
      crossAxisAlignment: form.formAnnotation.crossAxisAlignment,
      children: configurator.widgetStack,
    );
  }

}

/// Builder for a [FormColumnDecorator].
class FormStackConfigurator {
  final LinkedHashMap<String, DogsFormField> remainingFields;
  final BuildContext context;

  FormStackConfigurator(this.remainingFields, this.context);

  final Map<String, Widget> _overrides = {};

  /// The stack of widgets that will be used to build the column.
  List<Widget> widgetStack = [];

  /// Pops the next field from the [remainingFields].
  DogsFormField? popFirstField() {
    return remainingFields.remove(remainingFields.keys.first);
  }

  /// Pops the field with the given [name] from the [remainingFields] and returns it.
  DogsFormField? popNamed(String name) {
    return remainingFields.remove(name);
  }

  /// Adds an override for [field].
  void addOverride(String field, Widget widget) {
    _overrides[field] = widget;
  }

  /// Pops [field] from the [remainingFields] and pushes it to the [widgetStack].
  void field(String field) {
    var popped = remainingFields.remove(field);
    if (popped != null) {
      push(buildField(context, popped));
    }
  }

  /// Pops all [fields] from the [remainingFields] and pushes them to the
  /// [widgetStack], wrapped in a [Row].
  void row(
    List<String> fields, {
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    var items = fields.map((e) => remainingFields.remove(e)!);
    var childWidgets =
        items.map((e) => buildFlexibleField(context, e)).toList();
    push(Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: childWidgets));
  }

  /// Pops all [fields] from the [remainingFields] and pushes them to the
  /// [widgetStack], wrapped in a [Wrap].
  void wrap(List<String> fields,
      {WrapAlignment alignment = WrapAlignment.start,
      WrapAlignment runAlignment = WrapAlignment.start,
      WrapCrossAlignment wrapCrossAlignment = WrapCrossAlignment.start,
      Axis direction = Axis.horizontal,
      double spacing = 8,
      double runSpacing = 8}) {
    var items = fields.map((e) => remainingFields.remove(e)!);
    var childWidgets = items.map((e) => buildField(context, e)).toList();
    push(Wrap(
      alignment: alignment,
      crossAxisAlignment: wrapCrossAlignment,
      runAlignment: runAlignment,
      spacing: spacing,
      runSpacing: runSpacing,
      direction: direction,
      children: childWidgets,
    ));
  }

  /// Pushes [widget] to the [widgetStack].
  void push(Widget widget) {
    widgetStack.add(widget);
  }

  /// Builds the [field] and returns the resulting widget.
  Widget buildField(BuildContext context, DogsFormField field) {
    if (_overrides.containsKey(field.delegate.name)) {
      return _overrides[field.delegate.name]!;
    } else {
      return field.build(context);
    }
  }

  /// Builds the [field] and returns the resulting widget in a
  /// [Flexible] configuration.
  Widget buildFlexibleField(BuildContext context, DogsFormField field) {
    if ((field.formAnnotation?.flex ?? 1) == -1) {
      return field.build(context);
    } else {
      return Flexible(
        flex: field.formAnnotation?.flex ?? 1,
        fit: field.formAnnotation?.fit ?? FlexFit.tight,
        child: buildField(context, field),
      );
    }
  }
}

/// Default [FormDecorator] that uses a [FormColumnDecorator].
final class DefaultFormDecorator extends FormColumnDecorator {
  const DefaultFormDecorator();
}
