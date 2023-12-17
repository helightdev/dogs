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

/// Class used by [AutoFormFieldFactory]s to describe how they want their
/// [InputDecoration] to look like preferably. Currently only influences the
/// border and the content padding.
class DecorationPreference {
  final BorderPreference borderPreference;
  final EdgeInsets? contentPadding;

  const DecorationPreference(
      {this.borderPreference = BorderPreference.normal, this.contentPadding});

  /// A [DecorationPreference] that prefers a borderless style.
  static const DecorationPreference borderless = DecorationPreference(
      borderPreference: BorderPreference.borderless,
      contentPadding: EdgeInsets.zero);

  /// A [DecorationPreference] that prefers an outline border.
  static const DecorationPreference outline =
      DecorationPreference(borderPreference: BorderPreference.outline);

  /// A [DecorationPreference] that prefers the default field border.
  static const DecorationPreference normal =
      DecorationPreference(borderPreference: BorderPreference.normal);

  /// A [DecorationPreference] that prefers a style that is suitable for
  /// a container.
  static const DecorationPreference container =
      DecorationPreference(borderPreference: BorderPreference.outline);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecorationPreference &&
          runtimeType == other.runtimeType &&
          borderPreference == other.borderPreference &&
          contentPadding == other.contentPadding;

  @override
  int get hashCode => borderPreference.hashCode ^ contentPadding.hashCode;
}

enum BorderPreference {
  normal,
  outline,
  borderless,
}

extension FieldDecorationExtension on DogsFormField {

  /// Builds a [InputDecoration] using the [DecorationPreference] of this field
  /// for the [DogsForm] of the [context].
  InputDecoration buildInputDecoration(
      BuildContext context, DecorationPreference pref) {
    var form = DogsFormProvider.formOf(context)!;

    var themeDate = Theme.of(context);
    var inputTheme = themeDate.inputDecorationTheme;
    var decoration = InputDecoration(
      border: _defaultBorder(
          inputTheme.border ?? const UnderlineInputBorder(), pref),
      focusedBorder: _defaultBorder(inputTheme.focusedBorder, pref),
      enabledBorder: _defaultBorder(inputTheme.enabledBorder, pref),
      errorBorder: _defaultBorder(inputTheme.errorBorder, pref),
      disabledBorder: _defaultBorder(inputTheme.disabledBorder, pref),
      contentPadding: pref.contentPadding,
      prefix: formAnnotation?.prefix,
      suffix: formAnnotation?.suffix,
      prefixIcon: formAnnotation?.leading,
      suffixIcon: formAnnotation?.trailing,
    );
    if (form.preferenceDecorationMutator != null) {
      decoration = form.preferenceDecorationMutator!(decoration, pref) ??
          decoration;
    }
    decoration = formAnnotation?.decoration ?? decoration;
    // Apply data transformation
    var locale = Localizations.maybeLocaleOf(context);
    decoration = _applyTitle(decoration, form, context, locale);
    decoration = _applySubtitle(form, context, locale, decoration);
    decoration = _applyHint(form, context, locale, decoration);
    return decoration;
  }

  InputBorder? _defaultBorder(
          InputBorder? border, DecorationPreference pref) =>
      border == null
          ? null
          : switch (pref.borderPreference) {
              BorderPreference.normal =>
                UnderlineInputBorder(borderSide: border.borderSide),
              BorderPreference.outline =>
                OutlineInputBorder(borderSide: border.borderSide),
              BorderPreference.borderless => InputBorder.none,
            };

  InputDecoration _applyTitle(InputDecoration decoration,
      DogsForm<dynamic> form, BuildContext context, Locale? locale) {
    if (decoration.labelText == null && decoration.label == null) {
      if (formAnnotation?.titleTranslationKey != null) {
        var translated = form.translationResolver
            .translate(context, formAnnotation!.titleTranslationKey!, locale);
        decoration = decoration.copyWith(helperText: translated);
      } else {
        decoration = decoration.copyWith(labelText: capitalizeString(title));
      }
    }
    return decoration;
  }

  InputDecoration _applySubtitle(DogsForm<dynamic> form, BuildContext context,
      Locale? locale, InputDecoration decoration) {
    if (subtitle != null) {
      if (formAnnotation?.subtitleTranslationKey != null) {
        var translated = form.translationResolver.translate(
            context, formAnnotation!.subtitleTranslationKey!, locale);
        decoration = decoration.copyWith(helperText: translated);
      } else {
        decoration = decoration.copyWith(helperText: subtitle);
      }
    }
    return decoration;
  }

  InputDecoration _applyHint(DogsForm<dynamic> form, BuildContext context,
      Locale? locale, InputDecoration decoration) {
    if (hint != null) {
      if (formAnnotation?.hintTranslationKey != null) {
        var translated = form.translationResolver.translate(
            context, formAnnotation!.hintTranslationKey!, locale);
        decoration = decoration.copyWith(hintText: translated);
      } else {
        decoration = decoration.copyWith(hintText: hint);
      }
    }
    return decoration;
  }

  /// Builds a [InputDecoration] using [buildInputDecoration] but only includes
  /// the border information.
  InputDecoration buildBorderDecoration(
      BuildContext context, DecorationPreference preference) {
    var decoration = buildInputDecoration(context, preference);
    return InputDecoration(
      border: decoration.border,
      focusedBorder: decoration.focusedBorder,
      enabledBorder: decoration.enabledBorder,
      errorBorder: decoration.errorBorder,
      disabledBorder: decoration.disabledBorder,
      contentPadding: decoration.contentPadding,
    );
  }
}
