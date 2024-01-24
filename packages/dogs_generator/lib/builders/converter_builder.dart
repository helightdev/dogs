import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:dogs_core/dogs_core.dart';

import 'package:dogs_generator/dogs_generator.dart';
import 'package:lyell_gen/lyell_gen.dart';

class ConverterBuilder extends DogsAdapter<Serializable> {
  ConverterBuilder() : super(archetype: "conv");

  @override
  Future<SubjectDescriptor> generateDescriptor(
      SubjectGenContext<Element> context) async {
    var binding = context.defaultDescriptor();
    binding.meta["converterNames"] =
        context.matches.map((e) => "${e.name}Converter").toList();
    return binding;
  }

  static Future generateForEnum(
      EnumElement element,
      SubjectGenContext<Element> genContext,
      SubjectCodeContext codeContext) async {
    var emitter = DartEmitter();
    var converterName = "${element.name}Converter";
    var clazz = Class((builder) {
      builder.name = converterName;

      builder.extend = Reference(
          "$genAlias.GeneratedEnumDogConverter<${codeContext.typeName(element.thisType)}>");

      builder.methods.add(Method((builder) => builder
        ..name = "values"
        ..type = MethodType.getter
        ..returns = Reference("List<String>")
        ..annotations.add(CodeExpression(Code("override")))
        ..lambda = true
        ..body = Code(
            "${codeContext.typeName(element.thisType)}.values.map((e) => e.name).toList()")));

      builder.methods.add(Method((builder) => builder
        ..name = "toStr"
        ..type = MethodType.getter
        ..returns = Reference(
            "$genAlias.EnumToString<${codeContext.typeName(element.thisType)}> ")
        ..annotations.add(CodeExpression(Code("override")))
        ..lambda = true
        ..body = Code("(e) => e!.name")));

      builder.methods.add(Method((builder) => builder
        ..name = "fromStr"
        ..type = MethodType.getter
        ..returns = Reference(
            "$genAlias.EnumFromString<${codeContext.typeName(element.thisType)}> ")
        ..annotations.add(CodeExpression(Code("override")))
        ..lambda = true
        ..body = Code(
            "(e) => ${codeContext.typeName(element.thisType)}.values.firstWhereOrNullDogs((element) => element.name == e)")));
    });
    codeContext.codeBuffer.writeln(clazz.accept(emitter));
  }

  static Future generateForClass(
      ClassElement element,
      SubjectGenContext<Element> genContext,
      SubjectCodeContext codeContext) async {
    codeContext.additionalImports
        .add(AliasImport.gen("package:lyell/lyell.dart"));

    var constructorName = "";
    var constructor = element.unnamedConstructor;
    if (element.getNamedConstructor("dog") != null) {
      constructorName = ".dog";
      constructor = element.getNamedConstructor("dog");
    }
    StructurizeResult structurized;
    if (constructor != null && constructor.parameters.isNotEmpty) {
      // Create constructor based serializable
      structurized = await structurizeConstructor(
          element.thisType, constructor, genContext, codeContext.cachedCounter);
      codeContext.additionalImports.addAll(structurized.imports);
    } else if (constructor != null) {
      // Create bean like property based serializable
      structurized = await structurizeBean(
          element.thisType, element, genContext, codeContext.cachedCounter);
      codeContext.additionalImports.addAll(structurized.imports);
      writeBeanFactory(element, structurized, codeContext);
    } else {
      throw Exception("No accessible constructor");
    }

    writeGeneratedConverter(
        element, structurized, constructorName, codeContext);
    if (structurized.fieldNames.isNotEmpty &&
        structurized.structure.conformity != StructureConformity.bean) {
      writeGeneratedBuilder(
          element, structurized, constructorName, codeContext);
      writeGeneratedExtension(
          element, structurized, constructorName, codeContext);
    }
  }

  static void writeBeanFactory(ClassElement element,
      StructurizeResult structurized, SubjectCodeContext codeContext) {
    var emitter = DartEmitter();
    var factoryName = "${element.name}Factory";
    var clazz = Class((builder) {
      builder.name = factoryName;
      builder.methods.add(Method((builder) {
        builder.optionalParameters.addAll(structurized.structure.fields
            .map((e) => Parameter((builder) => builder
              ..named = true
              ..required = !e.optional
              ..type = Reference(e.type + (e.optional ? "?" : ""))
              ..name = e.name)));

        builder
          ..name = "create"
          ..returns = Reference(codeContext.className(element))
          ..static = true
          ..lambda = false
          ..body = Code(
              "var obj = ${codeContext.className(element)}();${structurized.structure.fields.mapIndexed((i, e) => "obj.${e.name} = ${e.name};").join("\n")} return obj;");
      }));
    });

    codeContext.codeBuffer.writeln(clazz.accept(emitter));
  }

  static void writeGeneratedConverter(
      ClassElement element,
      StructurizeResult structurized,
      String constructorName,
      SubjectCodeContext codeContext) {
    var emitter = DartEmitter();
    var converterName = "${element.name}Converter";
    var clazz = Class((builder) {
      builder.name = converterName;

      bool hasGenericTypeVariables = element.thisType.typeArguments.isNotEmpty;
      if (hasGenericTypeVariables) {
        log.severe("""
Generic type variables for models are not supported.
If you wish to use class-level generics, please implement a TreeBaseConverterFactory for your base type.
        """.trim());
      }

      var referencedClassName = codeContext.className(element);
      builder.extend = Reference(
          "$genAlias.DefaultStructureConverter<${codeContext.className(element)}>");

      builder.constructors.add(Constructor((constr) => constr
        ..initializers.add(Code(
            "super(struct: const ${structurized.structure.code(structurized.fieldNames.map((e) => "_\$$e").toList())})"))));

      _defaultProxyMethods(structurized, builder, codeContext, element);

      if (structurized.structure.conformity == StructureConformity.dataclass) {
        _dataclassProxyMethods(builder, codeContext, element, structurized);
      }
    });
    codeContext.codeBuffer.writeln(clazz.accept(emitter));
  }

  static void _defaultProxyMethods(
      StructurizeResult structurized,
      ClassBuilder builder,
      SubjectCodeContext codeContext,
      ClassElement element) {
    for (var value in structurized.fieldNames) {
      builder.methods.add(Method((builder) => builder
        ..name = "_\$$value"
        ..returns = Reference("dynamic")
        ..requiredParameters.add(Parameter((builder) => builder
          ..type = Reference(codeContext.className(element))
          ..name = "obj"))
        ..static = true
        ..lambda = true
        ..body = Code("obj.$value")));
    }

    builder.methods.add(Method((builder) => builder
      ..name = "_values"
      ..returns = Reference("List<dynamic>")
      ..requiredParameters.add(Parameter((builder) => builder
        ..type = Reference(codeContext.className(element))
        ..name = "obj"))
      ..static = true
      ..lambda = true
      ..body =
          Code("[${structurized.fieldNames.map((e) => "obj.$e").join(",")}]")));

    builder.methods.add(Method((builder) => builder
      ..name = "_activator"
      ..returns = Reference(codeContext.className(element))
      ..requiredParameters.add(Parameter((builder) => builder
        ..type = Reference("List")
        ..name = "list"))
      ..static = true
      ..lambda = false
      ..body = Code(structurized.activator)));
  }

  static void _dataclassProxyMethods(
      ClassBuilder builder,
      SubjectCodeContext codeContext,
      ClassElement element,
      StructurizeResult structurized) {
    builder.methods.add(Method((builder) => builder
      ..name = "_hash"
      ..returns = Reference("int")
      ..requiredParameters.add(Parameter((builder) => builder
        ..type = Reference(codeContext.className(element))
        ..name = "obj"))
      ..static = true
      ..lambda = true
      ..body = Code(structurized.structure.fields.map((e) {
        var index = structurized.structure.fields.indexOf(e);
        var fieldName = structurized.fieldNames[index];
        if (e.iterableKind != IterableKind.none || e.$isMap) {
          return "$genAlias.deepEquality.hash(obj.$fieldName)";
        } else {
          return "obj.$fieldName.hashCode";
        }
      }).join("^"))));

    builder.methods.add(Method((builder) => builder
      ..name = "_equals"
      ..returns = Reference("bool")
      ..requiredParameters.add(Parameter((builder) => builder
        ..type = Reference(codeContext.className(element))
        ..name = "a"))
      ..requiredParameters.add(Parameter((builder) => builder
        ..type = Reference(codeContext.className(element))
        ..name = "b"))
      ..static = true
      ..lambda = true
      ..body = Code("(${structurized.structure.fields.map((e) {
        var index = structurized.structure.fields.indexOf(e);
        var fieldName = structurized.fieldNames[index];
        if (e.iterableKind != IterableKind.none || e.$isMap) {
          return "$genAlias.deepEquality.equals(a.$fieldName, b.$fieldName)";
        } else {
          return "a.$fieldName == b.$fieldName";
        }
      }).join("&&")})")));
  }

  static void writeGeneratedBuilder(
      ClassElement element,
      StructurizeResult structurized,
      String constructorName,
      SubjectCodeContext codeContext) {
    var emitter = DartEmitter();
    var builderName = "${element.name}Builder";
    var clazz = Class((builder) {
      builder.name = builderName;

      builder.fields.add(Field((builder) => builder
        ..name = "\$values"
        ..type = Reference("late List<dynamic>")));

      builder.constructors.add(Constructor((builder) => builder
        ..optionalParameters.add(Parameter((builder) => builder
          ..type = Reference("${codeContext.className(element)}?")
          ..name = "\$src"))
        ..body = Code(
            "if (\$src == null) {\$values = List.filled(${structurized.fieldNames.length},null);} else {\$values = ${element.name}Converter._values(\$src);}")));

      for (var element in structurized.structure.fields) {
        var index = structurized.structure.fields.indexOf(element);
        builder.methods.add(Method((builder) => builder
          ..name = element.accessor
          ..type = MethodType.setter
          ..requiredParameters.add(Parameter((builder) => builder
            ..name = "value"
            ..type = Reference(element.type + (element.optional ? "?" : ""))))
          ..body = Code("\$values[$index] = value;")));

        builder.methods.add(Method((builder) => builder
          ..name = element.accessor
          ..type = MethodType.getter
          ..returns = Reference(element.type + (element.optional ? "?" : ""))
          ..lambda = true
          ..body = Code("\$values[$index]")));
      }

      builder.methods.add(Method((builder) => builder
        ..name = "build"
        ..returns = Reference(codeContext.className(element))
        ..lambda = true
        ..body = Code("${element.name}Converter._activator(\$values)")));
    });
    codeContext.codeBuffer.writeln(clazz.accept(emitter));
  }

  static void writeGeneratedExtension(
      ClassElement element,
      StructurizeResult structurized,
      String constructorName,
      SubjectCodeContext codeContext) {
    var emitter = DartEmitter();
    var extensionName = "${element.name}DogsExtension";
    var builderName = "${element.name}Builder";
    var clazz = Extension((builder) {
      builder.name = extensionName;
      var structureType =
          Reference(codeContext.cachedCounter.get(element.thisType));
      builder.on = structureType;

      builder.methods.add(Method((builder) => builder
        ..name = "rebuild"
        ..returns = structureType
        ..requiredParameters.add(Parameter((builder) => builder
          ..name = "f"
          ..type = Reference("Function($builderName b)")))
        ..body = Code("""
          var builder = $builderName(this);
          f(builder);
          return builder.build();
          """)));

      builder.methods.add(Method((builder) => builder
        ..name = "toBuilder"
        ..returns = Reference(builderName)
        ..body = Code("""
          return $builderName(this);
          """)));

      builder.methods.add(Method((builder) => builder
        ..name = "toNative"
        ..returns = Reference("Map<String,dynamic>")
        ..body = Code("""
          return $genAlias.dogs.convertObjectToNative(this, ${codeContext.cachedCounter.get(element.thisType)});
          """)));
    });
    codeContext.codeBuffer.writeln(clazz.accept(emitter));
  }

  @override
  FutureOr<void> generateSubject(SubjectGenContext<Element> genContext,
      SubjectCodeContext codeContext) async {
    codeContext.additionalImports
        .add(AliasImport.gen("package:dogs_core/dogs_core.dart"));

    try {
      for (var element in genContext.matches) {
        if (element is ClassElement) {
          await generateForClass(element, genContext, codeContext);
        } else if (element is EnumElement) {
          await generateForEnum(element, genContext, codeContext);
        }
      }
    } catch (e, s) {
      print("$e: $s");
    }
  }
}
