import 'dart:async';

import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_generator/dogs_generator.dart';
import 'package:lyell_gen/lyell_gen.dart';

// ignore: invalid_use_of_internal_member
class LinkBuilder extends DogsAdapter<DogLinked> {
  LinkBuilder() : super(archetype: "link");

  @override
  Future<SubjectDescriptor> generateDescriptor(
      SubjectGenContext<Element2> context) async {
    var binding = SubjectDescriptor(uri: context.step.inputId.uri.toString());

    var constructedNames = <String>[];
    var variableNames = <String>[];

    for (var match in context.matches) {
      switch (match) {
        case InterfaceElement2():
          constructedNames.add(match.displayName);
        case TopLevelVariableElement2():
          variableNames.add(match.displayName);
        case _:
          log.warning(
              "Element ${match.displayName} of type ${match.runtimeType} is not supported for linking and will be ignored.");
      }
    }

    binding.meta["constructedNames"] = constructedNames;
    binding.meta["variableNames"] = variableNames;

    return binding;
  }

  @override
  FutureOr<void> generateSubject(
      SubjectGenContext<Element2> genContext, SubjectCodeContext codeContext) {
    bool didGenerate = false;
    // Reserved
    codeContext.noGenerate = !didGenerate;
  }
}
