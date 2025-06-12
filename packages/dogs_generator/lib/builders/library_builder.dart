import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_generator/analyze/built_interop.dart';
import 'package:dogs_generator/dogs_generator.dart';
import 'package:lyell_gen/lyell_gen.dart';
import 'package:source_gen/source_gen.dart';

// ignore: invalid_use_of_internal_member
class SerializableLibraryBuilder extends DogsAdapter<SerializableLibrary> {
  SerializableLibraryBuilder() : super(archetype: "slib");

  @override
  Future<SubjectDescriptor> generateDescriptor(
      SubjectGenContext<Element> context) async {
    var libraries = getSerializableLibraries(context);
    var resolvedTypeSets = await Future.wait(
        libraries.map((e) => getSerializedTypes(context.step, e)));
    var allTypes = resolvedTypeSets.expand((e) => e).toSet();

    log.info(
        "Found ${allTypes.length} library serializable types in ${libraries.length} libraries");

    var binding = context.defaultDescriptor();
    binding.meta["converterNames"] =
        allTypes.map((e) => "${e.name}Converter").toList();
    return binding;
  }

  List<IRSerializableLibrary> getSerializableLibraries(
      SubjectGenContext<Element> context) {
    var typeChecker = TypeChecker.fromRuntime(SerializableLibrary);
    return context.matches
        .expand((element) => element.metadata
            .whereTypeChecker(typeChecker)
            .map((e) => [element, e]))
        .map((e) {
          var target = e[0] as Element;
          var annotation = (e[1] as ElementAnnotation).computeConstantValue()!;
          var reader = ConstantReader(annotation);
          if (target is! LibraryImportElement) {
            log.severe(
                "SerializableLibrary annotation can only be used on library imports");
            return null;
          }
          var importUri = target.importedLibrary!.source.uri;

          return IRSerializableLibrary(
            importUri.toString(),
            include: reader.read("include").isNull
                ? null
                : reader
                    .read("include")
                    .listValue
                    .map((e) => RegExp(e.toStringValue()!))
                    .toList(),
            exclude: reader.read("exclude").isNull
                ? null
                : reader
                    .read("exclude")
                    .listValue
                    .map((e) => RegExp(e.toStringValue()!))
                    .toList(),
          );
        })
        .nonNulls
        .toList();
  }

  Future<Set<Element>> getSerializedTypes(
      BuildStep step, IRSerializableLibrary irLib) async {
    await tryInitializeBuiltInterop(step);
    var importUri = Uri.parse(irLib.import);
    var assetId = AssetId.resolve(importUri);
    var library = await step.resolver.libraryFor(assetId);
    var possibleTypes = getClassCandidates(library);
    bool fullMatch(RegExp matcher, String str) {
      return matcher
          .allMatches(str)
          .any((element) => element.start == 0 && element.end == str.length);
    }

    if (irLib.exclude != null) {
      possibleTypes = possibleTypes
          .where((element) => !irLib.exclude!
              .any((test) => fullMatch(test, element.queryableUri)))
          .toSet();
    }
    if (irLib.include != null) {
      possibleTypes = possibleTypes
          .where((element) => irLib.include!
              .any((test) => fullMatch(test, element.queryableUri)))
          .toSet();
    }
    return possibleTypes;
  }

  Set<Element> getClassCandidates(LibraryElement library,
      [Set<LibraryElement>? visited]) {
    var reader = LibraryReader(library);
    visited ??= {};
    if (visited.contains(library)) {
      return {};
    }
    visited.add(library);
    var possibleTypes = [
      ...reader.classes,
      ...reader.enums,
      ...(library.exportedLibraries
          .expand((e) => getClassCandidates(e, visited)))
    ]
        .where((element) {
          return element.isPublic;
        })
        .where((element) => filterElement(element))
        .toSet();

    return possibleTypes;
  }

  bool filterElement(Element element) {
    if (hasBuiltInterop) {
      if (builtChecker.isAssignableFrom(element)) {
        return true;
      }
      if (builtBuilderChecker.isAssignableFrom(element)) {
        return false;
      }
      if (builtValueEnumChecker.isAssignableFrom(element)) {
        return false;
      }
    }
    return true;
  }

  @override
  FutureOr<void> generateSubject(SubjectGenContext<Element> genContext,
      SubjectCodeContext codeContext) async {
    codeContext.additionalImports
        .add(AliasImport.gen("package:dogs_core/dogs_core.dart"));

    var libraries = getSerializableLibraries(genContext);
    var resolvedTypeSets = await Future.wait(
        libraries.map((e) => getSerializedTypes(genContext.step, e)));
    var allTypes = resolvedTypeSets.expand((e) => e).toSet();
    var passTypes = allTypes.toSet();
    if (hasBuiltInterop) {
      for (var element in allTypes) {
        if (!builtChecker.isAssignableFrom(element)) {
          continue;
        }
        passTypes.remove(element);
        log.fine("Generating built_value dogs interop for '${element.name}'");
        try {
          await writeBuiltInteropConverter(
              element as ClassElement, codeContext, genContext);
        } catch (ex) {
          log.severe(
              "Can't generate built_value dogs interop for '${element.name}' with error: $ex");
        }
      }
    }

    for (var element in passTypes) {
      log.fine("Generating dogs converter for '${element.name}'");
      try {
        if (element is ClassElement) {
          await ConverterBuilder.generateForClass(
              element, genContext, codeContext);
        } else if (element is EnumElement) {
          await ConverterBuilder.generateForEnum(
              element, genContext, codeContext);
        }
      } catch (ex) {
        log.severe(
            "Can't generate converter for '${element.name}' with error: $ex");
      }
    }
  }
}

extension on Element {
  String get queryableUri =>
      library!.source.uri.replace(fragment: name).toString();
}

class IRSerializableLibrary {
  final String import;
  final List<RegExp>? include;
  final List<RegExp>? exclude;

  const IRSerializableLibrary(this.import, {this.include, this.exclude});
}
