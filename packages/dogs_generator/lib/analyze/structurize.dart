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

class IRStructure {
  String type;
  StructureConformity conformity;
  String serialName;
  List<IRStructureField> fields;
  String metadataSource;

  IRStructure(this.type, this.conformity, this.serialName, this.fields,
      this.metadataSource);

  String code(List<String> getters) {
    var fieldsArr = "[${fields.map((e) => e.code).join(", ")}]";
    var dataclassInsert =
        conformity == StructureConformity.dataclass ? (", _hash, _equals") : "";
    var proxyDef =
        "$genAlias.ObjectFactoryStructureProxy<$type>(_activator, [${getters.join(", ")}], _values$dataclassInsert)";
    return "$genAlias.DogStructure<$type>('$serialName', $genAlias.$conformity, $fieldsArr, $metadataSource, $proxyDef)";
  }
}

class IRStructureField {
  String accessor;
  String type;
  String typeTree;
  String serialType;
  String converterType;
  IterableKind iterableKind;
  String name;
  bool optional;
  bool structure;
  String metadataSource;
  bool $isMap;

  IRStructureField(
      this.accessor,
      this.type,
      this.typeTree,
      this.converterType,
      this.serialType,
      this.iterableKind,
      this.name,
      this.optional,
      this.structure,
      this.metadataSource,
      this.$isMap);

  String get code {
    return "$genAlias.DogStructureField($typeTree, ${genPrefix.str("TypeToken<$serialType>()")}, $converterType, ${genPrefix.str(iterableKind.toString())}, '$name', $optional, $structure, $metadataSource)";
  }
}

class StructurizeResult {
  List<AliasImport> imports;
  IRStructure structure;
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
TypeChecker dataclassChecker = TypeChecker.fromRuntime(Dataclass);
TypeChecker mapChecker = TypeChecker.fromRuntime(Map);
TypeChecker beanIgnoreChecker = TypeChecker.fromRuntime(beanIgnore.runtimeType);

Future<StructurizeResult> structurizeConstructor(
    DartType type,
    ConstructorElement constructorElement,
    SubjectGenContext<Element> context,
    CachedAliasCounter counter) async {
  List<AliasImport> imports = [];
  List<IRStructureField> fields = [];
  var element = type.element! as ClassElement;
  var serialName = element.name;

  // Determine used constructor
  var constructorName = "";
  if (element.getNamedConstructor("dog") != null) {
    constructorElement = element.getNamedConstructor("dog")!;
    constructorName = ".dog";
  }

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
    if (fieldType is DynamicType) optional = true;

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

    fields.add(IRStructureField(
        fieldName,
        counter.get(fieldType),
        getTypeTree(fieldType).code(counter),
        propertySerializer,
        counter.get(serialType),
        iterableType,
        propertyName,
        optional,
        !isDogPrimitiveType(serialType),
        getRetainedAnnotationSourceArray(field, counter),
        mapChecker.isAssignableFrom(field.type.element!)));
  }

  // Create proxy arguments
  var getters = fields.map((e) => e.accessor).toList();
  var activator =
      "return ${element.name}$constructorName(${constructorElement.parameters.mapIndexed((i, e) {
    var y = fields[i];
    if (e.isNamed) {
      if (y.iterableKind == IterableKind.none) return "${e.name}: list[$i]";
      if (y.optional) return "${e.name}: list[$i]?.cast<${y.serialType}>()";
      return "${e.name}: list[$i].cast<${y.serialType}>()";
    } else {
      if (y.iterableKind == IterableKind.none) return "list[$i]";
      if (y.optional) return "list[$i]?.cast<${y.serialType}>()";
      return "list[$i].cast<${y.serialType}>()";
    }
  }).join(", ")});";
  var isDataclass = dataclassChecker.isAssignableFromType(element.thisType);
  var structure = IRStructure(
      counter.get(type),
      isDataclass ? StructureConformity.dataclass : StructureConformity.basic,
      serialName,
      fields,
      getRetainedAnnotationSourceArray(element, counter));
  return StructurizeResult(imports, structure, getters, activator);
}

Future<StructurizeResult> structurizeBean(
    DartType type,
    ClassElement classElement,
    SubjectGenContext<Element> context,
    CachedAliasCounter counter) async {
  List<AliasImport> imports = [];
  List<IRStructureField> fields = [];
  var element = type.element! as ClassElement;
  var serialName = element.name;
  var beanFields = classElement.fields.where((element) {
    var field = classElement.getField(element.name)!;
    if (beanIgnoreChecker.hasAnnotationOf(field)) return false;
    return field.getter != null && field.setter != null;
  }).toList();
  for (var field in beanFields) {
    var fieldName = field.name;
    var fieldType = field.type;
    var serialType = await getSerialType(fieldType, context);
    var iterableType = await getIterableType(fieldType, context);

    var optional = field.type.nullabilitySuffix == NullabilitySuffix.question;
    if (fieldType is DynamicType) optional = true;
    if (field.isLate) optional = false;

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

    fields.add(IRStructureField(
        fieldName,
        counter.get(fieldType),
        getTypeTree(fieldType).code(counter),
        propertySerializer,
        counter.get(serialType),
        iterableType,
        propertyName,
        optional,
        !isDogPrimitiveType(serialType),
        getRetainedAnnotationSourceArray(field, counter),
        mapChecker.isAssignableFrom(field)));
  }

  // Create proxy arguments
  var getters = fields.map((e) => e.accessor).toList();
  var activator =
      "var obj = ${counter.get(element.thisType)}();${fields.where((element) {
    var field = classElement.getField(element.name)!;
    return field.getter != null && field.setter != null;
  }).mapIndexed((i, e) {
    if (e.iterableKind == IterableKind.none) {
      return "obj.${e.name} = list[$i];";
    } else if (e.optional) {
      return "obj.${e.name} = list[$i]?.cast<${e.serialType}>();";
    }
    return "obj.${e.name} = list[$i];";
  }).join("\n")} return obj;";
  var structure = IRStructure(counter.get(type), StructureConformity.bean,
      serialName, fields, getRetainedAnnotationSourceArray(element, counter));
  return StructurizeResult(imports, structure, getters, activator);
}
