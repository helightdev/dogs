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
import 'package:collection/collection.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:lyell_gen/lyell_gen.dart';
import 'package:source_gen/source_gen.dart';

import 'package:dogs_generator/dogs_generator.dart';

class CompiledStructure {
  String type;
  String serialName;
  List<CompiledStructureField> fields;
  String metadataSource;

  CompiledStructure(
      this.type, this.serialName, this.fields, this.metadataSource);

  String code(List<String> getters) =>
      "$genAlias.DogStructure<$type>('$serialName', [${fields.map((e) => e.code).join(", ")}], $metadataSource, $genAlias.ObjectFactoryStructureProxy<$type>(_activator, [${getters.join(", ")}]))";
}

class CompiledStructureField {
  String accessor;
  String type;
  String serialType;
  String converterType;
  IterableKind iterableKind;
  String name;
  bool optional;
  bool structure;
  String metadataSource;

  CompiledStructureField(
      this.accessor,
      this.type,
      this.converterType,
      this.serialType,
      this.iterableKind,
      this.name,
      this.optional,
      this.structure,
      this.metadataSource);

  String get code =>
      "$genAlias.DogStructureField($type, ${genPrefix.str("TypeToken<$serialType>()")}, $converterType, ${genPrefix.str(iterableKind.toString())}, '$name', $optional, $structure, $metadataSource)";
}

class StructurizeResult {
  List<AliasImport> imports;
  CompiledStructure structure;
  List<String> fieldNames;
  String activator;

  StructurizeResult(
      this.imports, this.structure, this.fieldNames, this.activator);
}

class StructurizeCounter {
  int _value = 0;

  int getAndIncrement() {
    return _value++;
  }
}

String szPrefix = "sz";
TypeChecker propertyNameChecker = TypeChecker.fromRuntime(PropertyName);
TypeChecker propertySerializerChecker =
    TypeChecker.fromRuntime(PropertySerializer);
TypeChecker polymorphicChecker = TypeChecker.fromRuntime(polymorphic.runtimeType);

Future<StructurizeResult> structurize(
    DartType type,
    ConstructorElement constructorElement,
    SubjectGenContext<Element> context,
    CachedAliasCounter counter) async {
  List<AliasImport> imports = [];
  List<CompiledStructureField> fields = [];
  var element = type.element! as ClassElement;
  var serialName = element.name;
  for (var e in constructorElement.parameters) {
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
    if (fieldType.isDynamic) optional = true;

    var propertyName = fieldName;
    if (propertyNameChecker.hasAnnotationOf(field)) {
      var annotation = propertyNameChecker.annotationsOf(field).first;
      propertyName = annotation.getField("name")!.toStringValue()!;
    }

    var propertySerializer = "null";
    if (propertySerializerChecker.hasAnnotationOf(field)) {
      var serializerAnnotation =
          propertySerializerChecker.annotationsOf(field).first;
      propertySerializer =
          counter.get(serializerAnnotation.getField("type")!.toTypeValue()!);
    }

    fields.add(CompiledStructureField(
        fieldName,
        counter.get(fieldType),
        propertySerializer,
        counter.get(serialType),
        iterableType,
        propertyName,
        optional,
        !isDogPrimitiveType(serialType),
        getRetainedAnnotationSourceArray(field, counter)));
  }

  // Determine used constructor
  var constructorName = "";
  if (element.getNamedConstructor("dog") != null) {
    constructorName = ".dog";
  }

  // Create proxy arguments
  var getters = fields.map((e) => e.accessor).toList();
  var activator = "${element.name}$constructorName(${fields.mapIndexed((i, y) {
    if (y.iterableKind == IterableKind.none) return "list[$i]";
    if (y.optional) return "list[$i]?.cast<${y.serialType}>()";
    return "list[$i].cast<${y.serialType}>()";
  }).join(", ")})";

  var structure = CompiledStructure(counter.get(type), serialName, fields,
      getRetainedAnnotationSourceArray(element, counter));
  return StructurizeResult(imports, structure, getters, activator);
}
