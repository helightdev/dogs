import 'package:dogs_core/dogs_core.dart';

class DatabindRequiredGuard extends FieldValidator
    implements StructureMetadata {
  const DatabindRequiredGuard();

  static const String messageId = "databind-required";
  static final AnnotationMessage sharedMessage = AnnotationMessage(
    id: messageId,
    message: "Field is required",
    variables: {},
  );

  @override
  bool validate(cached, value, DogEngine engine) {
    return value != null;
  }

  @override
  AnnotationResult annotate(cached, value, DogEngine engine) {
    final isValid = validate(cached, value, engine);
    if (isValid) return AnnotationResult.empty();
    return AnnotationResult(
      messages: [
        AnnotationMessage(id: messageId, message: "Field is required"),
      ],
    );
  }
}
