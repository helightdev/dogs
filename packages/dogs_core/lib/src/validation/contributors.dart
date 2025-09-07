import "package:dogs_core/dogs_core.dart";
import "package:dogs_core/dogs_validation.dart";

SchemaType _extractItemSchemaType(SchemaType type) => switch (type) {
      SchemaArray() => type.items,
      _ => type,
    };

/// A contributor that adds standard collection validation annotations
class CollectionValidationContributor extends SchemaStructureMaterializationContributor {
  @override
  DogStructureField transformField(DogStructureField field, SchemaType schema) {
    final minItems = schema[SchemaProperties.minItems];
    final maxItems = schema[SchemaProperties.maxItems];
    if (minItems != null || maxItems != null) {
      field = field.copy(annotations: [
        ...field.annotations,
        SizeRange(
          min: minItems as int?,
          max: maxItems as int?,
        )
      ]);
    }
    return field;
  }
}

/// A contributor that adds standard string validation annotations
class StringValidationContributor extends SchemaStructureMaterializationContributor {
  @override
  DogStructureField transformField(DogStructureField field, SchemaType schema) {
    final target = _extractItemSchemaType(schema);
    final minLength = target[SchemaProperties.minLength];
    final maxLength = target[SchemaProperties.maxLength];
    if (minLength != null || maxLength != null) {
      field = field.copy(annotations: [
        ...field.annotations,
        LengthRange(
          min: minLength as int?,
          max: maxLength as int?,
        )
      ]);
    }

    final pattern = target[SchemaProperties.pattern];
    if (pattern != null && pattern is String) {
      field = field.copy(annotations: [
        ...field.annotations,
        Regex(pattern),
      ]);
    }

    return field;
  }
}

/// A contributor that adds standard number validation annotations
class NumberValidationContributor extends SchemaStructureMaterializationContributor {
  @override
  DogStructureField transformField(DogStructureField field, SchemaType schema) {
    final target = _extractItemSchemaType(schema);
    final min = target[SchemaProperties.minimum];
    final max = target[SchemaProperties.maximum];
    if (min != null || max != null) {
      field = field.copy(annotations: [
        ...field.annotations,
        Range(
          min: min as num?,
          max: max as num?,
          minExclusive: target[SchemaProperties.exclusiveMinimum] ?? false,
          maxExclusive: target[SchemaProperties.exclusiveMaximum] ?? false,
        )
      ]);
    }
    return field;
  }
}
