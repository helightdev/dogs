import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_flutter/databinding/field_controller.dart';
import 'package:dogs_flutter/databinding/style.dart';
import 'package:flutter/material.dart';

class MaterialBindingStyle extends BindingStyleExtension<MaterialBindingStyle>
    implements StructureMetadata, BindingStyleModifier {
  final InputDecorationTheme? inputTheme;
  final ButtonStyle? buttonStyle;

  const MaterialBindingStyle({this.inputTheme, this.buttonStyle});

  const MaterialBindingStyle.inputTheme(this.inputTheme) : buttonStyle = null;

  const MaterialBindingStyle.buttonStyle(this.buttonStyle) : inputTheme = null;

  @override
  MaterialBindingStyle merge(MaterialBindingStyle? other) {
    if (other == null) return this;
    return MaterialBindingStyle(
      inputTheme: inputTheme?.merge(other.inputTheme) ?? other.inputTheme,
      buttonStyle: buttonStyle?.merge(other.buttonStyle) ?? other.buttonStyle,
    );
  }

  @override
  BindingStyle createStyleOverrides() => BindingStyle(extensions: [this]);
}

extension BindingStyleDataMaterialExtension on BindingStyle {
  InputDecoration buildMaterialDecoration(
    BuildContext context,
    FieldBindingController fbc, {
    bool includeLabel = true,
    bool includeHelper = true,
    bool includeHint = true,
  }) {
    final currentTheme = Theme.of(context);
    final theme =
        getExtension<MaterialBindingStyle>() ?? MaterialBindingStyle();
    final inputTheme =
        theme.inputTheme?.merge(
          InputDecorationTheme(data: currentTheme.inputDecorationTheme),
        ) ??
        currentTheme.inputDecorationTheme;
    final decoration = InputDecoration()
        .applyDefaults(inputTheme)
        .copyWith(
          labelText: includeLabel ? label : null,
          hintText: includeHint ? hint : null,
          helperText: includeHelper ? helper : null,
          prefix: prefix,
          suffix: suffix,
        );
    return decoration;
  }

  Widget? buildMaterialLabelText(
    BuildContext context, {
    Object? labelOverride = #none,
    bool isError = false,
  }) {
    var label = this.label;
    if (labelOverride != #none) {
      label = labelOverride as String?;
    }

    if (label == null) return null;
    final currentTheme = Theme.of(context);
    final theme =
        getExtension<MaterialBindingStyle>() ?? MaterialBindingStyle();
    final inputTheme =
        theme.inputTheme?.merge(
          InputDecorationTheme(data: currentTheme.inputDecorationTheme),
        ) ??
        InputDecorationTheme(data: currentTheme.inputDecorationTheme);
    var style = inputTheme.labelStyle;

    if (isError) {
      style =
          inputTheme.errorStyle ??
          TextStyle(color: currentTheme.colorScheme.error);
    }

    return Text(label, style: style);
  }

  Widget wrapHeader(
    Widget widget,
    BuildContext context, {
    Object? labelOverride = #none,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: labelOverride == #none ? label : labelOverride.toString(),
          errorText: errorText,
          helperText: helper
        ),
        child: widget,
      ),
    );
  }

  Widget wrapHeaderLabelSection(
    Widget widget,
    BuildContext context, {
    Object? labelOverride = #none,
    bool isError = false,
  }) {
    var label = buildMaterialLabelText(
      context,
      labelOverride: labelOverride,
      isError: isError,
    );
    if (label == null) return widget;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Padding(padding: const EdgeInsets.only(top: 8.0, bottom: 2.0), child: label,),
        InputDecorator(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            error: isError ? SizedBox(width: 0, height: 0) : null,
            labelText: this.label,
          ),
          child: widget,
        ),
      ],
    );
  }

  Widget? buildMaterialHelperOrErrorText(BuildContext context, String? error) {
    if (error != null) {
      return buildMaterialErrorText(context, error);
    }
    return buildMaterialHelperText(context);
  }

  Widget? buildMaterialHelperText(BuildContext context) {
    if (helper == null) return null;
    final currentTheme = Theme.of(context);
    final theme =
        getExtension<MaterialBindingStyle>() ?? MaterialBindingStyle();
    final inputTheme =
        theme.inputTheme?.merge(
          InputDecorationTheme(data: currentTheme.inputDecorationTheme),
        ) ??
        InputDecorationTheme(data: currentTheme.inputDecorationTheme);
    return Text(helper!, style: inputTheme.helperStyle);
  }

  Widget? buildMaterialErrorText(BuildContext context, String? error) {
    if (error == null) return null;
    final currentTheme = Theme.of(context);
    final theme =
        getExtension<MaterialBindingStyle>() ?? MaterialBindingStyle();
    final inputTheme =
        theme.inputTheme?.merge(
          InputDecorationTheme(data: currentTheme.inputDecorationTheme),
        ) ??
        InputDecorationTheme(data: currentTheme.inputDecorationTheme);

    return DefaultTextStyle(
      style:
          inputTheme.errorStyle ??
          TextStyle(color: currentTheme.colorScheme.error),
      child: Text(error),
    );
  }

  ButtonStyle? getMaterialButtonStyle() {
    return getExtension<MaterialBindingStyle>()?.buttonStyle;
  }
}
