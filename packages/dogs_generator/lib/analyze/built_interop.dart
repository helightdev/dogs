/*
 *    Copyright 2022, the DOGs authors
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_generator/analyze/structurize.dart';
import 'package:lyell_gen/lyell_gen.dart' as lyell;
import 'package:lyell_gen/lyell_gen.dart';
import 'package:source_gen/source_gen.dart';

import 'introspect.dart';

late LibraryReader _builtValueLibrary;
late LibraryReader _builtCollectionLibrary;

late TypeChecker builtChecker;
late TypeChecker builtBuilderChecker;
late TypeChecker listBuilderChecker;
late TypeChecker mapBuilderChecker;
late TypeChecker setBuilderChecker;
late TypeChecker builtValueFieldChecker;
late TypeChecker builtValueEnumChecker;

late InterfaceElement builtInterface;
late InterfaceElement builtBuilderInterface;

late InterfaceElement listBuilderInterface;
late InterfaceElement mapBuilderInterface;
late InterfaceElement setBuilderInterface;

bool hasBuiltInterop = false;

Future tryInitializeBuiltInterop(BuildStep step) async {
  var builtValueAsset =
      AssetId.resolve(Uri.parse("package:built_value/built_value.dart"));
  var builtCollectionAsset = AssetId.resolve(
      Uri.parse("package:built_collection/built_collection.dart"));
  if (!(await step.canRead(builtValueAsset) &&
      await step.canRead(builtCollectionAsset))) {
    hasBuiltInterop = false;
    return;
  }

  var builtValueLibrary = await step.resolver.libraryFor(builtValueAsset);
  var builtCollectionLibrary =
      await step.resolver.libraryFor(builtCollectionAsset);
  _builtValueLibrary = LibraryReader(builtValueLibrary);
  _builtCollectionLibrary = LibraryReader(builtCollectionLibrary);

  builtInterface = _builtValueLibrary.findType("Built") as InterfaceElement;
  builtBuilderInterface =
      _builtValueLibrary.findType("Builder") as InterfaceElement;
  listBuilderInterface =
      _builtCollectionLibrary.findType("ListBuilder") as InterfaceElement;
  mapBuilderInterface =
      _builtCollectionLibrary.findType("MapBuilder") as InterfaceElement;
  setBuilderInterface =
      _builtCollectionLibrary.findType("SetBuilder") as InterfaceElement;

  builtChecker = TypeChecker.fromStatic(builtInterface.thisType);
  builtBuilderChecker = TypeChecker.fromStatic(builtBuilderInterface.thisType);
  listBuilderChecker = TypeChecker.fromStatic(listBuilderInterface.thisType);
  mapBuilderChecker = TypeChecker.fromStatic(mapBuilderInterface.thisType);
  setBuilderChecker = TypeChecker.fromStatic(setBuilderInterface.thisType);
  builtValueFieldChecker = TypeChecker.fromStatic(
      _builtValueLibrary.findType("BuiltValueField")!.thisType);
  builtValueEnumChecker = TypeChecker.fromStatic(
      _builtValueLibrary.findType("EnumClass")!.thisType);

  hasBuiltInterop = true;
}

Future<IRStructure> structurizeBuilt(SubjectCodeContext codeContext,
    SubjectGenContext context, ClassElement element) async {
  var counter = codeContext.cachedCounter;
  var builtInterfaceImpl = element.thisType.asInstanceOf(builtInterface)!;
  var builderElement =
      builtInterfaceImpl.typeArguments[1].element! as ClassElement;

  var getters = builderElement.accessors
      .where((element) =>
          element.isGetter && element.isPublic && !element.isStatic)
      .toList();

  var fields = <IRStructureField>[];
  for (var builderGetter in getters) {
    var fieldGetter = element.getGetter(builderGetter.name)!;
    var fieldName = fieldGetter.name;
    var fieldType = fieldGetter.returnType;
    var serialType = await getSerialType(fieldType, context);
    var iterableType = await getIterableType(fieldType, context);

    var optional = fieldType.nullabilitySuffix == NullabilitySuffix.question;
    if (fieldType is DynamicType) optional = true;

    var builtValueFieldAnnotation = fieldGetter.metadata
        .whereTypeChecker(builtValueFieldChecker)
        .firstOrNull
        ?.computeConstantValue();

    var propertyName = fieldName;
    if (builtValueFieldAnnotation != null) {
      var reader = ConstantReader(builtValueFieldAnnotation);
      var wireName = reader.read("wireName");
      if (!wireName.isNull) propertyName = wireName.stringValue;
    }

    fields.add(IRStructureField(
        fieldName,
        counter.get(fieldType),
        getTypeTree(fieldType).code(counter),
        "null",
        counter.get(serialType),
        iterableType,
        propertyName,
        optional,
        !isDogPrimitiveType(serialType),
        getRetainedAnnotationSourceArray(fieldGetter, counter),
        lyell.mapChecker.isAssignableFromType(fieldType)));
  }

  return IRStructure(
    codeContext.className(element),
    StructureConformity.basic,
    element.name,
    fields,
    getRetainedAnnotationSourceArray(element, counter),
  );
}

Future<void> writeBuiltInteropConverter(ClassElement element,
    SubjectCodeContext codeContext, SubjectGenContext context) async {
  codeContext.additionalImports
      .add(AliasImport.gen("package:dogs_core/dogs_core.dart"));
  codeContext.additionalImports
      .add(AliasImport.gen("package:dogs_built/dogs_built.dart"));
  codeContext.additionalImports
      .add(AliasImport.gen("package:built_collection/built_collection.dart"));

  var builtInterfaceImpl = element.thisType.asInstanceOf(builtInterface)!;
  var builderElement =
      builtInterfaceImpl.typeArguments[1].element! as ClassElement;

  var structure = await structurizeBuilt(codeContext, context, element);
  var typeRef = codeContext.typeName(element.thisType);
  var emitter = DartEmitter();
  var clazz = Class((builder) {
    builder.name = "${element.name}Converter";
    builder.extend =
        Reference("$genAlias.GeneratedBuiltInteropConverter<$typeRef>");

    builder.constructors.add(Constructor((constr) => constr
      ..initializers.add(Code(
          "super(struct: const ${structure.code(structure.fields.map((e) => "_\$${e.accessor}").toList())})"))));

    builder.methods.add(Method((builder) => builder
      ..name = "_values"
      ..returns = Reference("List<dynamic>")
      ..requiredParameters.add(Parameter((builder) => builder
        ..type = Reference(codeContext.className(element))
        ..name = "obj"))
      ..static = true
      ..lambda = true
      ..body = Code(
          "[${structure.fields.map((e) => "obj.${e.accessor}").join(",")}]")));

    for (var value in structure.fields.map((e) => e.accessor)) {
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
      ..name = "_activator"
      ..returns = Reference(codeContext.className(element))
      ..requiredParameters.add(Parameter((builder) => builder
        ..type = Reference("List")
        ..name = "list"))
      ..static = true
      ..lambda = false
      ..body = Code(
          "return (${typeRef}Builder()\n${builderElement.accessors.where((element) => element.isGetter && element.isPublic && !element.isStatic).mapIndexed((i, e) {
        if (listBuilderChecker.isAssignableFromType(e.returnType)) {
          var innerType =
              e.returnType.asInstanceOf(listBuilderInterface)!.typeArguments[0];
          return "..${e.name} = list[$i] == null ? null : gen.ListBuilder<${codeContext.typeName(innerType)}>(list[$i])";
        } else if (setBuilderChecker.isAssignableFromType(e.returnType)) {
          var innerType =
              e.returnType.asInstanceOf(setBuilderInterface)!.typeArguments[0];
          return "..${e.name} = list[$i] == null ? null : gen.SetBuilder<${codeContext.typeName(innerType)}>(list[$i])";
        } else if (mapBuilderChecker.isAssignableFromType(e.returnType)) {
          var typeArguments =
              e.returnType.asInstanceOf(mapBuilderInterface)!.typeArguments;
          return "..${e.name} = list[$i] == null ? null : gen.MapBuilder<${codeContext.typeName(typeArguments[0])}, ${codeContext.typeName(typeArguments[1])}>(list[$i])";
        }
        return "..${e.name} = list[$i]";
      }).join("\n")}).build();")));
  });
  codeContext.codeBuffer.writeln(clazz.accept(emitter));
}
