import 'package:analyzer/dart/element/element.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:dogs_core/dogs_core.dart';

import 'package:dogs_generator/dogs_generator.dart';

class ConverterBuilder extends DogsAdapter {
  ConverterBuilder() : super(archetype: "conv", annotation: Serializable);

  @override
  Future<DogBinding> generateBinding(DogGenContext context) async {
    var binding = context.defaultBinding(this);
    binding.converterNames =
        context.elements.map((e) => "${e.element.name}Converter").toList();
    return binding;
  }

  @override
  Future<void> generateConverters(
      DogGenContext genContext, DogsCodeContext codeContext) async {
    StructurizeCounter counter = StructurizeCounter();
    codeContext.additionalImports
        .add(AliasImport.gen("package:dogs_core/dogs_core.dart"));
    for (var value in genContext.elements) {
      var element = value.element;
      if (element is ClassElement) {
        await generateForClass(element, counter, genContext, codeContext);
      } else if (element is EnumElement) {
        await generateForEnum(element, genContext, codeContext);
      }
    }
  }

  Future generateForEnum(EnumElement element, DogGenContext genContext,
      DogsCodeContext codeContext) async {
    var emitter = DartEmitter();
    var converterName = "${element.name}Converter";
    var clazz = Class((builder) {
      builder.name = converterName;

      builder.extend =
          Reference("$genAlias.GeneratedEnumDogConverter<${element.name}>");

      builder.methods.add(Method((builder) => builder
        ..name = "toStr"
        ..type = MethodType.getter
        ..returns = Reference("$genAlias.EnumToString<${element.name}> ")
        ..annotations.add(CodeExpression(Code("override")))
        ..lambda = true
        ..body =
            Code("(e) => e.toString().replaceFirst('${element.name}.', '')")));

      builder.methods.add(Method((builder) => builder
        ..name = "fromStr"
        ..type = MethodType.getter
        ..returns = Reference("$genAlias.EnumFromString<${element.name}> ")
        ..annotations.add(CodeExpression(Code("override")))
        ..lambda = true
        ..body = Code(
            "(e) => ${element.name}.values.firstWhereOrNull((element) => element.name == e)")));
    });
    codeContext.codeBuffer.writeln(clazz.accept(emitter));
  }

  Future generateForClass(ClassElement element, StructurizeCounter counter,
      DogGenContext genContext, DogsCodeContext codeContext) async {
    var structurized = await structurize(element.thisType, genContext, counter);
    codeContext.additionalImports.addAll(structurized.imports);
    var emitter = DartEmitter();
    var converterName = "${element.name}Converter";
    var clazz = Class((builder) {
      builder.name = converterName;

      builder.extend =
          Reference("$genAlias.GeneratedDogConverter<${element.name}>");

      builder.methods.add(Method((builder) => builder
        ..name = "structure"
        ..type = MethodType.getter
        ..returns = Reference("$genAlias.DogStructure")
        ..annotations.add(CodeExpression(Code("override")))
        ..lambda = true
        ..body = Code("const ${structurized.structure.code}")));

      builder.methods.add(Method((builder) => builder
        ..name = "getters"
        ..type = MethodType.getter
        ..returns = Reference("List<$genAlias.FieldGetter>")
        ..annotations.add(CodeExpression(Code("override")))
        ..lambda = true
        ..body = Code(
            "[${structurized.structure.fields.map((e) => e.accessor).join(", ")}]")));

      builder.methods.add(Method((builder) => builder
        ..name = "constructorAccessor"
        ..type = MethodType.getter
        ..returns = Reference("$genAlias.ConstructorAccessor")
        ..annotations.add(CodeExpression(Code("override")))
        ..lambda = true
        ..body = Code(
            "(list) => ${element.name}(${structurized.structure.fields.mapIndexed((i, y) {
          if (y.iterableKind == IterableKind.none) return "list[$i]";
          if (y.optional) return "list[$i]?.cast<${y.serialType}>()";
          return "list[$i].cast<${y.serialType}>()";
        }).join(", ")})")));
    });
    codeContext.codeBuffer.writeln(clazz.accept(emitter));
  }
}
