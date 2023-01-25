import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:source_gen/source_gen.dart';

import 'package:dogs_generator/dogs_generator.dart';

bool _isInitialized = false;

late LibraryReader coreLibraryReader;
late InterfaceElement iterableType;
final _iterableChecker = TypeChecker.fromRuntime(Iterable);

late InterfaceElement listType;
final _listChecker = TypeChecker.fromRuntime(List);

late InterfaceElement setType;
final _setChecker = TypeChecker.fromRuntime(Set);

final _stringChecker = TypeChecker.fromRuntime(String);
final _intChecker = TypeChecker.fromRuntime(int);
final _doubleChecker = TypeChecker.fromRuntime(double);
final _boolChecker = TypeChecker.fromRuntime(bool);

bool isDogPrimitiveType(DartType type) {
  return _stringChecker.isExactlyType(type) ||
      _intChecker.isExactlyType(type) ||
      _doubleChecker.isExactlyType(type) ||
      _boolChecker.isExactlyType(type);
}

Future tryInitialize(DogGenContext context) async {
  if (_isInitialized) return;

  var coreLibrary = await context.step.resolver.findLibraryByName("dart.core");
  coreLibraryReader = LibraryReader(coreLibrary!);
  iterableType = coreLibraryReader.findType("Iterable") as InterfaceElement;
  listType = coreLibraryReader.findType("List") as InterfaceElement;
  setType = coreLibraryReader.findType("Set") as InterfaceElement;

  _isInitialized = true;
}

Future<DartType> getSerialType(DartType target, DogGenContext context) async {
  await tryInitialize(context);
  if (target.isDynamic || target.isVoid) return target;
  if (_iterableChecker.isAssignableFromType(target)) {
    return target.asInstanceOf(iterableType)!.typeArguments.first;
  }
  return target;
}

Future<IterableKind> getIterableType(
    DartType target, DogGenContext context) async {
  await tryInitialize(context);
  if (_listChecker.isAssignableFromType(target)) {
    return IterableKind.list;
  }
  if (_setChecker.isAssignableFromType(target)) {
    return IterableKind.set;
  }
  return IterableKind.none;
}


String getStructureMetadataSourceArray(Element element) {
  var conditionChecker = TypeChecker.fromRuntime(StructureMetadata);
  var annotations = <String>[];
  for (var value in element.metadata.whereTypeChecker(conditionChecker)) {
    annotations.add(value.toSource().substring(1));
  }
  return "[${annotations.join(", ")}]";
}

String getStructureMetadataSourceArrayAliased(Element element, List<AliasImport> imports, StructurizeCounter counter) {
  var conditionChecker = TypeChecker.fromRuntime(StructureMetadata);
  var annotations = <String>[];
  for (var value in element.metadata.whereTypeChecker(conditionChecker)) {
    var cszp = "$szPrefix${counter.getAndIncrement()}";
    var import = AliasImport.library((value.element as ConstructorElement).library, cszp);
    imports.add(import);
    annotations.add("$cszp.${value.toSource().substring(1)}");
  }
  return "[${annotations.join(", ")}]";
}
