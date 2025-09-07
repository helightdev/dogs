import "package:dogs_core/dogs_core.dart";

/// Returns the schema type of the items if the field is an array, otherwise the field type itself.
SchemaType itemSchemaTarget(SchemaField field) {
  final type = field.type;
  if (type is SchemaArray) {
    return type.items;
  }
  return type;
}
