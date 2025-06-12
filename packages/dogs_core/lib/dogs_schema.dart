import "dogs_core.dart";

SchemaType string() => SchemaType.string;

SchemaType integer() => SchemaType.integer;

SchemaType number() => SchemaType.number;

SchemaType boolean() => SchemaType.boolean;

SchemaType any() => SchemaType.any;

SchemaType object(Map<String, SchemaType> properties) {
  return SchemaType.object(
      fields:
          properties.entries.map((e) => SchemaField(e.key, e.value)).toList());
}

SchemaType array(SchemaType itemType) {
  return SchemaType.array(itemType);
}

SchemaType ref(String serialName) {
  return SchemaType.reference(serialName);
}

SchemaType map(SchemaType itemType) {
  return SchemaType.map(itemType);
}

SchemaType enumeration(List<String> values) {
  return SchemaType.string.property(SchemaProperties.$enum, values);
}

extension SchemaTypeExtension on SchemaType {
  SchemaType array() => SchemaType.array(this);

  SchemaType optional() => this..nullable = true;

  SchemaType property(String key, dynamic value) =>
      this..properties[key] = value;

  /// Sets the minimum values for the schema.
  /// Depending on the type, this may set different properties:
  /// - For strings, it sets the `minLength` property.
  /// - For numbers, it sets the `minimum` property. (inclusive).
  /// - For integers, it sets the `minimum` property. (inclusive).
  /// - For arrays, it sets the `minItems` property.
  SchemaType min(int min) {
    if (this is SchemaPrimitive) {
      if (type == SchemaCoreType.string) {
        return property(SchemaProperties.minLength, min);
      } else if (type == SchemaCoreType.number) {
        return property(SchemaProperties.minimum, min);
      } else if (type == SchemaCoreType.integer) {
        return property(SchemaProperties.minimum, min);
      }
    } else if (this is SchemaArray) {
      return property(SchemaProperties.minItems, min);
    }
    throw ArgumentError("Min is not supported for $this");
  }

  /// Sets the maximum value for the schema.
  /// Depending on the type, this may set different properties:
  /// - For strings, it sets the `maxLength` property.
  /// - For numbers, it sets the `maximum` property. (inclusive).
  /// - For integers, it sets the `maximum` property. (inclusive).
  /// - For arrays, it sets the `maxItems` property.
  SchemaType max(int max) {
    if (this is SchemaPrimitive) {
      if (type == SchemaCoreType.string) {
        return property(SchemaProperties.maxLength, max);
      } else if (type == SchemaCoreType.number) {
        return property(SchemaProperties.maximum, max);
      } else if (type == SchemaCoreType.integer) {
        return property(SchemaProperties.maximum, max);
      }
    } else if (this is SchemaArray) {
      return property(SchemaProperties.maxItems, max);
    }
    throw ArgumentError("Max is not supported for $this");
  }

  SchemaType gt(double value) {
    if (type == SchemaCoreType.number || type == SchemaCoreType.integer) {
      return property(SchemaProperties.minimum, value)
          .property(SchemaProperties.exclusiveMinimum, true);
    }

    throw ArgumentError("Gt is not supported for $this");
  }

  SchemaType gte(double value) {
    if (type == SchemaCoreType.number || type == SchemaCoreType.integer) {
      return property(SchemaProperties.minimum, value);
    }

    throw ArgumentError("Gte is not supported for $this");
  }

  SchemaType lt(double value) {
    if (type == SchemaCoreType.number || type == SchemaCoreType.integer) {
      return property(SchemaProperties.maximum, value)
          .property(SchemaProperties.exclusiveMaximum, true);
    }

    throw ArgumentError("Lt is not supported for $this");
  }

  SchemaType lte(double value) {
    if (type == SchemaCoreType.number || type == SchemaCoreType.integer) {
      return property(SchemaProperties.maximum, value);
    }

    throw ArgumentError("Lte is not supported for $this");
  }

  SchemaType positive() => gte(0);
  SchemaType negative() => lte(0);
  SchemaType nonNegative() => gte(0);
  SchemaType nonPositive() => lte(0);
  SchemaType length(int length) => min(length).max(length);
  SchemaType unique() {
    if (this is! SchemaArray) {
      throw ArgumentError("Unique is only supported for arrays");
    }
    return property(SchemaProperties.uniqueItems, true);
  }

  SchemaType serialName(String serialName) {
    if (this is! SchemaObject) {
      throw ArgumentError("Serial name is only supported for objects");
    }
    return property(SchemaProperties.serialName, serialName);
  }
}
