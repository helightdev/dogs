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

import 'package:dogs_forms/dogs_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

typedef OptionalElementBuilder = Widget Function(
    BuildContext context, String name, Function(dynamic) callback);

class DogsFormOptional<T> extends StatefulWidget {
  final T? initialValue;
  final OptionalElementBuilder elementFactory;
  final Function(dynamic value) onChanged;
  final (dynamic, bool) Function(dynamic value) encode;
  final dynamic Function(dynamic value, bool isSelected) decode;

  const DogsFormOptional(
      {super.key,
      required this.elementFactory,
      required this.onChanged,
      this.encode = _encode,
      this.decode = _decode,
      this.initialValue});

  static dynamic _decode(dynamic value, bool isSelected) =>
      isSelected ? value : null;
  static (dynamic, bool) _encode(dynamic value) => (value, value != null);

  @override
  State<DogsFormOptional> createState() => DogsFormOptionalState<T>();
}

class DogsFormOptionalState<T> extends State<DogsFormOptional> {
  static const String builderName = "item";
  GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  var isEnabled = false;
  var storedValue;

  // If silent change is true, don't rebuild on parent widget changes.
  // Is set when an individual element field is changed.
  bool silentChange = false;

  bool get canRebuild {
    var result = !silentChange;
    silentChange = false;
    return result;
  }

  void applyManually(dynamic value) {
    var initialValue = widget.encode(widget.initialValue);
    storedValue = initialValue.$1;
    isEnabled = initialValue.$2;
    setState(() {});
  }

  @override
  void initState() {
    var initialValue = widget.encode(widget.initialValue);
    storedValue = initialValue.$1;
    isEnabled = initialValue.$2;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
            value: isEnabled,
            onChanged: (v) => setState(() {
                  silentChange = true;
                  isEnabled = v ?? false;
                  if (!isEnabled) {
                    push();
                  } else if (storedValue != null) {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      silentChange = true;
                      push();
                      setState(() {});
                    });
                  }
                })),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: FormBuilder(
              key: formKey,
              enabled: isEnabled,
              initialValue: {builderName: storedValue},
              child: Builder(builder: (context) {
                return widget.elementFactory(context, builderName, (v) {
                  silentChange = true;
                  storedValue = v;
                  push();
                });
              })),
        ),
      ],
    );
  }

  @override
  void didUpdateWidget(DogsFormOptional<T> oldWidget) {
    if (oldWidget.initialValue != widget.initialValue && canRebuild) {
      var mapped = widget.encode(widget.initialValue);
      setState(() {
        isEnabled = mapped.$2;
        storedValue = mapped.$1;
      });
      if (isEnabled) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          formKey.currentState!.reset();
          push();
          setState(() {});
        });
      }
    } else {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  void push() {
    var decoded = widget.decode(storedValue, isEnabled);
    widget.onChanged(decoded);
  }
}
