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
import 'package:dogs_flutter/databinding/controller.dart';
import 'package:dogs_flutter/databinding/field_controller.dart';
import 'package:dogs_flutter/databinding/opmode.dart';
import 'package:dogs_flutter/databinding/style.dart';
import 'package:dogs_flutter/databinding/validation.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FieldBinding extends StatefulWidget {
  final FieldBindingController? controller;
  final String? field;
  final BindingStyle Function(BindingStyle)? styleBuilder;
  final BindingStyle? style;
  final ValidationTrigger? validationTrigger;
  final AnnotationTransformer? annotationTransformer;
  final FlutterWidgetBinder? binder;

  const FieldBinding({
    super.key,
    this.controller,
    this.field,
    this.styleBuilder,
    this.style,
    this.validationTrigger,
    this.annotationTransformer,
    this.binder,
  });

  @override
  State<FieldBinding> createState() => _FieldBindingState();
}

class _FieldBindingState extends State<FieldBinding> {
  late BindingStyle generatedStyle;
  late List<BindingStyle> fieldStyleData;
  late BindingStyle Function(BindingStyle) styleBuilder;
  FieldBindingController? controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.controller == null) {
      var rootProvider = StructureBindingProvider.of(context);
      final structureController = rootProvider.controller;
      final fieldName = widget.field;
      if (fieldName == null) {
        throw ArgumentError(
          'Field name cannot be null when controller is not provided',
        );
      }
      controller = structureController.field(fieldName);
    } else {
      controller = widget.controller!;
    }

    // Apply validation trigger if provided
    final triggerOverride =
        widget.validationTrigger ??
        StructureBindingProvider.maybeOf(context)?.validationTrigger;
    if (triggerOverride != null) {
      controller!.validationTrigger = triggerOverride;
    }

    generatedStyle = BindingStyle(label: controller!.fieldName);
    fieldStyleData =
        controller!.bindingContext.field
            .annotationsOf<BindingStyleModifier>()
            .map((e) => e.createStyleOverrides())
            .toList();
    styleBuilder =
        widget.styleBuilder ?? (style) => widget.style?.merge(style) ?? style;
  }

  @override
  Widget build(BuildContext context) {
    var parentBindingTheme = BindingTheme.maybeOf(context);
    var structureBindingProvider = StructureBindingProvider.maybeOf(context);
    var currentStyle = parentBindingTheme?.style.asAncestor() ?? BindingStyle();
    currentStyle = generatedStyle.merge(currentStyle);
    for (var e in fieldStyleData) {
      currentStyle = e.merge(currentStyle);
    }
    currentStyle = styleBuilder(currentStyle);

    AnnotationResult annotationTransformer(AnnotationResult result) => result
        .maybeTransform(structureBindingProvider?.annotationTransformer)
        .maybeTransform(parentBindingTheme?.annotationTransformer)
        .maybeTransform(widget.annotationTransformer);

    var currentBinder = controller!.binder;
    var currentController = controller!;

    if (widget.binder != null && structureBindingProvider != null) {
      if (currentBinder != widget.binder) {
        var structureBindingController = structureBindingProvider.controller;
        structureBindingController.rebindField(
          controller!.fieldName,
          widget.binder!,
        );

        currentBinder = widget.binder!;
        currentController = structureBindingController.field(
          controller!.fieldName,
        );
        controller = currentController;
        if (kDebugMode) {
          print("Forcing widget rebind for ${controller!.fieldName}");
        }
      }
    }

    return BindingTheme(
      style: currentStyle,
      annotationTransformer: annotationTransformer,
      child: Builder(
        builder: (context) {
          return currentBinder.buildBindingField(context, currentController);
        },
      ),
    );
  }
}

class BindingTheme extends InheritedWidget {
  final BindingStyle style;
  final AnnotationTransformer? annotationTransformer;

  const BindingTheme({
    super.key,
    required super.child,
    required this.style,
    this.annotationTransformer,
  });

  static BindingTheme of(BuildContext context) {
    final BindingTheme? result =
        context.dependOnInheritedWidgetOfExactType<BindingTheme>();
    assert(result != null, 'No BindingContext found in context');
    return result!;
  }

  static BindingTheme? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BindingTheme>();
  }

  String? toErrorText(AnnotationResult result) {
    if (!result.hasErrors) return null;
    return result.maybeTransform(annotationTransformer).errorText;
  }

  @override
  bool updateShouldNotify(BindingTheme old) {
    return style != old.style;
  }
}
