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

library;

import "dogs_core.dart";

/// Creates a schema type representing a string.
SchemaType string() => SchemaType.string;

/// Creates a schema type representing an integer.
SchemaType integer() => SchemaType.integer;

/// Creates a schema type representing a number.
SchemaType number() => SchemaType.number;

/// Creates a schema type representing a boolean.
SchemaType boolean() => SchemaType.boolean;

/// Creates a schema type representing any value.
SchemaType any() => SchemaType.any;

/// Creates a schema type representing an object with the given properties.
SchemaType object(Map<String, SchemaType> properties) {
  return SchemaType.object(
      fields:
          properties.entries.map((e) => SchemaField(e.key, e.value)).toList());
}

/// Creates a schema type representing an array of the given item type.
SchemaType array(SchemaType itemType) {
  return SchemaType.array(itemType);
}

/// Creates a schema type representing a reference to another schema by its serial name.
SchemaType ref(String serialName) {
  return SchemaType.reference(serialName);
}

/// Creates a schema type representing a string-keyed map with values of the given item type.
SchemaType map(SchemaType itemType) {
  return SchemaType.map(itemType);
}

/// Creates a schema type representing an enumeration of the given string values.
SchemaType enumeration(List<String> values) {
  return SchemaType.string.property(SchemaProperties.$enum, values);
}

/// Extension methods for SchemaType to provide a fluent API for schema definitions.
extension SchemaTypeExtension on SchemaType {
  /// Makes this schema type an array of itself.
  SchemaType array() => SchemaType.array(this);

  /// Marks this schema type as optional (nullable).
  SchemaType optional() => this..nullable = true;

  /// Adds a custom property to the schema.
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

  /// Requires the value to be larger than the given value.
  SchemaType gt(double value) {
    if (type == SchemaCoreType.number || type == SchemaCoreType.integer) {
      return property(SchemaProperties.minimum, value)
          .property(SchemaProperties.exclusiveMinimum, true);
    }

    throw ArgumentError("Gt is not supported for $this");
  }

  /// Requires the value to be larger than or equal to the given value.
  SchemaType gte(double value) {
    if (type == SchemaCoreType.number || type == SchemaCoreType.integer) {
      return property(SchemaProperties.minimum, value);
    }

    throw ArgumentError("Gte is not supported for $this");
  }

  /// Requires the value to be less than the given value.
  SchemaType lt(double value) {
    if (type == SchemaCoreType.number || type == SchemaCoreType.integer) {
      return property(SchemaProperties.maximum, value)
          .property(SchemaProperties.exclusiveMaximum, true);
    }

    throw ArgumentError("Lt is not supported for $this");
  }

  /// Requires the value to be less than or equal to the given value.
  SchemaType lte(double value) {
    if (type == SchemaCoreType.number || type == SchemaCoreType.integer) {
      return property(SchemaProperties.maximum, value);
    }

    throw ArgumentError("Lte is not supported for $this");
  }

  /// Requires the value to be a positive number (greater than 0).
  SchemaType positive() => gte(0);

  /// Requires the value to be a negative number (less than 0).
  SchemaType negative() => lte(0);

  /// Requires the value to be a non-negative number (0 or greater).
  SchemaType nonNegative() => gte(0);

  /// Requires the value to be a non-positive number (0 or less).
  SchemaType nonPositive() => lte(0);

  /// Sets both the minimum and maximum values to the given length.
  SchemaType length(int length) => min(length).max(length);

  /// Requires all items in the array to be unique.
  SchemaType unique() {
    if (this is! SchemaArray) {
      throw ArgumentError("Unique is only supported for arrays");
    }
    return property(SchemaProperties.uniqueItems, true);
  }

  /// Sets the serial name for this schema type. Only supported for objects.
  SchemaType serialName(String serialName) {
    if (this is! SchemaObject) {
      throw ArgumentError("Serial name is only supported for objects");
    }
    return property(SchemaProperties.serialName, serialName);
  }
}
