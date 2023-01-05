// Notice: This code is pretty much copied from darwin, where it is used to
// enable third party generators. Since it's a bit hard to abstract into a
// package and not really time efficient, I basically 'Ctrl C + Ctrl V'ed
// it and reused it here. So no copyright problems here.
// ~ Christoph
import 'dart:async';
import 'dart:convert';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

import 'package:dogs_generator/dogs_generator.dart';

abstract class DogsAdapter {
  final String archetype;
  final Type annotation;

  late Builder bindingBuilder;
  late Builder converterBuilder;

  DogsAdapter({
    required this.archetype,
    required this.annotation,
  }) {
    bindingBuilder = _AdapterBindingBuilder(this);
    converterBuilder = _ServiceAdapterServiceBuilder(this);
  }

  Future<DogGenContext?> _createContext(BuildStep step) async {
    var library = await step.inputLibrary;
    var reader = LibraryReader(library);
    var foundElements =
        reader.annotatedWith(TypeChecker.fromRuntime(annotation));
    if (foundElements.isEmpty) return null;
    return DogGenContext(reader, foundElements.toList(), step);
  }

  Future<void> generateConverters(
      DogGenContext genContext, DogsCodeContext codeContext);

  Future<DogBinding> generateBinding(DogGenContext context);
}

class DogGenContext {
  final LibraryReader library;
  final List<AnnotatedElement> elements;
  final BuildStep step;

  DogGenContext(this.library, this.elements, this.step);

  DogBinding defaultBinding(DogsAdapter adapter) => DogBinding(
      name: library.element.name,
      package: step.inputId.uri.toString(),
      converterNames: <String>[],
      converterPackage: step.inputId
          .changeExtension(".${adapter.archetype}.g.dart")
          .uri
          .toString());
}

class DogsCodeContext {
  final List<AliasImport> additionalImports;
  final StringBuffer codeBuffer;
  bool noGenerate = false;

  DogsCodeContext(this.additionalImports, this.codeBuffer);
}

class _AdapterBindingBuilder extends Builder {
  final DogsAdapter adapter;

  _AdapterBindingBuilder(this.adapter);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var context = await adapter._createContext(buildStep);
    if (context == null) return;
    print("Generating Service Adapter Bindings for ${buildStep.inputId}");
    var binding = await adapter.generateBinding(context);
    await buildStep.writeAsString(
        buildStep.inputId.changeExtension(".${adapter.archetype}.dogs"),
        jsonEncode(binding.toMap()));
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        ".dart": [".${adapter.archetype}.dogs"]
      };
}

class _ServiceAdapterServiceBuilder extends Builder {
  final DogsAdapter adapter;

  _ServiceAdapterServiceBuilder(this.adapter);

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var genContext = await adapter._createContext(buildStep);
    if (genContext == null) return;
    print("Generating Service Adapter Code for ${buildStep.inputId}");
    var passedCodeBuffer = StringBuffer();
    var additionalImports = List<AliasImport>.empty(growable: true);
    var codeContext = DogsCodeContext(additionalImports, passedCodeBuffer);
    await adapter.generateConverters(genContext, codeContext);
    var codeBuffer = StringBuffer();
    codeBuffer.writeln(getImportString(genContext.library.element,
        genContext.step.inputId, additionalImports));
    codeBuffer.writeln(passedCodeBuffer.toString());
    if (codeContext.noGenerate) return;
    await buildStep.writeAsString(
        buildStep.inputId.changeExtension(".${adapter.archetype}.g.dart"),
        DartFormatter(pageWidth: 200).format(codeBuffer.toString()));
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        ".dart": [".${adapter.archetype}.g.dart"]
      };
}
