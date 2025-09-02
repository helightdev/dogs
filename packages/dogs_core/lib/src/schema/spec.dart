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

import "dart:convert";
import "dart:developer";

// ignore: unused_import
import "package:collection/collection.dart";
import "package:crypto/crypto.dart";
import "package:dogs_core/dogs_core.dart";
import "package:meta/meta.dart";

/// Extension methods for schema generation on [DogEngine].
extension SchemaGenerateExtension on DogEngine {
  /// Generates a schema for the given type [T].
  SchemaType describe<T>({SchemaConfig config = const SchemaConfig()}) {
    if (SchemaPass.current != null) {
      final converter = findAssociatedConverter(T);
      if (converter == null) {
        throw DogException("No converter found for type $T");
      }
      return converter.describeOutput(this, config);
    }

    final converter = findAssociatedConverter(T);
    if (converter == null) {
      throw DogException("No converter found for type $T");
    }
    return SchemaPass.run((pass) {
      return converter.describeOutput(this, config);
    });
  }

  /// Materializes a [type] schema, creating a [MaterializedConverter] that
  /// can be used to convert data to and from the schema.
  ///
  /// Materialization will create an engine fork with the custom types defined
  /// in the schema.
  MaterializedConverter materialize(SchemaType type) {
    return DogsMaterializer.get(this).materialize(type, true);
  }

  /// Materializes a [type] schema in the current engine scope, registering
  /// the resulting structures and converters.
  SyntheticTypeCapture importSchema(SchemaType type) {
    final materialized = DogsMaterializer.get(this).materialize(type, false);
    return SyntheticTypeCapture(materialized.structure.serialName);
  }
}

/// Configuration options for schema generation.
class SchemaConfig {
  /// Whether to use references for object types.
  final bool useReferences;

  /// Configuration options for schema generation.
  const SchemaConfig({this.useReferences = true});
}

/// A field in a schema object.
class SchemaField {
  /// The name/key of the field.
  String name;

  /// The type of the field.
  SchemaType type;

  /// Additional properties of the field.
  Map<String, dynamic> properties = {};

  /// A field in a schema object.
  SchemaField(this.name, this.type);

  /// Adds a custom property to the field.
  void operator []=(String key, dynamic value) {
    properties[key] = value;
  }

  /// Gets a custom property from the field.
  dynamic operator [](String key) => properties[key];

  /// Creates a deep copy of this field.
  SchemaField clone() {
    final field = SchemaField(name, type.clone());
    properties.forEach((key, value) {
      field[key] = value;
    });
    return field;
  }
}

/// A schema type.
sealed class SchemaType {
  /// The core type of the schema.
  SchemaCoreType type;

  /// Whether the type accepts null values.
  bool nullable = false;

  /// Additional properties of the schema.
  Map<String, dynamic> properties = {};

  SchemaType(this.type);

  /// Creates a schema type representing an integer.
  static SchemaType get integer => SchemaPrimitive(SchemaCoreType.integer);

  /// Creates a schema type representing a number.
  static SchemaType get number => SchemaPrimitive(SchemaCoreType.number);

  /// Creates a schema type representing a string.
  static SchemaType get string => SchemaPrimitive(SchemaCoreType.string);

  /// Creates a schema type representing a boolean.
  static SchemaType get boolean => SchemaPrimitive(SchemaCoreType.boolean);

  /// Creates a schema type representing any value.
  static SchemaType get any => SchemaPrimitive(SchemaCoreType.any);

  /// Creates a schema type representing a null value.
  static SchemaType get none => SchemaPrimitive(SchemaCoreType.$null);

  /// Creates a schema type representing a reference to another schema by its serial name.
  static SchemaType reference(String serialName) => SchemaReference(serialName);

  /// Creates a schema type representing an array of the given item type.
  static SchemaType array(SchemaType items) {
    if (items is SchemaArray || items is SchemaMap) {
      log(
          "Multidimensional arrays and maps are not fully supported yet. "
          "While serialization should generally work, validation and container "
          "specific configurations may not work as expected.",
          level: 500);
    }

    return SchemaArray(items);
  }

  /// Creates a schema type representing an object with the given fields.
  static SchemaType object({List<SchemaField> fields = const []}) => SchemaObject(fields: fields);

  /// Creates a schema type representing a string-keyed map with values of the given item type.
  static SchemaType map(SchemaType itemType) {
    if (itemType is SchemaArray || itemType is SchemaMap) {
      log(
          "Multidimensional arrays and maps are not fully supported yet. "
          "While serialization should generally work, validation and container "
          "specific configurations may not work as expected.",
          level: 500);
    }

    return SchemaMap(itemType);
  }

  /// Reads a SchemaType from a property map.
  static SchemaType fromProperties(Map<String, dynamic> properties) {
    final typeValue = properties["type"];
    final types = typeValue is List ? typeValue.cast<String>() : <String>[typeValue];
    final (coreType, nullable) = SchemaCoreType.fromJsonSchema(types);

    switch (coreType) {
      case SchemaCoreType.string:
        return SchemaPrimitive(SchemaCoreType.string, format: properties[SchemaProperties.format])
          ..nullable = nullable
          ..properties = _cleanProperties(properties);
      case SchemaCoreType.number:
      case SchemaCoreType.integer:
      case SchemaCoreType.boolean:
      case SchemaCoreType.$null:
        return SchemaPrimitive(coreType)
          ..nullable = nullable
          ..properties = _cleanProperties(properties);
      case SchemaCoreType.array:
        final items = properties["items"] as Map<String, dynamic>;
        return SchemaArray(fromProperties(items))
          ..nullable = nullable
          ..properties = _cleanProperties(properties);
      case SchemaCoreType.object:
        if (properties.containsKey(SchemaProperties.ref)) {
          return SchemaReference(properties[SchemaProperties.serialName])
            ..nullable = nullable
            ..properties = _cleanProperties(properties);
        } else if (properties.containsKey("additionalProperties")) {
          final itemType = fromProperties(properties["additionalProperties"]);
          return SchemaMap(itemType)
            ..nullable = nullable
            ..properties = _cleanProperties(properties);
        } else {
          final fields = (properties["properties"] as Map<String, dynamic>?)?.entries.map((entry) {
                final fieldType = fromProperties(entry.value as Map<String, dynamic>);
                return SchemaField(entry.key, fieldType);
              }).toList() ??
              [];
          return SchemaObject(fields: fields)
            ..nullable = nullable
            ..properties = _cleanProperties(properties);
        }
      case SchemaCoreType.any:
        return SchemaPrimitive(SchemaCoreType.any)
          ..nullable = nullable
          ..properties = _cleanProperties(properties);
    }
  }

  static Map<String, dynamic> _cleanProperties(Map<String, dynamic> properties) {
    return Map.fromEntries(properties.entries.where((e) => !_isTypeProperty(e.key)));
  }

  static bool _isTypeProperty(String key) {
    const typeProperties = [
      "type",
      "items",
      "properties",
      "required",
      "additionalProperties",
      SchemaProperties.ref,
      SchemaProperties.format,
    ];
    return typeProperties.contains(key);
  }

  /// Adds a custom property to the schema.
  void operator []=(String key, dynamic value) {
    properties[key] = value;
  }

  /// Gets a custom property from the schema.
  dynamic operator [](String key) => properties[key];

  void _writeToProperties(Map<String, dynamic> map) {
    map["type"] = type.toJsonSchemaType(nullable);
    if (properties.isNotEmpty) {
      properties.forEach((key, value) {
        map[key] = value;
      });
    }
  }

  /// Converts this schema type to a map of json-schema-like properties.
  Map<String, dynamic> toProperties() {
    final buffer = <String, dynamic>{};
    _writeToProperties(buffer);
    return buffer;
  }

  /// Converts this schema type to a formatted JSON string.
  String toJson() {
    return JsonEncoder.withIndent("  ").convert(toProperties());
  }

  /// Converts this schema type to a SHA-256 hash of its properties.
  String toSha256() {
    final buffer = toProperties();
    return sha256.convert(utf8.encode(jsonEncode(buffer))).toString();
  }

  /// Creates a deep copy of this schema type.
  SchemaType clone();

  /// Removes the nullable flag from this schema type.
  @internal
  SchemaType removeNullable() => clone()..nullable = false;
}

/// Commonly used JSON Schema property keys.
class SchemaProperties {
  // List
  /// https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.6.4.2
  static const String minItems = "minItems";

  /// https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.6.4.1
  static const String maxItems = "maxItems";

  /// https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.6.4.3
  static const String uniqueItems = "uniqueItems";

  // Number
  /// https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.6.2.4
  static const String minimum = "minimum";

  /// https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.6.2.2
  static const String maximum = "maximum";

  /// https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.6.2.5
  static const String exclusiveMinimum = "exclusiveMinimum";

  /// https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.6.2.3
  static const String exclusiveMaximum = "exclusiveMaximum";

  // String
  /// https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.7.2.1
  static const String format = "format";

  /// https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.6.3.2
  static const String minLength = "minLength";

  /// https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.6.3.1
  static const String maxLength = "maxLength";

  /// https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.6.3.3
  static const String pattern = "pattern";

  // Arbitrary
  /// https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.6.1.2
  static const String $enum = "enum";

  /// https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.9.2
  static const String $default = "default";

  /// https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.9.1
  static const String title = "title";

  /// https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.9.1
  static const String description = "description";

  /// https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-00#rfc.section.8.2.3.1
  static const String ref = r"$ref";

  /// Dogs serial name
  static const String serialName = "x-serialName";

  /// List of properties that should be inherited by reference types.
  static const List<String> $inheritedProperties = [serialName];
}

/// A primitive schema type.
class SchemaPrimitive extends SchemaType {
  /// The format of the string primitives.
  String? format;

  /// A primitive schema type.
  SchemaPrimitive(super.type, {this.format});

  @override
  void _writeToProperties(Map<String, dynamic> map) {
    super._writeToProperties(map);
    if (format != null) map[SchemaProperties.format] = format;
  }

  @override
  SchemaPrimitive clone() {
    return SchemaPrimitive(type, format: format)
      ..properties = Map.from(properties)
      ..nullable = nullable;
  }
}

/// A string-keyed map with values of a specific type.
class SchemaMap extends SchemaType {
  /// The type of the items in the map.
  SchemaType itemType;

  /// A string-keyed map with values of a specific type.
  SchemaMap(this.itemType) : super(SchemaCoreType.object);

  @override
  void _writeToProperties(Map<String, dynamic> map) {
    super._writeToProperties(map);
    final buffer = <String, dynamic>{};
    itemType._writeToProperties(buffer);
    map["additionalProperties"] = buffer;
  }

  @override
  SchemaMap clone() {
    return SchemaMap(itemType.clone())
      ..properties = Map.from(properties)
      ..nullable = nullable;
  }
}

/// A collection of key-value pairs.
class SchemaObject extends SchemaType {
  /// The fields of the object.
  List<SchemaField> fields;

  /// A collection of key-value pairs.
  SchemaObject({this.fields = const []}) : super(SchemaCoreType.object);

  @override
  void _writeToProperties(Map<String, dynamic> map) {
    super._writeToProperties(map);
    if (fields.isNotEmpty) {
      map["properties"] = Map.fromEntries(fields.map((e) {
        final buffer = <String, dynamic>{};
        e.type._writeToProperties(buffer);
        buffer.addAll(e.properties);
        return MapEntry(e.name, buffer);
      }));

      map["required"] = fields.where((e) => !e.type.nullable).map((e) => e.name).toList();
    }
  }

  @override
  SchemaObject clone() {
    return SchemaObject(fields: fields.map((e) => e.clone()).toList())
      ..properties = Map.from(properties)
      ..nullable = nullable;
  }
}

/// A collection of items.
class SchemaArray extends SchemaType {
  /// The type of the items in the array.
  SchemaType items;

  /// A collection of items.
  SchemaArray(this.items) : super(SchemaCoreType.array);

  @override
  void _writeToProperties(Map<String, dynamic> map) {
    super._writeToProperties(map);
    final buffer = <String, dynamic>{};
    items._writeToProperties(buffer);
    map["items"] = buffer;
  }

  @override
  SchemaArray clone() {
    return SchemaArray(items.clone())
      ..properties = Map.from(properties)
      ..nullable = nullable;
  }
}

/// A reference to another schema structure.
final class SchemaReference extends SchemaType {
  /// The serial name of there referenced dogs structure.
  String serialName;

  /// A reference to another schema structure.
  SchemaReference(this.serialName) : super(SchemaCoreType.object);

  @override
  void _writeToProperties(Map<String, dynamic> map) {
    super._writeToProperties(map);
    map[SchemaProperties.ref] = "#/\$defs/$serialName";
    map[SchemaProperties.serialName] = serialName;
  }

  @override
  SchemaReference clone() {
    return SchemaReference(serialName)
      ..properties = Map.from(properties)
      ..nullable = nullable;
  }
}

/// Json Schema core types
enum SchemaCoreType {
  /// Represents any JSON value.
  any(["string", "number", "integer", "boolean", "object", "array"]),

  /// Represents a string value.
  string(["string"]),

  /// Represents a numeric value.
  number(["number"]),

  /// Represents an integer value.
  integer(["integer"]),

  /// Represents a boolean value.
  boolean(["boolean"]),

  /// Represents an object value.
  object(["object"]),

  /// Represents an array value.
  array(["array"]),

  /// Represents a null value.
  $null(["null"]);

  final List<String> _jsonSchemaTypes;

  const SchemaCoreType([this._jsonSchemaTypes = const []]);

  /// Converts a string to a [SchemaCoreType].
  static SchemaCoreType fromString(String value) {
    switch (value) {
      case "any":
        return SchemaCoreType.any;
      case "string":
        return SchemaCoreType.string;
      case "number":
        return SchemaCoreType.number;
      case "integer":
        return SchemaCoreType.integer;
      case "boolean":
        return SchemaCoreType.boolean;
      case "object":
        return SchemaCoreType.object;
      case "array":
        return SchemaCoreType.array;
      case "null":
        return SchemaCoreType.$null;
      default:
        throw Exception("Unknown value: $value");
    }
  }

  /// Converts a list of JSON schema types to a [SchemaCoreType] and a nullable flag.
  static (SchemaCoreType type, bool nullable) fromJsonSchema(List<String> types) {
    final nullable = types.contains("null");
    final nonNullTypes = types.where((type) => type != "null").toList();
    if (nonNullTypes.length == 1) {
      return (fromString(nonNullTypes.first), nullable);
    } else {
      return (SchemaCoreType.any, nullable);
    }
  }

  @override
  String toString() => name;

  /// Converts this [SchemaCoreType] to a JSON schema type.
  Object toJsonSchemaType(bool nullable) {
    final list = <String>{};
    list.addAll(_jsonSchemaTypes);
    if (nullable) {
      list.add("null");
    }
    if (list.length == 1) {
      return list.first;
    } else {
      return list.toList();
    }
  }
}
