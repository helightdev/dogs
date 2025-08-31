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
import 'package:analyzer/dart/element/type.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_generator/dogs_generator.dart';
import 'package:lyell_gen/lyell_gen.dart';
import 'package:source_gen/source_gen.dart';

final _iterableChecker = TypeChecker.typeNamed(Iterable, inSdk: true);
final _listChecker = TypeChecker.typeNamed(List, inSdk: true);
final _setChecker = TypeChecker.typeNamed(Set, inSdk: true);
final _stringChecker = TypeChecker.typeNamed(String, inSdk: true);
final _intChecker = TypeChecker.typeNamed(int, inSdk: true);
final _doubleChecker = TypeChecker.typeNamed(double, inSdk: true);
final _boolChecker = TypeChecker.typeNamed(bool, inSdk: true);

bool isDogPrimitiveType(DartType type) {
  if (type is DynamicType || type is VoidType) return true;
  return _stringChecker.isExactlyType(type) ||
      _intChecker.isExactlyType(type) ||
      _doubleChecker.isExactlyType(type) ||
      _boolChecker.isExactlyType(type);
}

Future<DartType> getSerialType(
    DartType target, SubjectGenContext<Element> context) async {
  return await getItemType(target, context.step);
}

Future<IterableKind> getIterableType(
    DartType target, SubjectGenContext<Element> context) async {
  var typeTree = getTypeTree(target);
  if (_listChecker.isAssignableFromType(target) &&
      typeTree.base.isDartCoreList) {
    return IterableKind.list;
  }
  if (_setChecker.isAssignableFromType(target) && typeTree.base.isDartCoreSet) {
    return IterableKind.set;
  }
  if (_iterableChecker.isAssignableFromType(target) &&
      typeTree.base.isDartCoreIterable) {
    return IterableKind.list;
  }
  return IterableKind.none;
}

String getStructureMetadataSourceArray(Element element) {
  var conditionChecker = TypeChecker.typeNamed(StructureMetadata);
  var annotations = <String>[];
  for (var value in element.metadata.annotations.whereTypeChecker(conditionChecker)) {
    annotations.add(value.toSource().substring(1));
  }
  return "[${annotations.join(", ")}]";
}

String getStructureMetadataSourceArrayAliased(
    Element element, List<AliasImport> imports, StructurizeCounter counter) {
  var conditionChecker = TypeChecker.typeNamed(StructureMetadata);
  var annotations = <String>[];
  for (var value in element.metadata.annotations.whereTypeChecker(conditionChecker)) {
    var cszp = "$szPrefix${counter.getAndIncrement()}";
    var import = AliasImport.library(
        (value.element as ConstructorElement).library, cszp);
    imports.add(import);
    annotations.add("$cszp.${value.toSource().substring(1)}");
  }
  return "[${annotations.join(", ")}]";
}
