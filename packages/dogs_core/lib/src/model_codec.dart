import "package:dogs_core/dogs_core.dart";

/// Sentinel for an unset [JsonKey.value], so explicit `null` stays expressible.
class JsonKeyUnset {
  /// Creates the shared unset sentinel.
  const JsonKeyUnset();
}

/// Marker used when [JsonKey.value] is omitted.
const jsonKeyUnset = JsonKeyUnset();

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
      final key = field.firstAnnotationOf<JsonKey>();
      final aliases = key?.aliases;
      if (aliases != null) map[field.name] = key!.readAliasValue(source);
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

/// Unified field JSON rules for [DogModelCodec].
///
/// Use one annotation per field instead of separate alias/convert/parser types.
/// [convert] always runs on the whole field value. [each] converts list elements.
/// [parse] reads a nested object map, or each list element map when the field is
/// a list.
class JsonKey extends StructureMetadata with FieldSerializationHook {
  /// Alternative input names; the generated field name remains the output name.
  final List<String>? aliases;

  /// Explicit input key; defaults to the generated field name when omitted.
  final String? name;

  /// Converts the whole field value before construction.
  final Object? Function(Object?)? convert;

  /// Converts each list element before construction.
  final Object? Function(Object?)? each;

  /// Parses a nested object map, or each list element map for list fields.
  final Object? Function(Map<String, dynamic>)? parse;

  /// Reads using the full parent input map.
  final Object? Function(Map<String, dynamic>)? read;

  /// Forces this decode value when not [jsonKeyUnset], including explicit null.
  final Object? value;

  /// Declares field-level JSON rules for aliases, conversion, and nested parses.
  const JsonKey({
    this.aliases,
    this.name,
    this.convert,
    this.each,
    this.parse,
    this.read,
    this.value = jsonKeyUnset,
  });

  /// Whether [value] was supplied, including an explicit null.
  bool hasFixedValue() => !identical(value, jsonKeyUnset);

  /// Returns the first alias key with a non-null value, or null if none match.
  String? readAliasKey(Map<String, dynamic> json) {
    final keys = aliases;
    if (keys == null) return null;
    for (final key in keys) {
      if (json[key] != null) return key;
    }
    return null;
  }

  /// Reads from the original map so aliases never affect each other.
  Object? readAliasValue(Map<String, dynamic> json) => json[readAliasKey(json)];

  @override
  void beforeFieldDeserialization(NativeStructureContext context,
      NativeStructureFieldContext fieldContext, Map<String, dynamic> map, DogEngine engine) {
    if (hasFixedValue()) map[fieldContext.key] = value;
  }
}

/// Common explicit conversions that are not inferred from Dart field types.
///
/// Use the static methods as constant tear-offs with [JsonKey], for example
/// `@JsonKey(convert: JsonConversions.stringify)`.
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
      final keyMeta = field.firstAnnotationOf<JsonKey>();
      if (keyMeta != null && keyMeta.hasFixedValue()) {
        fields.add(keyMeta.value);
        continue;
      }
      if (keyMeta?.read != null) {
        fields.add(keyMeta!.read!(json));
        continue;
      }
      final Object? value;
      final String key;
      final bool missing;
      if (keyMeta?.name != null) {
        key = keyMeta!.name!;
        value = json[key];
        missing = !json.containsKey(key);
      } else if (keyMeta?.aliases != null) {
        key = keyMeta!.readAliasKey(json) ?? field.name;
        value = keyMeta.readAliasValue(json);
        missing = !keyMeta.aliases!.any(json.containsKey);
      } else {
        key = field.name;
        value = json[field.name];
        missing = !json.containsKey(field.name);
      }
      final input = {key: value};
      final defaultValue = field.firstAnnotationOf<DefaultValue>();
      final useDefault =
          defaultValue != null && (missing || (defaultValue.onNull && value == null));
      if (keyMeta?.convert != null) {
        final provided = useDefault ? defaultValue.value : value;
        final supplied = useDefault && provided is DefaultValueSupplier ? provided() : provided;
        fields.add(keyMeta!.convert!(supplied));
        continue;
      }
      final isList = field.iterableKind == IterableKind.list;
      if (keyMeta?.parse != null && !isList) {
        fields.add(field.serial.consumeType(<T>() {
          if (useDefault) {
            final provided = defaultValue.value;
            final supplied = provided is DefaultValueSupplier ? provided() : provided;
            return supplied as T?;
          }
          return guard.object<T>(input, key, (data) => keyMeta!.parse!(data) as T);
        }));
        continue;
      }
      final nested = engine.findStructureByType(field.serial.typeArgument);
      if (isList &&
          (nested != null ||
              keyMeta?.each != null ||
              keyMeta?.parse != null ||
              defaultValue != null ||
              emptyListsOnNull)) {
        fields.add(field.serial.consumeType(<T>() {
          final result = guard.list<T>(input, key, (item) {
            if (keyMeta?.parse != null) {
              return keyMeta!.parse!(item as Map<String, dynamic>) as T;
            }
            if (keyMeta?.each != null) return keyMeta!.each!(item) as T;
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
