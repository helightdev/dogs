import "dart:convert";
import "dart:math";

import "package:dogs_core/dogs_core.dart";
import "package:dogs_core/src/schema/contributors.dart";

class SchemaObjectUnroller {
  SchemaObjectUnroller._();

  static (List<SchemaObject> objects, SchemaType unrolled) unroll(
      SchemaType type) {
    final unroller = SchemaObjectUnroller._();
    final unrolled = unroller.visit(type, false);
    return (unroller.objects.values.toList(), unrolled);
  }

  final Map<String, SchemaObject> objects = {};

  SchemaType visit(SchemaType type, bool isRoot) {
    switch (type) {
      case SchemaPrimitive():
        return type.clone();
      case SchemaMap():
        return type.clone()..itemType = visit(type.itemType, false);
      case SchemaObject():
        final cloned = type.clone();
        if (isRoot) {
          for (var e in cloned.fields) {
            e.type = visit(e.type, false);
          }
          return cloned;
        }
        final String hashName =
            cloned.properties[SchemaProperties.serialName] ??
                "*${cloned.toSha256()}";
        if (!objects.containsKey(hashName)) {
          cloned.properties[SchemaProperties.serialName] = hashName;
          objects[hashName] = visit(cloned, true) as SchemaObject;
        }
        return SchemaReference(hashName)..nullable = type.nullable;
      case SchemaArray():
        return type.clone()..items = visit(type.items, false);
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

  static DogsMaterializer get([DogEngine? engine]) {
    engine ??= DogEngine.instance;
    final instance = engine.getMetaOrNull<DogsMaterializer>();
    if (instance != null) return instance;
    return configure(engine: engine);
  }

  static DogsMaterializer configure({DogEngine? engine}) {
    engine ??= DogEngine.instance;
    final materializer = DogsMaterializer(engine);
    engine.setMeta<DogsMaterializer>(materializer);
    return materializer;
  }

  MaterializedConverter materialize(SchemaType type) {
    final forked = engine.fork();
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
            var field = _materializeField(forked, e);
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
      forked.registerAutomatic(converter);
    }
    final converter = forked.findConverterBySerialName(rootSerialName)!;
    final structure = forked.findStructureBySerialName(rootSerialName)!;
    final nativeMode =
        forked.modeRegistry.nativeSerialization.forConverter(converter, forked);
    final serializer =
        MaterializedConverter(forked, converter, nativeMode, structure, type);
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
        RuntimeEnumConverter(enumProperty, "${field.name}Enum")
      ));
    }

    final structureField = DogStructureField(
      materializedTypeTree,
      null,
      field.name,
      field.type.nullable,
      true,
      annotations
    );
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
