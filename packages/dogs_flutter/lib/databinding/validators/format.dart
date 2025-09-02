import 'package:dogs_core/dogs_core.dart';

class FormatMessages {
  static final AnnotationMessage invalidNumberFormat = AnnotationMessage(
    id: "invalid-number-format",
    message: "Invalid number format",
    variables: {},
  );

  static final AnnotationMessage fieldHasError = AnnotationMessage(
    id: "invalid-field-format",
    message: "A field has an invalid state",
    variables: {},
  );
}
