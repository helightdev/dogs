import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:lyell_gen/lyell_gen.dart';
import 'package:source_gen/source_gen.dart';

import '../output_layout.dart';
import 'converter_builder.dart';

/// Writes converters directly to their declared destination using public Lyell APIs.
class ConverterSourceBuilder implements Builder {
  final ConverterBuilder adapter;
  final DogsOutputLayout layout;

  ConverterSourceBuilder(this.adapter, this.layout);

  @override
  Map<String, List<String>> get buildExtensions => layout.converterBuildExtensions();

  @override
  Future<void> build(BuildStep step) async {
    if (!await step.resolver.isLibrary(step.inputId)) return;
    await tryInitialize(step);
    final library = LibraryReader(await step.inputLibrary);
    final matches = library
        .annotatedWith(TypeChecker.typeNamed(Serializable))
        .map((annotation) => annotation.element)
        .whereType<Element>()
        .toList();
    if (matches.isEmpty) return;
    final context = SubjectGenContext<Element>(adapter, library, matches, step);
    if (!await adapter.doesOutput(context)) return;
    final code = SubjectCodeContext([], StringBuffer());
    await adapter.generateSubject(context, code);
    if (code.noGenerate) return;
    final imports = createImports(
      library: adapter.copySourceImports ? library.element : null,
      id: adapter.importSourceFile ? step.inputId : null,
      imports: code.additionalImports,
    );
    final content = '${code.header}\n$imports\n${code.codeBuffer}\n';
    await step.writeAsString(
      layout.converterAsset(step.inputId),
      DartFormatter(pageWidth: 200, languageVersion: DartFormatter.latestLanguageVersion)
          .format(content),
    );
  }
}
