import 'dart:async';

import 'package:build/build.dart';
import 'package:lyell_gen/lyell_gen.dart';
import 'package:pubspec/pubspec.dart';
import 'package:recase/recase.dart';

class DogReactorBuilder extends SubjectReactorBuilder {
  DogReactorBuilder() : super('dogs', 'dogs.g.dart');

  String packageName = "unnamed";
  bool isLibrary = false;
  late BuildStep step;

  @override
  Future build(BuildStep buildStep) async {
    step = buildStep;
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
      List<SubjectDescriptor> descriptors, SubjectCodeContext code) async {
    code.additionalImports
        .add(AliasImport.root("package:dogs_core/dogs_core.dart"));

    List<String> descriptorNames = [];
    for (var descriptor in descriptors) {
      var names = (descriptor.meta["converterNames"] as List).cast<String>();
      for (var name in names) {
        var type = await getDartType(step, descriptor.uri, name);
        descriptorNames.add(code.cachedCounter.get(type));
      }

      code.codeBuffer.writeln("export '${descriptor.uri}';");
    }
    var converterNameArr =
        "[${descriptorNames.map((e) => "$e()").join(", ")}]";
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
