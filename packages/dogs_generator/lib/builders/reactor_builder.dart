import 'dart:async';

import 'package:lyell_gen/lyell_gen.dart';

class DogReactorBuilder extends SubjectReactorBuilder {
  DogReactorBuilder() : super('dogs', 'dogs.g.dart');

  @override
  FutureOr<void> buildReactor(
      List<SubjectDescriptor> descriptors, SubjectCodeContext code) {
    code.additionalImports
        .add(AliasImport.root("package:dogs_core/dogs_core.dart"));
    code.codeBuffer
        .writeln(descriptors.map((e) => "export '${e.uri}';").join("\n"));
    code.codeBuffer.writeln("""
Future initialiseDogs() async {
  // ignore: invalid_use_of_internal_member
  DogEngine.internalSingleton ??= DogEngine(false);
  var engine = dogs;
  engine.registerAllConverters([${descriptors.expand((e) => (e.meta["converterNames"] as List).cast<String>()).map((e) => "$e()").join(", ")}]);
  engine.setSingleton();
}""");
  }
}
