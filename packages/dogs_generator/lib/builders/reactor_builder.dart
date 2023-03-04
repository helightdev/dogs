import 'dart:async';

import 'package:build/build.dart';
import 'package:lyell_gen/lyell_gen.dart';
import 'package:pubspec/pubspec.dart';
import 'package:recase/recase.dart';

class DogReactorBuilder extends SubjectReactorBuilder {
  DogReactorBuilder() : super('dogs', 'dogs.g.dart');

  String packageName = "unnamed";
  bool isLibrary = false;

  @override
  Future build(BuildStep buildStep) async {
    packageName = buildStep.inputId.package;
    try {
      var pubspecString = await buildStep
          .readAsString(AssetId(buildStep.inputId.package, "pubspec.yaml"));
      var pubspec = PubSpec.fromYamlString(pubspecString);
      var dogsRegion = pubspec.unParsedYaml?["dogs"];
      if (dogsRegion != null) {
        log.info("Using dogs generator options specified in the pubspec.yaml");
        var map = dogsRegion as Map;
        isLibrary = map["library"] as bool;

        log.info("isLibrary: $isLibrary");
      }
    } catch (ex) {
      log.warning(
          "Can't resolve package pubspec.yaml with error: $ex. Using default values.");
    }

    await super.build(buildStep);
  }

  @override
  FutureOr<void> buildReactor(
      List<SubjectDescriptor> descriptors, SubjectCodeContext code) {
    code.additionalImports
        .add(AliasImport.root("package:dogs_core/dogs_core.dart"));
    code.codeBuffer
        .writeln(descriptors.map((e) => "export '${e.uri}';").join("\n"));

    var converterNameArr =
        "[${descriptors.expand((e) => (e.meta["converterNames"] as List).cast<String>()).map((e) => "$e()").join(", ")}]";
    if (!isLibrary) {
      code.codeBuffer.writeln("""
Future initialiseDogs() async {
  var engine = DogEngine.hasValidInstance ? DogEngine.instance : DogEngine(false);
  engine.registerAllConverters($converterNameArr);
  engine.setSingleton();
}""");
    } else {
      var fieldName = ReCase("$packageName converters").camelCase;
      var funcName = ReCase("install $packageName converters").camelCase;
      code.codeBuffer.writeln("""
final $fieldName = <DogConverter>$converterNameArr;
      
void $funcName() {
  if (!DogEngine.hasValidInstance) {
    throw Exception("No valid global DogEngine instance present");
  }
  DogEngine.instance.registerAllConverters($fieldName);
}""");
    }
  }
}
