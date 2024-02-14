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
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:uuid/uuid.dart';

typedef ListElementBuilder = Widget Function(
    BuildContext context, String name, Function(dynamic) callback);

/// An complimentary [FormBuilderField] for lists intended to be used inside
/// [AutoFormFieldFactory]s to create [FormBuilderField]s for lists.
class DogsFormList<T> extends StatefulWidget {
  /// The initial value of the list.
  final List<T>? initialValue;
  /// The callback that is called when the value of the list changes.
  final Function(List<T>?) onChanged;

  /// The [ListElementBuilder] that is used to create the fields of list elements.
  final ListElementBuilder elementFactory;

  /// The [Initializer] that is selected by the implementation.
  final Initializer itemInit;

  /// The [Initializer] that is used as the default initializer for the items of the list.
  final Initializer defaultInit;

  /// The encoder that is used to encode the values of the list.
  final dynamic Function(dynamic) encoder;

  /// The decoder that is used to decode the values of the list.
  final dynamic Function(dynamic) decoder;

  /// Whether the list is reorderable.
  final bool reorderable;
  final Function(BuildContext context, Function(dynamic) callback)? addItem;

  static dynamic keepValue(value) => value;

  // Private so you don't accidentally use it. You are meant
  // to use the [DogsFormList.field] constructor if you don't
  // know what you are doing. If you do know what you are doing,
  // use the [DogsFormList.raw] constructor.
  const DogsFormList._(
      {super.key,
      required this.initialValue,
      required this.onChanged,
      required this.elementFactory,
      this.itemInit = defaultInitializer,
      this.defaultInit = nullInitializer,
      this.encoder = keepValue,
      this.decoder = keepValue,
      this.reorderable = false,
      this.addItem});

  /// Creates a [DogsFormList] from a [DogsFormField].
  const DogsFormList.raw(
      {super.key,
      required this.initialValue,
      required this.onChanged,
      required this.elementFactory,
      this.itemInit = defaultInitializer,
      this.defaultInit = nullInitializer,
      this.encoder = keepValue,
      this.decoder = keepValue,
      this.reorderable = false,
      this.addItem});

  /// Creates a [DogsFormList] from a [DogsFormField].
  /// This automatically handles decoration, validation and error messages.
  /// If you want a more fine-grained control over the [DogsFormList], use the
  /// [DogsFormList.raw] constructor.
  static Widget field<T>(DogsFormField field,
      {required ListElementBuilder elementFactory,
      Initializer defaultInit = nullInitializer,
      dynamic Function(dynamic) encoder = keepValue,
      dynamic Function(dynamic) decoder = keepValue,
      Function(BuildContext context, Function(dynamic) callback)? addItem}) {
    var isReorderable = field.formAnnotation?.listReorderable ?? false;
    return Builder(builder: (context) {
      var locale = Localizations.maybeLocaleOf(context);
      var translationResolver =
          DogsFormProvider.formOf(context)!.translationResolver;
      return FormBuilderField<List<T>>(
          validator:
              FormBuilderValidators.compose([field.buildValidator(context)]),
          autovalidateMode: field.autovalidateMode,
          name: field.delegate.name,
          builder: (fieldState) => InputDecorator(
              decoration: field
                  .buildInputDecoration(context, DecorationPreference.container)
                  .copyWith(
                      errorText: switch (fieldState.errorText) {
                    null => null,
                    String() => translationResolver.translate(
                            context, "invalid-list", locale) ??
                        "This list contains invalid items."
                  }),
              child: DogsFormList<T>._(
                initialValue: fieldState.value,
                itemInit: field.itemInitializer,
                onChanged: (v) {
                  fieldState.didChange(v);
                },
                encoder: (v) => v ?? "",
                decoder: (v) => v ?? "",
                defaultInit: defaultInit,
                elementFactory: elementFactory,
                reorderable: isReorderable,
                addItem: addItem,
              )));
    });
  }

  @override
  State<DogsFormList> createState() => _DogsFormListState<T>();
}

class _DogsFormListState<T> extends State<DogsFormList<T>> {
  GlobalKey<FormBuilderState> formKey = GlobalKey();
  List<String> children = [];
  Map<String, dynamic> initialData = {};

  Initializer get itemInitializer => switch (widget.itemInit) {
        DefaultInitializer() => widget.defaultInit,
        _ => widget.itemInit
      };

  // If silent change is true, don't rebuild on parent widget changes.
  // Is set when an individual element field is changed.
  bool silentChange = false;
  bool get canRebuild {
    var result = !silentChange;
    silentChange = false;
    return result;
  }

  @override
  void initState() {
    if (widget.initialValue != null) {
      children = widget.initialValue!.map((e) => const Uuid().v4()).toList();
      for (var i = 0; i < children.length; i++) {
        this.initialData["item-${children[i]}"] =
            widget.encoder(widget.initialValue![i]);
      }
    }

    if (widget.initialValue == null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        widget.onChanged([]);
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
        key: formKey,
        initialValue: initialData,
        child: switch (widget.reorderable) {
          false => Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: _buildItem,
                  itemCount: children.length,
                ),
                _buildAddButton(context),
              ],
            ),
          true => ReorderableListView.builder(
              shrinkWrap: true,
              buildDefaultDragHandles: false,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  var id = children.removeAt(oldIndex);
                  children.insert(newIndex, id);
                  widget.onChanged(buildList());
                });
              },
              itemBuilder: _buildItem,
              itemCount: children.length,
              footer: _buildAddButton(context),
            ),
        });
  }

  IconButton _buildAddButton(BuildContext context) {
    return IconButton(
        onPressed: () {
          callback(dynamic value) {
            var id = const Uuid().v4();
            children.add(id);
            setState(() {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                formKey.currentState!.fields["item-$id"]!.didChange(value);
                widget.onChanged(buildList());
              });
            });
          }

          if (widget.addItem != null) {
            widget.addItem!(context, callback);
          } else {
            callback(itemInitializer());
          }
        },
        icon: const Icon(Icons.add));
  }

  Widget _buildItem(BuildContext context, int i) {
    return Padding(
      key: ValueKey(children[i]),
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
              child: widget.elementFactory(context, "item-${children[i]}",
                  (newValue) {
            silentChange = true;
            // This fixes a bug where the value is not updated for the first
            // time the field is changed. This shouldn't have any side effects.
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              silentChange = true;
              widget.onChanged(buildList());
            });
          })),
          IconButton(
              onPressed: () => setState(() {
                    var id = children[i];
                    children.removeAt(i);
                    formKey.currentState!.fields["item-$id"]!.setValue(null);
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                      widget.onChanged(buildList());
                    });
                  }),
              icon: const Icon(Icons.delete)),
          if (widget.reorderable)
            ReorderableDragStartListener(
                index: i, child: const Icon(Icons.drag_handle))
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(DogsFormList<T> oldWidget) {
    if (oldWidget.initialValue != widget.initialValue && canRebuild) {
      children = widget.initialValue!.map((e) => const Uuid().v4()).toList();
      for (var i = 0; i < children.length; i++) {
        if (widget.initialValue != null) {
          this.initialData["item-${children[i]}"] =
              widget.encoder(widget.initialValue![i]);
        } else {
          this.initialData["item-${children[i]}"] =
              widget.encoder(itemInitializer());
        }
      }
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  List<T>? buildList() {
    return formKey.currentState!.isValid
        ? TypeToken<T>().castList(children
            .map((e) =>
                widget.decoder(formKey.currentState!.instantValue["item-$e"]))
            .toList())
        : null;
  }
}
