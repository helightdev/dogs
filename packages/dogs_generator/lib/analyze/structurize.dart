import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dogs/dogs.dart';
import 'package:source_gen/source_gen.dart';

import 'package:dogs_generator/dogs_generator.dart';

class CompiledStructure {
  String type;
  String serialName;
  List<CompiledStructureField> fields;

  CompiledStructure(this.type, this.serialName, this.fields);

  String get code =>
      "$genAlias.DogStructure($type, '$serialName', [${fields.map((e) => e.code).join(", ")}])";
}

class CompiledStructureField {
  String accessor;
  String type;
  String serialType;
  IterableKind iterableKind;
  String name;
  bool optional;
  bool structure;

  CompiledStructureField(this.accessor, this.type, this.serialType,
      this.iterableKind, this.name, this.optional, this.structure);

  String get code =>
      "$genAlias.DogStructureField($type, $serialType, $iterableKind, '$name', $optional, $structure)";
}

class StructurizeResult {
  List<AliasImport> imports;
  CompiledStructure structure;

  StructurizeResult(this.imports, this.structure);
}

class StructurizeCounter {
  int _value = 0;

  int getAndIncrement() {
    return _value++;
  }
}

String szPrefix = "sz";
TypeChecker propertyNameChecker = TypeChecker.fromRuntime(PropertyName);

Future<StructurizeResult> structurize(
    DartType type, DogGenContext context, StructurizeCounter counter) async {
  List<AliasImport> imports = [];
  List<CompiledStructureField> fields = [];
  var element = type.element! as ClassElement;
  var serialName = element.name;
  for (var e in element.unnamedConstructor!.parameters) {
    var cszp = "$szPrefix${counter.getAndIncrement()}";
    var fieldName = e.name.replaceFirst("this.", "");
    var field = element.getField(fieldName);
    if (field == null) {
      throw Exception(
          "Serializable constructors must only reference instance fields");
    }
    var fieldType = field.type;
    var serialType = await getSerialType(fieldType, context);
    var iterableType = await getIterableType(fieldType, context);
    var optional = field.type.nullabilitySuffix == NullabilitySuffix.question;

    var propertyName = fieldName;
    if (propertyNameChecker.hasAnnotationOf(field)) {
      var annotation = propertyNameChecker.annotationsOf(field).first;
      propertyName = annotation.getField("name")!.toStringValue()!;
    }

    imports.add(AliasImport.type(fieldType, cszp));
    imports.add(AliasImport.type(serialType, cszp));

    fields.add(CompiledStructureField(
        "(obj) => obj.$fieldName",
        "$cszp.${fieldType.getDisplayString(withNullability: false)}",
        "$cszp.${serialType.getDisplayString(withNullability: false)}",
        iterableType,
        propertyName,
        optional,
        !isDogPrimitiveType(serialType)));
  }
  var rootTypePrefix = "$szPrefix${counter.getAndIncrement()}";
  imports.add(AliasImport.type(type, rootTypePrefix));
  var structure = CompiledStructure(
      "$rootTypePrefix.${type.getDisplayString(withNullability: false)}",
      serialName,
      fields);
  return StructurizeResult(imports, structure);
}
