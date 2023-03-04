import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
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

  Future generateForEnum(
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
            "(e) => ${codeContext.typeName(element.thisType)}.values.firstWhereOrNull((element) => element.name == e)")));
    });
    codeContext.codeBuffer.writeln(clazz.accept(emitter));
  }

  Future generateForClass(
      ClassElement element,
      SubjectGenContext<Element> genContext,
      SubjectCodeContext codeContext) async {
    codeContext.additionalImports
        .add(AliasImport.gen("package:lyell/lyell.dart"));

    var constructorName = "";
    var constructor = element.unnamedConstructor!;
    if (element.getNamedConstructor("dog") != null) {
      constructorName = ".dog";
      constructor = element.getNamedConstructor("dog")!;
    }
    var structurized = await structurize(
        element.thisType, constructor, genContext, codeContext.cachedCounter);
    codeContext.additionalImports.addAll(structurized.imports);

    writeGeneratedConverter(
        element, structurized, constructorName, codeContext);
    writeGeneratedBuilder(element, structurized, constructorName, codeContext);
    writeGeneratedExtension(
        element, structurized, constructorName, codeContext);
  }

  void writeGeneratedConverter(
      ClassElement element,
      StructurizeResult structurized,
      String constructorName,
      SubjectCodeContext codeContext) {
    var emitter = DartEmitter();
    var converterName = "${element.name}Converter";
    var clazz = Class((builder) {
      builder.name = converterName;

      builder.extend = Reference(
          "$genAlias.DefaultStructureConverter<${codeContext.className(element)}>");

      builder.fields.add(Field((builder) => builder
        ..name = "structure"
        ..type = Reference(
            "$genAlias.DogStructure<${codeContext.className(element)}>")
        ..annotations.add(CodeExpression(Code("override")))
        ..assignment = Code(
            "const ${structurized.structure.code(structurized.fieldNames.map((e) => "_$e").toList())}")
        ..modifier = FieldModifier.final$));

      for (var value in structurized.fieldNames) {
        builder.methods.add(Method((builder) => builder
          ..name = "_$value"
          ..returns = Reference("dynamic")
          ..requiredParameters.add(Parameter((builder) => builder
            ..type = Reference(codeContext.className(element))
            ..name = "obj"))
          ..static = true
          ..lambda = true
          ..body = Code("obj.$value")));
      }

      builder.methods.add(Method((builder) => builder
        ..name = "_activator"
        ..returns = Reference(codeContext.className(element))
        ..requiredParameters.add(Parameter((builder) => builder
          ..type = Reference("List")
          ..name = "list"))
        ..static = true
        ..lambda = true
        ..body = Code(structurized.activator)));
    });
    codeContext.codeBuffer.writeln(clazz.accept(emitter));
  }

  void writeGeneratedBuilder(
      ClassElement element,
      StructurizeResult structurized,
      String constructorName,
      SubjectCodeContext codeContext) {
    var emitter = DartEmitter();
    var builderName = "${element.name}Builder";
    var clazz = Class((builder) {
      builder.name = builderName;

      builder.extend =
          Reference("$genAlias.Builder<${codeContext.className(element)}>");

      builder.constructors.add(Constructor((builder) => builder
        ..requiredParameters.add(Parameter((builder) => builder
          ..toSuper = true
          ..name = "\$src"))));

      for (var element in structurized.structure.fields) {
        builder.methods.add(Method((builder) => builder
          ..name = element.name
          ..type = MethodType.setter
          ..requiredParameters.add(Parameter((builder) => builder
            ..name = "value"
            ..type = Reference(element.type)))
          ..body = Code("\$overrides['${element.name}'] = value;")));
      }
    });
    codeContext.codeBuffer.writeln(clazz.accept(emitter));
  }

  void writeGeneratedExtension(
      ClassElement element,
      StructurizeResult structurized,
      String constructorName,
      SubjectCodeContext codeContext) {
    var emitter = DartEmitter();
    var extensionName = "${element.name}DogsExtension";
    var builderName = "${element.name}Builder";
    var clazz = Extension((builder) {
      builder.name = extensionName;
      builder.on = Reference(element.name);
      builder.methods.add(Method((builder) => builder
        ..name = "builder"
        ..returns = Reference(element.name)
        ..requiredParameters.add(Parameter((builder) => builder
          ..name = "func"
          ..type = Reference("Function($builderName builder)")))
        ..body = Code("""
          var builder = $builderName(this);
          func(builder);
          return builder.build();
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
