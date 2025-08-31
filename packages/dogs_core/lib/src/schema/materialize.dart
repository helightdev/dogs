import "dart:convert";
import "dart:math";

import "package:dogs_core/dogs_core.dart";
import "package:dogs_core/dogs_schema.dart";
import "package:dogs_core/src/schema/contributors.dart";

class SchemaObjectUnroller {
  SchemaObjectUnroller._();

  /// Unrolls the given [type], returning a list of all encountered [SchemaObject]s
  /// and the unrolled root [SchemaType], which will be a [SchemaReference].
  static (List<SchemaObject> objects, SchemaType unrolled) unroll(
      SchemaType type) {
    final unroller = SchemaObjectUnroller._();
    final unrolled = unroller._visit(type, false);
    return (unroller._objects.values.toList(), unrolled);
  }

  final Map<String, SchemaObject> _objects = {};

  SchemaType _visit(SchemaType type, bool isRoot) {
    switch (type) {
      case SchemaPrimitive():
        return type.clone();
      case SchemaMap():
        return type.clone()..itemType = _visit(type.itemType, false);
      case SchemaObject():
        final cloned = type.clone();
        if (isRoot) {
          for (var e in cloned.fields) {
            e.type = _visit(e.type, false);
          }
          return cloned;
        }

        cloned.properties = <String, dynamic>{};
        for (var inheritedProperty in SchemaProperties.$inheritedProperties) {
          if (type.properties.containsKey(inheritedProperty)) {
            cloned.properties[inheritedProperty] = type.properties[inheritedProperty];
          }
        }

        final String hashName =
            cloned.properties[SchemaProperties.serialName] ??
                "*${cloned.toSha256()}";
        if (!_objects.containsKey(hashName)) {
          cloned.properties[SchemaProperties.serialName] = hashName;
          _objects[hashName] = _visit(cloned, true) as SchemaObject;
        }

        return SchemaReference(hashName)
          ..nullable = type.nullable
          ..properties = Map.from(type.properties);
      case SchemaArray():
        return type.clone()..items = _visit(type.items, false);
      case SchemaReference():
        return type.clone();
    }
  }
}

abstract class SchemaStructureMaterializationContributor {
  /// May be used to transform the generated [DogStructureField] before it is added to the [DogStructure].
  DogStructureField transformField(
          DogStructureField field, SchemaType schema) =>
      field;

  /// May be used to transform the generated [DogStructure] before it is used in the [MaterializedConverter].
  DogStructure<Object> transformStructure(
          DogStructure<Object> structure, SchemaType schema) =>
      structure;
}

class DogsMaterializer {
  final DogEngine engine;

  DogsMaterializer(this.engine);

  List<SchemaStructureMaterializationContributor> contributors = [
    CollectionValidationContributor(),
    StringValidationContributor(),
    NumberValidationContributor(),
  ];

  /// Returns or creates a [DogsMaterializer] associated with the given [engine],
  /// or the default [DogEngine.instance] if no engine is provided. If the
  /// materializer does not exist yet, it will be created and configured with
  /// the default contributors.
  static DogsMaterializer get([DogEngine? engine]) {
    engine ??= DogEngine.instance;
    final instance = engine.getMetaOrNull<DogsMaterializer>();
    if (instance != null) return instance;
    return configure(engine: engine);
  }

  /// Creates a new [DogsMaterializer] associated with the given [engine],
  /// or the default [DogEngine.instance] if no engine is provided.
  static DogsMaterializer configure({DogEngine? engine}) {
    engine ??= DogEngine.instance;
    final materializer = DogsMaterializer(engine);
    engine.setMeta<DogsMaterializer>(materializer);
    return materializer;
  }

  /// Materializes the given [type] into a [MaterializedConverter], which can be
  /// used like most other statically defined converters.
  ///
  /// If [useFork] is true, a fork of the current engine will be used to register
  /// the generated structures and converters, otherwise the current engine will be used.
  /// Usually, using a fork is preferred to avoid polluting the main engine with
  /// dynamically generated structures. This wil also prevent the schema from
  /// possibly overriding existing structures in the original engine.
  MaterializedConverter materialize(SchemaType type, bool useFork) {
    final usedEngine = switch (useFork) {
      true => engine.fork(),
      false => engine,
    };
    final (objects, unrolled) = SchemaObjectUnroller.unroll(type);
    if (unrolled is! SchemaReference) {
      throw DogException(
          "Root type must have a serial name, most likely the root is not an object."
          "Currently only objects are supported as schema roots.");
    }
    final String rootSerialName = unrolled.serialName;
    for (var object in objects) {
      final String serialName =
          object.properties[SchemaProperties.serialName]!!;
      final fieldNames = object.fields.map((e) => e.name).toList();
      var structure = DogStructure<Object>(
          serialName,
          StructureConformity.basic,
          object.fields.map((e) {
            var field = _materializeField(usedEngine, e);
            for (var contributor in contributors) {
              field = contributor.transformField(field, e.type);
            }
            return field;
          }).toList(),
          [],
          FieldMapStructureProxy(fieldNames));
      for (var contributor in contributors) {
        structure = contributor.transformStructure(structure, object);
      }
      final converter = DogStructureConverterImpl(structure);
      usedEngine.registerAutomatic(converter);
    }
    final converter = usedEngine.findConverterBySerialName(rootSerialName)!;
    final structure = usedEngine.findStructureBySerialName(rootSerialName)!;
    final nativeMode = usedEngine.modeRegistry.nativeSerialization
        .forConverter(converter, usedEngine);
    final serializer = MaterializedConverter(
        usedEngine, converter, nativeMode, structure, type);
    return serializer;
  }

  static TypeTree _materializeTypeTree(
      DogEngine engine, SchemaType type, TypeTree Function() polymorphic) {
    if (type.nullable) {
      return TypeTreeN<Optional>(
          [_materializeTypeTree(engine, type.removeNullable(), polymorphic)]);
    }

    return switch (type) {
      SchemaObject() => throw DogException(
          "SchemaObject is not supported as for materialization, schema types must be unrolled first."),
      SchemaPrimitive() => switch (type.type) {
          SchemaCoreType.any => polymorphic(),
          SchemaCoreType.string => QualifiedTypeTree.terminal<String>(),
          SchemaCoreType.number => QualifiedTypeTree.terminal<double>(),
          SchemaCoreType.integer => QualifiedTypeTree.terminal<int>(),
          SchemaCoreType.boolean => QualifiedTypeTree.terminal<bool>(),
          SchemaCoreType.object => throw UnimplementedError(),
          SchemaCoreType.array => throw UnimplementedError(),
          SchemaCoreType.$null => polymorphic(),
        },
      SchemaMap() => TypeTreeN<Map>([
          QualifiedTypeTree.terminal<String>(),
          _materializeTypeTree(engine, type.itemType, polymorphic),
        ]),
      SchemaArray() => _materializeArray(engine, type, polymorphic),
      SchemaReference(serialName: final serialName) =>
        SyntheticTypeCapture(serialName) as TypeTree
    };
  }

  static TypeTree _materializeArray(DogEngine engine, SchemaArray type,
      TypeTree<dynamic> Function() polymorphic) {
    final uniqueItems = type[SchemaProperties.uniqueItems] as bool? ?? false;
    if (uniqueItems) {
      return TypeTreeN<Set>([
        _materializeTypeTree(engine, type.items, polymorphic),
      ]);
    }
    return TypeTreeN<List>([
      _materializeTypeTree(engine, type.items, polymorphic),
    ]);
  }

  static DogStructureField _materializeField(
      DogEngine fork, SchemaField field) {
    var isPolymorphic = false;
    final materializedTypeTree =
        _materializeTypeTree(fork, field.type.removeNullable(), () {
      isPolymorphic = true;
      return QualifiedTypeTree.terminal<dynamic>();
    });
    final annotations = <StructureMetadata>[];
    if (isPolymorphic) {
      annotations.add(polymorphic);
    }

    final enumProperty = field.type[SchemaProperties.$enum] as List<String>?;
    if (enumProperty != null) {
      annotations.add(UseConverterInstance(
          RuntimeEnumConverter(enumProperty, "${field.name}Enum")));
    }

    final structureField = DogStructureField(materializedTypeTree, null,
        field.name, field.type.nullable, true, annotations);
    return structureField;
  }
}

class MaterializedConverter {
  final DogEngine engineFork;
  final DogConverter converter;
  final NativeSerializerMode nativeMode;
  final DogStructure structure;
  final SchemaType originalSchema;

  MaterializedConverter(
    this.engineFork,
    this.converter,
    this.nativeMode,
    this.structure,
    this.originalSchema,
  );

  dynamic toNative(dynamic value) {
    return nativeMode.serialize(value, engineFork);
  }

  dynamic fromNative(dynamic value) {
    return nativeMode.deserialize(value, engineFork);
  }

  String toJson(dynamic value) => jsonEncode(toNative(value));

  dynamic fromJson(String value) => fromNative(jsonDecode(value));

  bool isValid(dynamic value) {
    return engineFork.modeRegistry.validation
        .forConverter(converter, engineFork)
        .validate(value, engineFork);
  }

  AnnotationResult annotate(dynamic value) {
    return engineFork.modeRegistry.validation
        .forConverter(converter, engineFork)
        .annotate(value, engineFork);
  }
}
