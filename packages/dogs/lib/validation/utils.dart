import "package:dogs_core/dogs_core.dart";

SchemaType itemSchemaTarget(SchemaField field) {
  final type = field.type;
  if (type is SchemaArray) {
    return type.items;
  }
  return type;
}