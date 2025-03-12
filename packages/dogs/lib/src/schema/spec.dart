// class SchemaField {
//   SchemaType type;
//   String name;
//   bool nullable;
//
// }
//
// class SchemaType {
//   SchemaPrimitiveType type;
//   String? format;
//   String? serial;
//
//   SchemaType(this.type, {this.format, this.serial});
//
//   SchemaType.structure(this.serial)
//       : type = SchemaPrimitiveType.object;
// }
//
//
// // Json Schema core types
// enum SchemaPrimitiveType {
//   string,
//   number,
//   integer,
//   boolean,
//   object,
//   array,
//   nil;
//
//   static SchemaPrimitiveType fromString(String value) {
//     switch (value) {
//       case "string":
//         return SchemaPrimitiveType.string;
//       case "number":
//         return SchemaPrimitiveType.number;
//       case "integer":
//         return SchemaPrimitiveType.integer;
//       case "boolean":
//         return SchemaPrimitiveType.boolean;
//       case "object":
//         return SchemaPrimitiveType.object;
//       case "array":
//         return SchemaPrimitiveType.array;
//       case "null":
//         return SchemaPrimitiveType.nil;
//       default:
//         throw Exception("Unknown value: $value");
//     }
//   }
//
//   @override
//   String toString() => name;
// }