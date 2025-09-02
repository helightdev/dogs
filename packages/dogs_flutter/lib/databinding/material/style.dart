import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_flutter/databinding/field_controller.dart';
import 'package:dogs_flutter/databinding/style.dart';
import 'package:flutter/material.dart';

class MaterialBindingStyle extends BindingStyleExtension<MaterialBindingStyle>
    implements StructureMetadata, BindingStyleModifier {
  final InputDecorationThemeData? inputTheme;
  final InputDecorationThemeData? sectionTheme;
  final ButtonStyle? buttonStyle;

  const MaterialBindingStyle({
    this.inputTheme,
    this.buttonStyle,
    this.sectionTheme,
  });

  const MaterialBindingStyle.inputTheme(this.inputTheme)
    : buttonStyle = null,
      sectionTheme = null;

  const MaterialBindingStyle.buttonStyle(this.buttonStyle)
    : inputTheme = null,
      sectionTheme = null;

  const MaterialBindingStyle.sectionTheme(this.sectionTheme)
    : inputTheme = null,
      buttonStyle = null;

  @override
  MaterialBindingStyle merge(MaterialBindingStyle? other) {
    if (other == null) return this;
    return MaterialBindingStyle(
      inputTheme: inputTheme?.merge(other.inputTheme) ?? other.inputTheme,
      buttonStyle: buttonStyle?.merge(other.buttonStyle) ?? other.buttonStyle,
      sectionTheme:
          sectionTheme?.merge(other.sectionTheme) ?? other.sectionTheme,
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
    var (inputTheme, style, theme) = resolveTheme(context);
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

  Widget buildInputSection(
    Widget widget,
    BuildContext context, {
    Object? labelOverride = #none,
    String? errorText,
  }) {
    var (inputTheme, style, theme) = resolveTheme(context);
    if (style.sectionTheme != null) {
      inputTheme = style.sectionTheme!.merge(inputTheme);
    } else {
      inputTheme = inputTheme.copyWith(border: OutlineInputBorder());
    }
    var decoration = InputDecoration()
        .applyDefaults(inputTheme)
        .copyWith(
          labelText: labelOverride == #none ? label : labelOverride.toString(),
          errorText: errorText,
          helperText: helper,
          prefix: prefix,
          suffix: suffix,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(decoration: decoration, child: widget),
    );
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
    final (inputTheme, bindingStyle, theme) = resolveTheme(context);
    var style = inputTheme.labelStyle;
    if (isError) {
      style =
          inputTheme.errorStyle ?? TextStyle(color: theme.colorScheme.error);
    }
    return Text(label, style: style);
  }

  Widget? buildMaterialHelperOrErrorText(BuildContext context, String? error) {
    if (error != null) {
      return buildMaterialErrorText(context, error);
    }
    return buildMaterialHelperText(context);
  }

  Widget? buildMaterialHelperText(BuildContext context) {
    if (helper == null) return null;
    final (inputTheme, style, theme) = resolveTheme(context);
    return Text(helper!, style: inputTheme.helperStyle);
  }

  Widget? buildMaterialErrorText(BuildContext context, String? error) {
    if (error == null) return null;
    final (inputTheme, style, theme) = resolveTheme(context);
    return DefaultTextStyle(
      style: inputTheme.errorStyle ?? TextStyle(color: theme.colorScheme.error),
      child: Text(error),
    );
  }

  ButtonStyle? getMaterialButtonStyle() {
    return getExtension<MaterialBindingStyle>()?.buttonStyle;
  }

  (InputDecorationThemeData, MaterialBindingStyle, ThemeData) resolveTheme(
    BuildContext context,
  ) {
    final currentTheme = Theme.of(context);
    final style =
        getExtension<MaterialBindingStyle>() ?? MaterialBindingStyle();
    var inputTheme = currentTheme.inputDecorationTheme;
    if (style.inputTheme != null) {
      inputTheme = style.inputTheme!.merge(inputTheme);
    }
    return (inputTheme, style, currentTheme);
  }
}
