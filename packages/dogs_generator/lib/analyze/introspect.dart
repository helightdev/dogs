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
