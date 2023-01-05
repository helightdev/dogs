import 'package:dogs/dogs.dart';

import 'package:dogs_generator/dogs_generator.dart';

class LinkBuilder extends DogsAdapter {
  LinkBuilder() : super(archetype: "link", annotation: LinkSerializer);

  @override
  Future<DogBinding> generateBinding(DogGenContext context) async {
    var binding = context.defaultBinding(this);
    binding.converterPackage = context.library.element.identifier;
    binding.converterNames =
        context.elements.map((e) => e.element.name!).toList();
    return binding;
  }

  @override
  Future<void> generateConverters(
      DogGenContext genContext, DogsCodeContext codeContext) async {
    codeContext.noGenerate = true;
  }
}
