import 'package:build/build.dart';
import 'package:dogs_generator/adapters/dog_adapter.dart';
import 'package:dogs_generator/builders/converter_builder.dart';
import 'package:dogs_generator/builders/link_builder.dart';
import 'package:dogs_generator/builders/reactor_builder.dart';
import 'package:dogs_generator/output_layout.dart';

Builder dogsLinking(BuilderOptions options) => LinkBuilder().descriptorBuilder;
Builder dogsBindings(BuilderOptions options) => CombinedBuilder([
      ConverterBuilder(outputLayout: DogsOutputLayout.fromOptions(options)).descriptorBuilder,
    ]);
Builder dogsConverters(BuilderOptions options) => CombinedBuilder([
      ConverterBuilder(outputLayout: DogsOutputLayout.fromOptions(options)).subjectBuilder,
    ]);
Builder dogsReactor(BuilderOptions options) =>
    DogReactorBuilder(outputLayout: DogsOutputLayout.fromOptions(options));
