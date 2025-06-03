import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_flutter/databinding/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A style extension for TextField properties that are commonly modified.
/// This extension is not tied to Material Design and can be used with any theme.
class TextFieldStyle extends BindingStyleExtension<TextFieldStyle>
    implements StructureMetadata, BindingStyleModifier {
  /// Whether to hide the text being edited (like for passwords).
  final bool? obscureText;

  /// The type of keyboard to use for editing the text.
  final TextInputType? keyboardType;

  /// The maximum number of lines for the text to span.
  final int? maxLines;

  /// The minimum number of lines for the text to span.
  final int? minLines;

  /// The maximum number of characters (Unicode scalar values) to allow in the text field.
  final int? maxLength;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The style to use for the text being edited.
  final TextStyle? textStyle;

  /// The capitalization behavior for the keyboard.
  final TextCapitalization? textCapitalization;

  /// Whether the text field is enabled.
  final bool? enabled;

  /// Whether the text field is read-only.
  final bool? readOnly;

  /// Whether the text field should be focused initially.
  final bool? autofocus;

  /// Optional input validation and formatting.
  final List<TextInputFormatter>? inputFormatters;

  const TextFieldStyle({
    this.obscureText,
    this.keyboardType,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.textAlign,
    this.textStyle,
    this.textCapitalization,
    this.enabled,
    this.readOnly,
    this.autofocus,
    this.inputFormatters,
  });

  @override
  TextFieldStyle merge(TextFieldStyle? other) {
    if (other == null) return this;
    return TextFieldStyle(
      obscureText: other.obscureText ?? obscureText,
      keyboardType: other.keyboardType ?? keyboardType,
      maxLines: other.maxLines ?? maxLines,
      minLines: other.minLines ?? minLines,
      maxLength: other.maxLength ?? maxLength,
      textAlign: other.textAlign ?? textAlign,
      textStyle: other.textStyle ?? textStyle,
      textCapitalization: other.textCapitalization ?? textCapitalization,
      enabled: other.enabled ?? enabled,
      readOnly: other.readOnly ?? readOnly,
      autofocus: other.autofocus ?? autofocus,
      inputFormatters: other.inputFormatters ?? inputFormatters,
    );
  }

  @override
  BindingStyle createStyleOverrides() => BindingStyle(extensions: [this]);
}

/// Extension methods for applying TextField properties from TextFieldStyle
extension TextFieldStyleExtension on BindingStyle {
  /// Gets the TextFieldStyle extension or returns a default one if not found
  TextFieldStyle getTextFieldStyle() {
    return getExtension<TextFieldStyle>() ?? const TextFieldStyle();
  }
}
