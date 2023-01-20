import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';

import 'package:dogs_generator/dogs_generator.dart';

class DogReactorBuilder extends Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) async {
    StringBuffer buffer = StringBuffer();
    var componentIds = await buildStep.findAssets(Glob("**.dogs")).toList();
    List<String> importValues = List<String>.empty(growable: true);
    List<String> converterNames = List<String>.empty(growable: true);
    importValues.add("package:dogs_core/dogs_core.dart");

    for (var value in componentIds) {
      var bindingString = await buildStep.readAsString(value);
      var binding = DogBinding.fromMap(jsonDecode(bindingString));
      var sourcePath = binding.converterPackage;
      if (!importValues.contains(sourcePath)) importValues.add(sourcePath);
      converterNames.addAll(binding.converterNames);
    }

    buffer.writeln(importValues.map((e) => "import '$e';").join("\n"));
    buffer.writeln(importValues.map((e) => "export '$e';").join("\n"));

    buffer.writeln("""

Future initialiseDogs() async {
  dogs = DogEngine(false)
    ..registerAllConverters([${converterNames.map((e) => "$e()").join(", ")}])
    ..setSingleton();
}
""");
    buildStep.writeAsString(
        AssetId(buildStep.inputId.package, "lib/dogs.g.dart"),
        DartFormatter().format(buffer.toString()));
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        r"$lib$": ["dogs.g.dart"]
      };
}
