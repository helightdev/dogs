import "package:dogs_core/dogs_core.dart";

/// Declares JSON model rules without changing native DOGs coercion defaults.
class JsonModel extends Structure implements SerializationHook {
  /// Fields allowed in [DogModelCodec.toJson], or all fields when null.
  final List<String>? outputKeys;

  /// Converts non-null input values to strings before construction.
  final bool stringify;

  /// Returns a fresh empty list for missing or null list fields on this model.
  final bool emptyListsOnNull;

  /// Optional custom factory used when this model is decoded as a child.
  final Object Function(Map<String, dynamic>)? reader;

  /// Declares a serializable model with optional read and write rules.
  const JsonModel(
      {this.outputKeys, this.stringify = false, this.emptyListsOnNull = false, this.reader})
      : super(serializable: true);

  @override
  void beforeDeserialization(Map<String, dynamic> map, DogStructure structure, DogEngine engine) {
    final source = Map<String, dynamic>.from(map);
    for (final field in structure.fields) {
      final aliases = field.firstAnnotationOf<JsonAliases>();
      if (aliases != null) map[field.name] = aliases.readValue(source);
    }
    if (stringify) map.updateAll((key, value) => value?.toString());
  }

  @override
  void postSerialization(
      dynamic obj, Map<String, dynamic> map, DogStructure structure, DogEngine engine) {
    final keys = outputKeys;
    if (keys != null) map.removeWhere((key, value) => !keys.contains(key));
  }
}

/// Reads the first non-null input key, in declaration order.
class JsonAliases extends StructureMetadata {
  /// Accepted input names; the generated field name remains the output name.
  final List<String> keys;

  /// Declares alternative input names, including the canonical name if wanted.
  const JsonAliases(this.keys);

  /// Returns the first key with a non-null value, or null if none match.
  String? readKey(Map<String, dynamic> json) {
    for (final key in keys) {
      if (json[key] != null) return key;
    }
    return null;
  }

  /// Reads from the original map so aliases never affect each other.
  Object? readValue(Map<String, dynamic> json) => json[readKey(json)];
}

/// Forces a value when decoding, independently of incoming JSON.
class JsonReadValue extends StructureMetadata with FieldSerializationHook {
  /// The value supplied to the constructor.
  final Object? value;

  /// Keeps transient constructor state independent of backend fields.
  const JsonReadValue(this.value);

  @override
  void beforeFieldDeserialization(NativeStructureContext context,
      NativeStructureFieldContext fieldContext, Map<String, dynamic> map, DogEngine engine) {
    map[fieldContext.key] = value;
  }
}

/// Converts a raw JSON field value before constructor type checking.
class JsonConvert extends StructureMetadata {
  /// A constant top-level or static function; also receives null inputs.
  final Object? Function(Object?) convert;

  /// Declares a reusable field conversion instead of a per-model map override.
  const JsonConvert(this.convert);
}

/// Converts each element of a JSON list with typed, indexed error handling.
class JsonListConvert extends StructureMetadata {
  /// A constant top-level or static function applied to each list element.
  final Object? Function(Object?) convert;

  /// Declares an element conversion; combine with [DefaultValue] for defaults.
  const JsonListConvert(this.convert);
}

/// Parses a nested JSON object with a fromJson-style factory.
///
/// Reads [key] from the parent map, or the generated field name when [key] is
/// omitted. When [key] is omitted and [JsonAliases] is present, alias lookup
/// is used instead.
class JsonParser extends StructureMetadata {
  /// Constant tear-off receiving the nested object map.
  final Object? Function(Map<String, dynamic>) parse;

  /// Backend key to read; defaults to the generated field name when omitted.
  final String? key;

  /// Declares an explicit nested object parse, including unregistered types.
  const JsonParser(this.parse, {this.key});
}

/// Parses each JSON list element as a nested object map.
///
/// Reads [key] from the parent map, or the generated field name when [key] is
/// omitted. When [key] is omitted and [JsonAliases] is present, alias lookup
/// is used instead.
class JsonListParser extends StructureMetadata {
  /// Constant tear-off receiving each nested object map element.
  final Object? Function(Map<String, dynamic>) parse;

  /// Backend key to read; defaults to the generated field name when omitted.
  final String? key;

  /// Declares an explicit nested list parse, including unregistered types.
  const JsonListParser(this.parse, {this.key});
}

/// Reads a field using the full original input map for cross-field rules.
class JsonReadWith extends StructureMetadata {
  /// A constant top-level or static function receiving the unmodified input.
  final Object? Function(Map<String, dynamic>) read;

  /// Declares a custom rule that depends on more than one backend field.
  const JsonReadWith(this.read);
}

/// Common explicit conversions that are not inferred from Dart field types.
///
/// Use the static methods as constant tear-offs with [JsonConvert] /
/// [JsonListConvert], for example `@JsonConvert(JsonConversions.stringify)`.
class JsonConversions {
  /// Converts a non-null value to its string representation.
  static String? stringify(Object? value) => value?.toString();

  /// Converts booleans to 0/1, retains integers, and defaults other values to 0.
  static int flagInt(Object? value) => value is bool
      ? (value ? 1 : 0)
      : value is int
          ? value
          : 0;

  /// Truncates a numeric value toward zero; rejects non-numeric values.
  static int integer(Object? value) => (value as num).toInt();
}

/// Controls nested-object/list diagnostics without adding a codec dependency.
class DogModelGuard {
  /// Uses strict JSON container types and reports malformed fields as formats.
  const DogModelGuard();

  /// Parses an optional object, retaining its field name in errors.
  T? object<T>(Map<String, dynamic> json, String key, T Function(Map<String, dynamic>) parse) {
    final value = json[key];
    if (value == null) return null;
    try {
      return parse(value as Map<String, dynamic>);
    } catch (error) {
      throw FormatException('Invalid "$key": expected $T. $error', value);
    }
  }

  /// Parses an optional list, retaining its field name and element index.
  List<T>? list<T>(Map<String, dynamic> json, String key, T Function(dynamic) parse) {
    final value = json[key];
    if (value == null) return null;
    if (value is! List) {
      throw FormatException('Invalid "$key": expected List<$T>.', value);
    }
    return [
      for (var index = 0; index < value.length; index++)
        element<T>(value[index], "$key[$index]", parse),
    ];
  }

  /// Parses one list element, reporting its complete indexed field name.
  T element<T>(dynamic value, String key, T Function(dynamic) parse) {
    try {
      return parse(value);
    } catch (error) {
      throw FormatException('Invalid "$key": expected $T. $error', value);
    }
  }
}

/// Maps backend JSON using generated fields while retaining strict Dart casts.
///
/// This opt-in codec does not alter [DogEngine.fromNative]. Scalar values are
/// passed to the generated constructor unchanged unless explicitly converted.
/// JSON hooks outside the annotations documented here use native DOGs modes.
class DogModelCodec {
  /// The engine containing generated model structures.
  final DogEngine engine;

  /// Nested object/list diagnostics, which applications may customize.
  final DogModelGuard guard;

  /// Creates a reusable codec; no global state or engine mutation is required.
  const DogModelCodec({required this.engine, this.guard = const DogModelGuard()});

  /// Finds the generated structure, or reports a missing model registration.
  DogStructure structure(Type type) {
    final result = engine.findStructureByType(type);
    if (result == null) throw StateError("Missing generated model: $type");
    return result;
  }

  /// Reads JSON without mutating input or implicitly coercing scalar numbers.
  ///
  /// Explicit [values] override input annotations, including explicit nulls.
  /// A model's custom reader is invoked only for children, avoiding recursion
  /// when a custom factory itself delegates to this method.
  T fromJson<T>(Map<String, dynamic> json,
          {Map<String, dynamic> values = const {}, bool stringify = false}) =>
      readStructure(structure(T), json, values: values, stringify: stringify) as T;

  /// Reads one generated structure, recursively decoding registered children.
  dynamic readStructure(DogStructure descriptor, Map<String, dynamic> json,
      {Map<String, dynamic> values = const {}, bool stringify = false}) {
    final strings = stringify || (descriptor.firstAnnotationOf<JsonModel>()?.stringify ?? false);
    final emptyListsOnNull = descriptor.firstAnnotationOf<JsonModel>()?.emptyListsOnNull ?? false;
    final fields = <dynamic>[];
    for (final field in descriptor.fields) {
      if (values.containsKey(field.name)) {
        fields.add(values[field.name]);
        continue;
      }
      final fixed = field.firstAnnotationOf<JsonReadValue>();
      if (fixed != null) {
        fields.add(fixed.value);
        continue;
      }
      final readWith = field.firstAnnotationOf<JsonReadWith>();
      if (readWith != null) {
        fields.add(readWith.read(json));
        continue;
      }
      final aliases = field.firstAnnotationOf<JsonAliases>();
      final parser = field.firstAnnotationOf<JsonParser>();
      final listParser = field.firstAnnotationOf<JsonListParser>();
      final customKey = parser?.key ?? listParser?.key;
      final Object? value;
      final String key;
      final bool missing;
      if (customKey != null) {
        key = customKey;
        value = json[customKey];
        missing = !json.containsKey(customKey);
      } else if (aliases != null) {
        key = aliases.readKey(json) ?? field.name;
        value = aliases.readValue(json);
        missing = !aliases.keys.any(json.containsKey);
      } else {
        key = field.name;
        value = json[field.name];
        missing = !json.containsKey(field.name);
      }
      final input = {key: value};
      final defaultValue = field.firstAnnotationOf<DefaultValue>();
      final useDefault =
          defaultValue != null && (missing || (defaultValue.onNull && value == null));
      final converter = field.firstAnnotationOf<JsonConvert>();
      if (converter != null) {
        final provided = useDefault ? defaultValue.value : value;
        final supplied = useDefault && provided is DefaultValueSupplier ? provided() : provided;
        fields.add(converter.convert(supplied));
        continue;
      }
      if (parser != null) {
        fields.add(field.serial.consumeType(<T>() {
          if (useDefault) {
            final provided = defaultValue.value;
            final supplied = provided is DefaultValueSupplier ? provided() : provided;
            return supplied as T?;
          }
          return guard.object<T>(input, key, (data) => parser.parse(data) as T);
        }));
        continue;
      }
      final nested = engine.findStructureByType(field.serial.typeArgument);
      final listConverter = field.firstAnnotationOf<JsonListConvert>();
      if (field.iterableKind == IterableKind.list &&
          (nested != null ||
              listConverter != null ||
              listParser != null ||
              defaultValue != null ||
              emptyListsOnNull)) {
        fields.add(field.serial.consumeType(<T>() {
          final result = guard.list<T>(input, key, (item) {
            if (listParser != null) {
              return listParser.parse(item as Map<String, dynamic>) as T;
            }
            if (listConverter != null) return listConverter.convert(item) as T;
            if (nested != null) {
              return readChild(nested, item as Map<String, dynamic>) as T;
            }
            return item as T;
          });
          if (result != null) return result;
          if (useDefault) {
            final provided = defaultValue.value;
            final supplied = provided is DefaultValueSupplier ? provided() : provided;
            return List<T>.from(supplied as Iterable);
          }
          return emptyListsOnNull ? <T>[] : null;
        }));
        continue;
      }
      if (nested != null) {
        fields.add(field.serial.consumeType(
            <T>() => guard.object<T>(input, key, (data) => readChild(nested, data) as T)));
        continue;
      }
      final provided = useDefault ? defaultValue.value : value;
      final supplied = useDefault && provided is DefaultValueSupplier ? provided() : provided;
      fields.add(strings ? supplied?.toString() : supplied);
    }
    return descriptor.proxy.instantiate(fields);
  }

  /// Uses an explicitly declared child factory or the generated structure.
  dynamic readChild(DogStructure descriptor, Map<String, dynamic> json) {
    final reader = descriptor.firstAnnotationOf<JsonModel>()?.reader;
    return reader == null ? readStructure(descriptor, json) : reader(json);
  }

  /// Returns raw constructor fields, filtered by [JsonModel.outputKeys].
  ///
  /// Nulls and nested instances are retained; use [DogEngine.toNative] when a
  /// recursively encoded, JSON-ready object graph is required.
  Map<String, dynamic> toJson<T>(T model) {
    final descriptor = structure(T);
    final values = descriptor.proxy.getFieldValues(model);
    final keys = descriptor.firstAnnotationOf<JsonModel>()?.outputKeys;
    return {
      for (var index = 0; index < descriptor.fields.length; index++)
        if (keys == null || keys.contains(descriptor.fields[index].name))
          descriptor.fields[index].name: values[index],
    };
  }
}
