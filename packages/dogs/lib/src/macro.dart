import 'dart:async';

import 'package:macros/macros.dart';
import 'package:collection/collection.dart';

typedef PrimitiveRecord = ({StaticType int, StaticType double, StaticType string, StaticType bool});

String getLibraryName(Uri uri) {
  var libraryName = uri.pathSegments.last;
  libraryName = libraryName.substring(0, libraryName.length - 5); // Remove .dart
  libraryName = libraryName.split("_") // Make camel case
      .map((e) => e[0].toUpperCase() + e.substring(1))
      .join();
  return libraryName;
}

class Default {
  final dynamic _value;
  const Default(this._value);

  dynamic get value {
    if (_value is Function) {
      return _value();
    } else {
      return _value;
    }
  }
}

macro class ModelBuilderMacro implements ClassDeclarationsMacro, ClassDefinitionMacro {

  final String uri;
  final String name;

  const ModelBuilderMacro(this.uri, this.name);

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {

    var [dartList] = await Future.wait([
      builder.resolveIdentifier(_dartCore, 'List'),
    ]);

    var sourceClassId = await builder.resolveIdentifier(Uri.parse(uri), name);
    var srcClazz = await builder.typeDeclarationOf(sourceClassId);
    var fields =  await getDogFields(srcClazz as ClassDeclaration, builder);

    // Declare source field
    builder.declareInType(DeclarationCode.fromParts([
      "final ",
      NamedTypeAnnotationCode(name: sourceClassId).asNullable.code,
      " \$src;"
    ]));

    // Declare constructor using source field. If source is null,
    // initialize with null list, otherwise initialize with source values.
    builder.declareInType(DeclarationCode.fromParts([
      clazz.identifier.name,
      "([this.\$src]) {"
          "if (\$src == null) {",
      "\$values = ",
      NamedTypeAnnotationCode(name: dartList),
      ".filled(",
      fields.length.toString(),
      ", null);",
      "} else {",
      "\$values = ",
      NamedTypeAnnotationCode(name: sourceClassId),
      ".\$values(\$src!);",
      "}}"
    ]));

    // Declare override list field
    builder.declareInType(DeclarationCode.fromParts([
      "late ",
      NamedTypeAnnotationCode(name: dartList),
      " \$values;"
    ]));

    // Declare setters for each field
    for (var field in fields) {
      var parts = <Object>[
        "set ",
        field.identifier.name,
        "(",
        field.type.code,
        " value) => \$values[",
        fields.indexOf(field).toString(),
        "] = value;"
      ];
      builder.declareInType(DeclarationCode.fromParts(parts));
    }

    // Declare a build method
    builder.declareInType(DeclarationCode.fromParts([
      NamedTypeAnnotationCode(name: srcClazz.identifier),
      " build() => ",
      NamedTypeAnnotationCode(name: srcClazz.identifier),
      ".\$activator(\$values);",
    ]));

  }

  @override
  FutureOr<void> buildDefinitionForClass(ClassDeclaration clazz, TypeDefinitionBuilder builder) {

  }
}

macro class CopyWithFrontendMacro implements ClassDeclarationsMacro {
  final String uri;
  final String name;

  const CopyWithFrontendMacro(this.uri, this.name);

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    var sourceClassId = await builder.resolveIdentifier(Uri.parse(uri), name);
    var srcClazz = await builder.typeDeclarationOf(sourceClassId);
    var fields =  await getDogFields(srcClazz as ClassDeclaration, builder);

    builder.declareInType(DeclarationCode.fromParts([
      NamedTypeAnnotationCode(name: sourceClassId),
      " call({",
      ...fields.map((e) => RawCode.fromParts([
        e.type.code.asNullable,
        " ${e.identifier.name}"
      ])).commaDelimited,
      "});"
    ]));
  }
}

macro class CopyWithImplMacro implements ClassDeclarationsMacro {
  final String uri;
  final String name;

  const CopyWithImplMacro(this.uri, this.name);

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz, MemberDeclarationBuilder builder) async {
    var sourceClassId = await builder.resolveIdentifier(Uri.parse(uri), name);
    var srcClazz = await builder.typeDeclarationOf(sourceClassId);
    var dartObject = await builder.resolveIdentifier(_dartCore, 'Object');
    var fields =  await getDogFields(srcClazz as ClassDeclaration, builder);

    builder.declareInType(DeclarationCode.fromParts([
      "final ",
      NamedTypeAnnotationCode(name: sourceClassId),
      " value;"
    ]));

    // Declare constructor
    builder.declareInType(DeclarationCode.fromParts([
      "_${sourceClassId.name}CopyWithImpl(this.value);"
    ]));

    var copyWithParams = fields.map((e) {
      if (e.type.isNullable) {
        return RawCode.fromParts([
          NamedTypeAnnotationCode(name: dartObject).asNullable,
          " ${e.identifier.name} = #not_changed"
        ]);
      } else {
        return RawCode.fromParts([
          e.type.code.asNullable,
          " ${e.identifier.name} = null"
        ]);
      }
    }).toList();

    builder.declareInType(DeclarationCode.fromParts([
      NamedTypeAnnotationCode(name: sourceClassId),
      " call({",
      ...copyWithParams.commaDelimited,
      "}) {",
      "var values = ",
      NamedTypeAnnotationCode(name: sourceClassId),
      ".\$values(value);",
      ...fields.mapIndexed((i,e) {
        var index = fields.indexOf(e);
        if (e.type.isNullable) {
          return RawCode.fromParts([
            "if (${e.identifier.name} != #not_changed) values[$index] = ${e.identifier.name};"
          ]);
        } else {
          return RawCode.fromParts([
            "if (${e.identifier.name} != null) values[$index] = ${e.identifier.name};"
          ]);
        }
      }),
      "return ",
      NamedTypeAnnotationCode(name: sourceClassId),
      "._activator(values);",
      "}"
    ]));
  }
}

macro class Model implements ClassDeclarationsMacro, ClassDefinitionMacro, ClassTypesMacro {
  const Model();

  @override
  FutureOr<void> buildTypesForClass(ClassDeclaration clazz, ClassTypeBuilder builder) async {
    var modelBuilderMacro = await builder.resolveIdentifier(_thisLibrary, 'ModelBuilderMacro');
    var copyWithFrontendMacro = await builder.resolveIdentifier(_thisLibrary, 'CopyWithFrontendMacro');
    var copyWithImplMacro = await builder.resolveIdentifier(_thisLibrary, 'CopyWithImplMacro');

    var builderName = "${clazz.identifier.name}Builder";
    builder.declareType(builderName, DeclarationCode.fromParts([
      "@",
      NamedTypeAnnotationCode(name: modelBuilderMacro),
      "('",
      clazz.library.uri.toString(),
      "','",
      clazz.identifier.name,
      "') class ",
      builderName,
      "{",
      "}"
    ]));

    var copyWithFrontendName = "_${clazz.identifier.name}CopyWithFrontend";
    var copyWithImplName = "_${clazz.identifier.name}CopyWithImpl";

    builder.declareType(copyWithImplName, DeclarationCode.fromParts([
      "@",
      NamedTypeAnnotationCode(name: copyWithImplMacro),
      "('",
      clazz.library.uri.toString(),
      "','",
      clazz.identifier.name,
      "') ",
      "final class $copyWithImplName implements $copyWithFrontendName {}"
    ]));
    builder.declareType(copyWithFrontendName, DeclarationCode.fromParts([
      "@",
      NamedTypeAnnotationCode(name: copyWithFrontendMacro),
      "('",
      clazz.library.uri.toString(),
      "','",
      clazz.identifier.name,
      "') ",
      "abstract interface class $copyWithFrontendName {}"
    ]));
  }

  @override
  FutureOr<void> buildDeclarationsForClass(ClassDeclaration clazz,
      MemberDeclarationBuilder builder) async {
    var [structure, dartList, defaultStructureImpl, builderReference, dartFunction,
    deepEquality, overrideAnnotation, dartObject, dartInt] = await Future.wait([
      builder.resolveIdentifier(_structureFile, 'DogStructure'),
      builder.resolveIdentifier(_dartCore, 'List'),
      builder.resolveIdentifier(_structureConverterFile, 'DogStructureConverterImpl'),
      builder.resolveIdentifier(clazz.library.uri, "${clazz.identifier.name}Builder"),
      builder.resolveIdentifier(_dartCore, 'Function'),
      builder.resolveIdentifier(_dogsGlobalFile, 'deepEquality'),
      builder.resolveIdentifier(_dartCore, 'override'),
      builder.resolveIdentifier(_dartCore, 'Object'),
      builder.resolveIdentifier(_dartCore, 'int'),
    ]);

    var thisClass = NamedTypeAnnotationCode(name: clazz.identifier);

    var structureType = NamedTypeAnnotationCode(
        name: structure,
        typeArguments: [thisClass]);

    var methods = await builder.methodsOf(clazz);
    var fields = await getDogFields(clazz, builder);

    // Declare Structure Getter
    builder.declareInType(DeclarationCode.fromParts(
        ["external static ", structureType, " get structure;"]));

    // Declare a static converter field using the structure getter
    builder.declareInType(DeclarationCode.fromParts([
      "static ",
      NamedTypeAnnotationCode(name: defaultStructureImpl),
      " converter = ",
      NamedTypeAnnotationCode(name: defaultStructureImpl),
      "<",
      thisClass,
      ">(structure);"
    ]));

    // Declare a builder rebuild instance method using the generated builder
    builder.declareInType(DeclarationCode.fromParts([
      NamedTypeAnnotationCode(name: clazz.identifier),
      " rebuild(",
      "Function(",
      NamedTypeAnnotationCode(name: builderReference),
      ") f) {",
      "var builder = ",
      NamedTypeAnnotationCode(name: builderReference),
      "(this);",
      "f(builder);",
      "return builder.build();",
      "}"
    ]));


    // Copy with
    var copyWithFrontend = await builder.resolveIdentifier(clazz.library.uri, '_${clazz.identifier.name}CopyWithFrontend');
    var copyWithImpl = await builder.resolveIdentifier(clazz.library.uri, '_${clazz.identifier.name}CopyWithImpl');
    builder.declareInType(DeclarationCode.fromParts([
      NamedTypeAnnotationCode(name: copyWithFrontend).name.name,
      " get copyWith => ",
      NamedTypeAnnotationCode(name: copyWithImpl).name.name,
      "(this);"
    ]));

    // <editor-fold desc="Dataclass Methods">
    // If no equals override, create one
    if (!methods.any((element) => element.identifier.name == 'equals')) {
      builder.declareInType(DeclarationCode.fromParts([
        "@",
        NamedTypeAnnotationCode(name: overrideAnnotation),
        " operator ==(",
        NamedTypeAnnotationCode(name: dartObject),
        " other) => ",
        "other is ",
        NamedTypeAnnotationCode(name: clazz.identifier),
        " && ",
        NamedTypeAnnotationCode(name: deepEquality),
        ".equals(\$values(this), \$values(other));"
      ]));
    }

    // If no hashcode override, create one
    if (!methods.any((element) => element.identifier.name == 'hash')) {
      builder.declareInType(DeclarationCode.fromParts([
        "@",
        NamedTypeAnnotationCode(name: overrideAnnotation),
        " ",
        NamedTypeAnnotationCode(name: dartInt),
        " get hashCode => ",
        NamedTypeAnnotationCode(name: deepEquality),
        ".hash(\$values(this));"
      ]));
    }
    //</editor-fold>

    //<editor-fold desc="Fields Accessors and Constructor">
    // Declare static getter for each field
    for (var field in fields) {
      var parts = <Object>[
        "static ",
        "\$get_",
        field.identifier.name,
        "(",
        thisClass,
        " obj) => obj.${field.identifier.name}",
        ";"
      ];

      builder.declareInType(DeclarationCode.fromParts(parts));
    }

    // Declare constructor with named args
    var hasDefaultConstructor = (await builder.constructorsOf(clazz))
        .any((element) {
      // TODO: Maybe check if all fields are included
      return element.identifier.name.isEmpty;
    });

    if (!hasDefaultConstructor) {
      builder.declareInType(DeclarationCode.fromParts([
        clazz.identifier.name,
        "({",
        ...fields.map((e) => "${e.type.isNullable ? "" : "required "}this.${e.identifier.name}").commaDelimited,
        "});"
      ]));
    }

    // Declare values getter
    builder.declareInType(DeclarationCode.fromParts([
      "static ",
      NamedTypeAnnotationCode(name: dartList),
      " \$values(",
      NamedTypeAnnotationCode(name: clazz.identifier),
      " obj) => [",
      ...fields.map((e) => "obj.${e.identifier.name}").commaDelimited,
      "];"
    ]));

    // Declare Factory from Dynamic Arg List
    builder.declareInType(DeclarationCode.fromParts([
      clazz.identifier.name,
      "._activator(",
      NamedTypeAnnotationCode(name: dartList),
      " list) : ",
      ...fields.mapIndexed((i,e) => "${e.identifier.name} = list[$i]").commaDelimited,
      ";"
    ]));

    // Declare a static function proxying the activator constructor.
    builder.declareInType(DeclarationCode.fromParts([
      "static ",
      NamedTypeAnnotationCode(name: clazz.identifier),
      " \$activator(",
      NamedTypeAnnotationCode(name: dartList),
      " list) => ",
      NamedTypeAnnotationCode(name: clazz.identifier),
      "._activator(list);"
    ]));
    //</editor-fold>
  }

  @override
  FutureOr<void> buildDefinitionForClass(ClassDeclaration clazz,
      TypeDefinitionBuilder builder) async {
    try {
      var structureGetter = await builder.methodsOf(clazz).then((methods) =>
          methods.firstWhere((element) =>
          element.identifier.name == 'structure' && element.isGetter));

      var [
      structure, structureConformity, qualifiedTree, dartList,
      memoryProxy, structureField, qualifiedTypeTreeN, qualifiedTerminal,
      iterableKind, retainedAnnotation, objectFactoryStructureProxy,
      dogsOptional
      ] = await Future.wait([
        builder.resolveIdentifier(_structureFile, 'DogStructure'),
        builder.resolveIdentifier(_structureFile, 'StructureConformity'),
        builder.resolveIdentifier(_qualifiedTreeFile, 'QualifiedTypeTree'),
        builder.resolveIdentifier(_dartCore, 'List'),
        builder.resolveIdentifier(_proxyFile, 'MemoryDogStructureProxy'),
        builder.resolveIdentifier(_fieldFile, 'DogStructureField'),
        builder.resolveIdentifier(_qualifiedTreeFile, 'QualifiedTypeTreeN'),
        builder.resolveIdentifier(_qualifiedTreeFile, 'QualifiedTerminal'),
        builder.resolveIdentifier(_dogsEngineFile, 'IterableKind'),
        builder.resolveIdentifier(_lyellBaseFile, 'RetainedAnnotation'),
        builder.resolveIdentifier(_proxyFile, 'ObjectFactoryStructureProxy'),
        builder.resolveIdentifier(_dogsDatatypeOptionalFile, 'Optional')
      ]);
      var primitiveRecord = await resolveSimpleTypes(builder);
      var retainedAnnotationStatic = await builder.resolve(NamedTypeAnnotationCode(name: retainedAnnotation));
      var propertyBuilder = await builder.buildMethod(structureGetter.identifier);
      var structureFields = await getDogFields(clazz, builder);

      // Create field definitions from the class fields
      List<Code> fieldDefinitions = [];
      for (var field in structureFields) {
        fieldDefinitions.add(RawCode.fromParts([
          NamedTypeAnnotationCode(name: structureField),
          "(",
          createLyellTypeTree(field.type, qualifiedTerminal, qualifiedTypeTreeN),
          ",",
          createLyellTypeTree(field.type, qualifiedTerminal, qualifiedTypeTreeN),
          ",null,",
          NamedTypeAnnotationCode(name: iterableKind),
          ".none,'",
          field.identifier.name,
          "',",
          (field.type.isNullable).toString(),
          ",",
          (!(await isSimpleType(field.type.code, builder, primitiveRecord))).toString(),
          ",",
          await createMetaList(field.metadata, retainedAnnotationStatic, builder),
          ")"
        ]));
      }

      // Construct the final structure definition using the field definitions
      propertyBuilder.augment(FunctionBodyCode.fromParts([
        "=> const ",
        structure,
        "<",
        NamedTypeAnnotationCode(name: clazz.identifier),
        ">('",
        clazz.identifier.name,
        "',",
        NamedTypeAnnotationCode(name: structureConformity),
        ".basic, [",
        ...fieldDefinitions.commaDelimited,
        "],",
        await createMetaList(clazz.metadata, retainedAnnotationStatic, builder),
        ", ",
        NamedTypeAnnotationCode(name: objectFactoryStructureProxy, typeArguments: [
          NamedTypeAnnotationCode(name: clazz.identifier)
        ]),
        "(",
        "\$activator, [",
        ...structureFields.map((e) => "\$get_${e.identifier.name}").commaDelimited,
        "], \$values));",
      ]));
    } catch (ex, st) {
      builder.report(Diagnostic(DiagnosticMessage("$ex: $st"), Severity.error));
    }
  }

  /// Create a record of all simple types from the dart core library that
  /// can be automatically serialized by the dogs engine.
  Future<PrimitiveRecord> resolveSimpleTypes(DefinitionPhaseIntrospector intro) async {
    var futures = [
      intro.resolveIdentifier(_dartCore, 'int'),
      intro.resolveIdentifier(_dartCore, 'double'),
      intro.resolveIdentifier(_dartCore, 'String'),
      intro.resolveIdentifier(_dartCore, 'bool')
    ];
    var identifiers = await Future.wait(futures);
    var types = await Future.wait(identifiers
        .map((e) => intro.resolve(NamedTypeAnnotationCode(name: e))));
    return (
    int: types[0],
    double: types[1],
    string: types[2],
    bool: types[3]
    );
  }

  Future<bool> isSimpleType(TypeAnnotationCode code, DefinitionPhaseIntrospector intro, PrimitiveRecord record) async {
    if (code is NullableTypeAnnotationCode) {
      code = code.underlyingType;
    }
    var type = await intro.resolve(code);
    return await type.isSubtypeOf(record.int) ||
        await type.isSubtypeOf(record.double) ||
        await type.isSubtypeOf(record.string) ||
        await type.isSubtypeOf(record.bool);
  }

  /// Create valid code to construct a list of all retained annotations of
  /// a metadata iterable. Takes the [StaticType] for the retained annotation
  /// as well as a definition-stage builder.
  Future<Code> createMetaList(Iterable<MetadataAnnotation> metadata, StaticType retainedAnnotationType, DefinitionBuilder builder) async {
    var parts = <Object>["["];
    for (var meta in metadata) {
      if (meta is ConstructorMetadataAnnotation) {
        var type = await builder.resolve(meta.type.code);
        if (await type.isSubtypeOf(retainedAnnotationType)) {
          parts.add(recreateAnnotation(meta));
          parts.add(",");
        }
      } else if (meta is IdentifierMetadataAnnotation) {
        var dec = await builder.declarationOf(meta.identifier);
        if (dec is FunctionDeclaration) {
          var type = await builder.resolve(dec.returnType.code);
          if (await type.isSubtypeOf(retainedAnnotationType)) {
            parts.add(recreateAnnotation(meta));
            parts.add(",");
          }
        }
      }
    }
    parts.add("]");
    return RawCode.fromParts(parts);
  }

  /// Tries to recreate an annotation to make it accessible at runtime.
  /// Note: This only works from the definition phase on, since const field
  /// annotation can't be reconstructed at this point.
  Code recreateAnnotation(MetadataAnnotation annotation) {
    if (annotation is ConstructorMetadataAnnotation) {
      var parts = <Object>[annotation.type.code, "("];
      for (var arg in annotation.positionalArguments) {
        parts.add(arg);
        parts.add(",");
      }
      for (var arg in annotation.namedArguments.entries) {
        parts.add(arg.key);
        parts.add(":");
        parts.add(arg.value);
        parts.add(",");
      }
      parts.add(")");
      return RawCode.fromParts(parts);
    } else if (annotation is IdentifierMetadataAnnotation) {
      return NamedTypeAnnotationCode(name: annotation.identifier);
    }

    throw ArgumentError.value(annotation, 'annotation', 'Unsupported annotation');
  }

  /// Create the code for a lyell qualified type tree from a type annotation.
  /// Requires the identifiers for terminal and narg type trees from the lyell
  /// package.
  Code createLyellTypeTree(TypeAnnotation annotation, Identifier qtId,
      Identifier ttnId) {
    if (annotation is! NamedTypeAnnotation) {
      throw ArgumentError.value(
          annotation, 'annotation', 'Must be a NamedTypeAnnotation');
    }
    var argCodes = annotation.typeArguments.map((e) =>
        createLyellTypeTree(e, qtId, ttnId)).toList();

    if (argCodes.isEmpty) {
      return RawCode.fromParts([
        NamedTypeAnnotationCode(name: qtId,
            typeArguments: [
              NamedTypeAnnotationCode(name: annotation.identifier)
            ]),
        "()"
      ]);
    } else {
      return RawCode.fromParts([
        NamedTypeAnnotationCode(name: ttnId, typeArguments: [
          annotation.code,
          NamedTypeAnnotationCode(name: annotation.identifier)]),
        "([",
        ...argCodes.commaDelimited,
        "])"
      ]);
    }
  }
}

/*
// TODO: This doesn't work, I don't think this is my fault though
// I'm just using using stuff here the demo is also using. (which also doesn't
// currently work)
macro class ModelModule implements LibraryTypesMacro {

  final List<TypeAnnotation> types;

  const ModelModule(this.types);

  @override
  FutureOr<void> buildTypesForLibrary(Library library, TypeBuilder builder) async {
    var dogConverter = await builder.resolveIdentifier(_dogsConverterFile, 'DogConverter');
    var dogEngine = await builder.resolveIdentifier(_dogsEngineFile, 'DogEngine');
    var name = "${getLibraryName(library.uri)}Module";

    builder.declareType(name, DeclarationCode.fromParts([
      "class $name {",
      "void register(",
      NamedTypeAnnotationCode(name: dogEngine),
      " engine) => engine.registerAll([",
      ...types.map((e) => RawCode.fromParts([
        e.code,
        ".converter",
      ])).commaDelimited,
      "]);",
      "}"
    ]));
  }
}

 */

Future<List<FieldDeclaration>> getDogFields(ClassDeclaration clazz, DeclarationPhaseIntrospector introspector) async {
  var fields = await introspector.fieldsOf(clazz);
  fields.removeWhere((element) => element.hasStatic);
  // TODO: Maybe add ignore annotations later.
  return fields;
}

final _dartCore = Uri.parse("dart:core");
final _thisLibrary = Uri.parse("package:dogs_core/src/macro.dart");
final _structureFile =
Uri.parse("package:dogs_core/src/structure/structure.dart");
final _lyellBaseFile = Uri.parse("package:lyell/src/lyell_base.dart");
final _qualifiedTreeFile = Uri.parse("package:lyell/src/qualified_tree.dart");
final _proxyFile = Uri.parse("package:dogs_core/src/structure/proxy.dart");
final _fieldFile = Uri.parse("package:dogs_core/src/structure/field.dart");
final _dogsEngineFile = Uri.parse("package:dogs_core/src/engine.dart");
final _dogsConverterFile = Uri.parse("package:dogs_core/src/converter.dart");
final _dogsDataclassFile = Uri.parse("package:dogs_core/src/dataclass.dart");
final _structureConverterFile = Uri.parse("package:dogs_core/src/structure/converter.dart");
final _dogsGlobalFile = Uri.parse("package:dogs_core/src/global.dart");
final _dogsDatatypeOptionalFile = Uri.parse("package:dogs_core/src/datatype/optional.dart");

extension _ITE<T> on Iterable<T> {

  List<Object> get commaDelimited {
    if (isEmpty) return [];
    return expand((e) => [e!, ","]).skipLast(1).toList();
  }

  List<T> skipLast(int n) {
    final list = toList();
    if (n == 0) return list;
    if (n >= list.length) return [];
    return list.sublist(0, list.length - n);
  }
}