# Schemas

The library can **generate schema definitions** for all converters that support it and can **also regenerate**
'materialize' **structures** from those **schema definitions**. The schema definition format is JSON-based and a
subset of **JSON Schema** with some custom framework-specific extensions, primarily used for styling in the Flutter
integration.

## API Examples

```{ .dart title="Export a Schema" }
// This config fully expands all references for use in other tools 
final schemaConfig = SchemaConfig(useReferences: false);

final schema = dogs.describe<User>(config: schemaConfig);
final exported = schema.toJson();
```

```{ .dart title="Define a schema using the dsl" }
final schema = object({
  "name": string(),
  "age": integer().min(0),
});
```

```{ .dart title="Load a converter from a JSON schema" }
final schema = parseSchema([...]);
final converter = dogs.materialize(schema);
// Use the proxy methods of the converter
```

```{ .dart title="Import a json schema into the global dogs instance" } 
final schema = parseSchema([...]);
final typeReference = dogs.importSchema(schema);
// Use the returned type reference like a type tree
```

## Supported JSON Schema Properties

- `type: string | number | integer | boolean | null`
- `enum: [string]`
- `default: any`

List/Array specific:

- `minItems: int`
- `maxItems: int`
- `uniqueItems: bool`

Object specific:  
`required: [String]` (Only written, for reading only unions with `null` make fields optional)

Number specific:

- `minimum: number`
- `maximum: number`
- `exclusiveMinimum: number`
- `exclusiveMaximum: number`

String specific:

- `minLength: int`
- `maxLength: int`
- `pattern: string`
