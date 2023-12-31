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

import 'dart:convert';

import 'package:code_editor/code_editor.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_forms/dogs_forms.dart';
import 'package:flutter/material.dart';

import 'package:flutter_highlight/themes/atom-one-dark.dart';

class FormPrintWrapper<T> extends StatefulWidget {
  final T exampleValue;
  final String modelCode;
  final Map<Symbol, Object?> attributes;

  const FormPrintWrapper(
      {Key? key,
      required this.exampleValue,
      this.modelCode = "",
      this.attributes = const {}})
      : super(key: key);

  @override
  State<FormPrintWrapper<T>> createState() => _FormPrintWrapperState<T>();
}

bool presetExamples = true;

class _FormPrintWrapperState<T> extends State<FormPrintWrapper<T>> {
  DogsFormRef<T> ref = DogsFormRef();
  T? initialValue;

  @override
  void initState() {
    if(presetExamples) initialValue = widget.exampleValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Row(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: DogsForm<T>(
                reference: ref,
                initialValue: initialValue,
                attributes: widget.attributes,
              ),
            ),
          ],
        ),
        Row(
          children: [
            TextButton(
              onPressed: setExample,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.drive_folder_upload),
                  SizedBox(width: 4),
                  Text("Example Value")
                ],
              ),
            ),
            TextButton(
                onPressed: () => showValue(context), child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.code),
                SizedBox(width: 4),
                Text("Value & Code")
              ],
            )),
          ],
        )
      ],
    );
  }

  void showValue(BuildContext context) {
    var value = ref.read();
    var jsonEncoder = const JsonEncoder.withIndent("  ");
    var model = EditorModel(
        styleOptions: EditorModelStyleOptions(
          theme: atomOneDarkTheme,
          editorColor: Color(0xff282c34),
        ),
        files: [
          FileEditor(
              name: "data.json",
              language: "json",
              code: value == null
                  ? "null"
                  : jsonEncoder.convert(dogs.convertObjectToNative(value, T)),
              readonly: true),
          FileEditor(
              name: "model.dart",
              language: "dart",
              code: widget.modelCode,
              readonly: true)
        ]);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Value"),
              content: SizedBox(
                  height: 512,
                  width: 512 + 128,
                  child: CodeEditor(model: model)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Close"),
                )
              ],
            ));
  }

  void setExample() {
    setState(() {
      ref.set(widget.exampleValue);
    });
  }
}
