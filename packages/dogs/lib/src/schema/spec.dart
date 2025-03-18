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

import "package:dogs_core/dogs_core.dart";

extension SchemaGenerateExtension on DogEngine {

  /// Generates a schema for the given type [T].
  SchemaType describe<T>({SchemaConfig config = const SchemaConfig()}) {
    final converter = findAssociatedConverter(T);
    if (converter == null) {
      throw DogException("No converter found for type $T");
    }
    return SchemaPass.run((pass) {
      return converter.describeOutput(this, config);
    });
  }
}

class SchemaConfig {
  final bool useReferences;

  const SchemaConfig({this.useReferences = true});
}

class SchemaField {
  String name;
  SchemaType type;
  Map<String, dynamic> properties = {};

  SchemaField(this.name, this.type);

  void operator []=(String key, dynamic value) {
    properties[key] = value;
  }

  dynamic operator [](String key) => properties[key];

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

  static SchemaType get integer => SchemaPrimitive(SchemaCoreType.integer);

  static SchemaType get number => SchemaPrimitive(SchemaCoreType.number);

  static SchemaType get string => SchemaPrimitive(SchemaCoreType.string);

  static SchemaType get boolean => SchemaPrimitive(SchemaCoreType.boolean);

  static SchemaType get any => SchemaPrimitive(SchemaCoreType.any);

  static SchemaType get none => SchemaPrimitive(SchemaCoreType.$null);

  static SchemaType reference(String serialName) => SchemaReference(serialName);

  static SchemaType array(SchemaType items) => SchemaArray(items);

  static SchemaType object({List<SchemaField> fields = const []}) =>
      SchemaObject(fields: fields);

  static SchemaType map(SchemaType itemType) => SchemaMap(itemType);

  void operator []=(String key, dynamic value) {
    properties[key] = value;
  }

  dynamic operator [](String key) => properties[key];

  void _writeToProperties(Map<String, dynamic> map) {
    map["type"] = type.toJsonSchemaType(nullable);
    if (properties.isNotEmpty) {
      properties.forEach((key, value) {
        map[key] = value;
      });
    }
  }

  String toJson() {
    final buffer = <String, dynamic>{};
    _writeToProperties(buffer);
    return JsonEncoder.withIndent("  ").convert(buffer);
  }

  /// Creates a deep copy of this schema type.
  SchemaType clone();

}

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
  static const String description = "description";

  /// https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-00#rfc.section.8.2.3.1
  static const String ref = r"$ref";

  /// Dogs serial name
  static const String serialName = "x-serialName";
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

  SchemaPrimitive clone() {
    return SchemaPrimitive(type, format: format);
  }
}

class SchemaMap extends SchemaType {

  SchemaType itemType;
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
    return SchemaMap(itemType.clone());
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

      map["required"] = fields
          .where((e) => !e.type.nullable)
          .map((e) => e.name)
          .toList();
    }
  }

  @override
  SchemaObject clone() {
    return SchemaObject(fields: fields.map((e) => e.clone()).toList());
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
    return SchemaArray(items.clone());
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
    return SchemaReference(serialName);
  }
}

/// Json Schema core types
enum SchemaCoreType {
  any(["string", "number", "integer", "boolean", "object", "array"]),
  string(["string"]),
  number(["number"]),
  integer(["integer"]),
  boolean(["boolean"]),
  object(["object"]),
  array(["array"]),
  $null(["null"]);

  final List<String> _jsonSchemaTypes;

  const SchemaCoreType([this._jsonSchemaTypes = const []]);

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
