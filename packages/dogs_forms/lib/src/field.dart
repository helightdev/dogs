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
import 'package:dogs_core/dogs_validation.dart';
import 'package:dogs_forms/dogs_forms.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

export 'field_decoration.dart';

/// Marks a field as a form field, although this is not necessary for
/// [AutoForm] to work. Allows to specify additional attributes for the field.
class AutoFormField implements StructureMetadata {
  /// The padding to use around the field.
  final EdgeInsets padding;

  /// The decoration to use for the field.
  /// By default, the decoration is inferred from the field [DecorationPreference]
  /// of the fields [AutoFormFieldFactory] and by the current [InputDecorationTheme].
  final InputDecoration? decoration;

  /// The autofill hints to use for the field.
  /// May or may not be used by the [AutoFormFieldFactory].
  final Iterable<String>? autofillHints;

  /// The [Initializer] used to create an initial value for the field.
  final Initializer initializer;

  /// The [Initializer] used to create an initial value for the items of the field.
  /// This is only used by some [AutoFormFieldFactory]s like [ListFieldFactory]s.
  final Initializer itemInitializer;

  /// Specify a custom [FormFieldWrapper] to wrap the field with.
  final FormFieldWrapper wrapper;

  /// Specify a custom [AutoFormFieldFactory] to use for the field.
  final AutoFormFieldFactory? factory;

  /// The flex factor to use for the field when using a [Flex] layout in the
  /// [FormDecorator] (Default: 1). May or may not be used depending on the [FormDecorator].
  ///
  /// **Note: A flex value of -1 will result in the form field not being wrapped with `Flexible`**
  final int flex;

  /// Specify the [FlexFit] to use for the field when using a [Flex] layout in the
  /// [FormDecorator]. May or may not be used depending on the [FormDecorator].
  final FlexFit fit;

  /// Additional [FormFieldValidator]s to use for the field.
  final List<FormFieldValidator> validators;

  /// The [AutovalidateMode] to use for the field.
  final AutovalidateMode autovalidateMode;

  /// The title to use for the field. Will be used as the label text
  /// by [buildInputDecoration] to create a [InputDecoration] if no [decoration]
  /// is specified.
  final String? title;

  /// The translation key to use for the title. Multi language support is
  /// provided by [DogsFormTranslationResolver].
  final String? titleTranslationKey;

  /// The subtitle to use for the field. Will be used as the helper text
  /// by [buildInputDecoration] to create a [InputDecoration] if no [decoration]
  /// is specified.
  final String? subtitle;

  /// The translation key to use for the subtitle. Multi language support is
  /// provided by [DogsFormTranslationResolver].
  final String? subtitleTranslationKey;

  /// The hint text to use for the field. Will be used by [buildInputDecoration]
  /// to create a [InputDecoration] if no [decoration] is specified.
  final String? hint;

  /// The translation key to use for the hint. Multi language support is
  /// provided by [DogsFormTranslationResolver].
  final String? hintTranslationKey;

  /// The prefix widget to use for the field. Will be used by [buildInputDecoration]
  /// to create a [InputDecoration] if no [decoration] is specified.
  final Widget? prefix;

  /// The suffix widget to use for the field. Will be used by [buildInputDecoration]
  /// to create a [InputDecoration] if no [decoration] is specified.
  final Widget? suffix;

  /// The leading widget to use for the field. Will be used by [buildInputDecoration]
  /// to create a [InputDecoration] if no [decoration] is specified. Uses the
  /// [InputDecorationTheme.prefixIcon] by default.
  final Widget? leading;

  /// The trailing widget to use for the field. Will be used by [buildInputDecoration]
  /// to create a [InputDecoration] if no [decoration] is specified. Uses the
  /// [InputDecorationTheme.suffixIcon] by default.
  final Widget? trailing;

  /// Defines the constraints to use for the field.
  final BoxConstraints? constraints;

  /// If this field is a list, this flag can be used to specify if the list is reorderable.
  final bool listReorderable;

  const AutoFormField({
    this.padding = const EdgeInsets.all(8),
    this.decoration,
    this.autofillHints,
    this.factory,
    this.flex = 1,
    this.fit = FlexFit.tight,
    this.constraints,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.validators = const [],
    this.initializer = defaultInitializer,
    this.itemInitializer = defaultInitializer,
    this.wrapper = defaultWrapper,
    this.listReorderable = false,
    this.title,
    this.titleTranslationKey,
    this.subtitle,
    this.subtitleTranslationKey,
    this.hint,
    this.hintTranslationKey,
    this.prefix,
    this.suffix,
    this.leading,
    this.trailing,
  });

  static Widget defaultWrapper(
          DogsFormField field, BuildContext context, Widget child) =>
      child;
}

typedef FormFieldWrapper = Widget Function(
    DogsFormField field, BuildContext context, Widget child);

class DogsFormField {
  final DogStructure parent;
  final DogStructureField delegate;
  DogsFormField(this.parent, this.delegate);

  late DogsForm form;

  late AutoFormFieldFactory factory;

  late StructureValidation<dynamic> structureValidator;

  /// Can be used by the [AutoFormFieldFactory] to store additional data.
  Object? factoryData;
  bool isFirstPass = true;

  void hookEngine() {
    structureValidator = form.engine.modeRegistry.validation
        .forType(parent.typeArgument, form.engine) as StructureValidation;
    factory = _getFactory();
  }

  AutoFormFieldFactory _getFactory() {
    if (formAnnotation?.factory != null) {
      return formAnnotation!.factory!;
    }
    var treeConverter = form.engine.getTreeConverter(delegate.type);
    return form.engine.modeRegistry
        .getConverter<AutoFormFieldFactory>(treeConverter, form.engine);
  }

  late AutoFormField? formAnnotation =
      delegate.annotationsOf<AutoFormField>().firstOrNull;
  late final Initializer initializer =
      formAnnotation?.initializer ?? defaultInitializer;
  late final Initializer itemInitializer =
      formAnnotation?.itemInitializer ?? defaultInitializer;
  late final AutovalidateMode autovalidateMode =
      formAnnotation?.autovalidateMode ?? AutovalidateMode.onUserInteraction;
  late final String title = formAnnotation?.title ?? delegate.name;
  late final String? subtitle = formAnnotation?.subtitle;
  late final String? hint = formAnnotation?.hint;

  // Lazy computed values
  FormFieldValidator buildValidator(BuildContext context) {
    var form = DogsFormProvider.formOf(context)!;
    return FormBuilderValidators.compose([
      ...(formAnnotation?.validators ?? []),
      if (!delegate.optional) relaxedRequired(),
      (c) {
        var annotationResult = structureValidator.annotateFieldValue(
            parent.indexOfFieldName(delegate.name)!, c, form.engine);
        annotationResult = form.translationResolver.translateAnnotation(
            context, annotationResult, Localizations.maybeLocaleOf(context));
        return annotationResult.buildMessages().firstOrNull;
      }
    ]);
  }

  static FormFieldValidator<T> relaxedRequired<T>({
    String? errorText,
  }) {
    return (T? valueCandidate) {
      if (valueCandidate == null ||
          (valueCandidate is String && valueCandidate.trim().isEmpty)) {
        return errorText ?? FormBuilderLocalizations.current.requiredErrorText;
      }
      return null;
    };
  }

  Widget build(BuildContext context) {
    var inner = Padding(
      padding: formAnnotation?.padding ?? const EdgeInsets.all(8.0),
      child: ConstrainedBox(
          constraints: formAnnotation?.constraints ?? const BoxConstraints(),
          child: factory.build(context, this)),
    );
    if (formAnnotation?.wrapper != null) {
      return formAnnotation!.wrapper(this, context, inner);
    } else {
      return inner;
    }
  }

  void expectNonIterable() {
    if (delegate.iterableKind != IterableKind.none) {
      throw Exception("Field ${delegate.name} is iterable, but should not be");
    }
  }

  void expectType(Type type) {
    if (delegate.serial.typeArgument != type) {
      throw Exception(
          "Field ${delegate.name} is of type ${delegate.type.typeArgument}, but should be $type");
    }
  }
}

extension DogFieldExt on DogStructureField {
  double getInclusiveMin() {
    var value = -double.maxFinite;
    var minimum = annotationsOf<Minimum>().firstOrNull;
    if (minimum != null) {
      value = minimum.min!.toDouble();
      if (minimum.minExclusive == true) {
        value += 0.0000000000000001;
      }
    }
    var range = annotationsOf<Range>().firstOrNull;
    if (range != null) {
      value = range.min!.toDouble();
      if (range.minExclusive == true) {
        value += 0.0000000000000001;
      }
    }
    return value;
  }

  int getInclusiveMinInt() {
    var value = (-double.maxFinite).toInt();
    var minimum = annotationsOf<Minimum>().firstOrNull;
    if (minimum != null) {
      value = minimum.min!.toInt();
      if (minimum.minExclusive == true) {
        value += 1;
      }
    }
    var range = annotationsOf<Range>().firstOrNull;
    if (range != null) {
      value = range.min!.toInt();
      if (range.minExclusive == true) {
        value += 1;
      }
    }
    return value.toInt();
  }

  double getMaxInclusive() {
    var value = double.maxFinite;
    var maximum = annotationsOf<Maximum>().firstOrNull;
    if (maximum != null) {
      value = maximum.max!.toDouble();
      if (maximum.maxExclusive == true) {
        value -= 0.0000000000000001;
      }
    }
    var range = annotationsOf<Range>().firstOrNull;
    if (range != null) {
      value = range.max!.toDouble();
      if (range.maxExclusive == true) {
        value -= 0.0000000000000001;
      }
    }
    return value;
  }

  int getMaxInclusiveInt() {
    var value = double.maxFinite.toInt();
    var maximum = annotationsOf<Maximum>().firstOrNull;
    if (maximum != null) {
      value = maximum.max!.toInt();
      if (maximum.maxExclusive == true) {
        value -= 1;
      }
    }
    var range = annotationsOf<Range>().firstOrNull;
    if (range != null) {
      value = range.max!.toInt();
      if (range.maxExclusive == true) {
        value -= 1;
      }
    }
    return value;
  }
}

