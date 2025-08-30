import 'dart:async';

import 'package:build/build.dart';
import 'package:lyell_gen/lyell_gen.dart';
import 'package:pubspec/pubspec.dart';
import 'package:recase/recase.dart';

import '../settings.dart';

class DogReactorBuilder extends SubjectReactorBuilder {
  DogReactorBuilder() : super('dogs', 'dogs.g.dart');

  String packageName = "unnamed";
  bool isLibrary = false;
  late BuildStep step;

  @override
  Future build(BuildStep buildStep) async {
    step = buildStep;
    packageName = buildStep.inputId.package;
    var settings = await DogsGeneratorSettings.load(buildStep);
    isLibrary = settings.isLibrary;
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
    var converterNameArr = "[${descriptorNames.map((e) => "$e()").join(", ")}]";
    if (!isLibrary) {
      code.codeBuffer.writeln("""
       
DogPlugin GeneratedModelsPlugin() => (engine) {
  engine.registerAllConverters($converterNameArr);
};""");
    } else {
      var fieldName = ReCase("$packageName converters").camelCase;
      var funcName = ReCase("$packageName Generated Models Plugin").pascalCase;
      code.codeBuffer.writeln("""
      
final $fieldName = <DogConverter>$converterNameArr;
      
DogPlugin $funcName() => (engine) {
  engine.registerAllConverters($fieldName);
};""");
      print("Wrote: ${code.codeBuffer}");
    }
  }
}
