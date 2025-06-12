import 'package:build/build.dart';
import 'package:dogs_generator/adapters/dog_adapter.dart';
import 'package:dogs_generator/builders/converter_builder.dart';
import 'package:dogs_generator/builders/library_builder.dart';
import 'package:dogs_generator/builders/link_builder.dart';
import 'package:dogs_generator/builders/reactor_builder.dart';

Builder dogsLinking(BuilderOptions options) => LinkBuilder().descriptorBuilder;
Builder dogsBindings(BuilderOptions options) => CombinedBuilder([
      ConverterBuilder().descriptorBuilder,
      SerializableLibraryBuilder().descriptorBuilder
    ]);
Builder dogsConverters(BuilderOptions options) => CombinedBuilder([
      ConverterBuilder().subjectBuilder,
      SerializableLibraryBuilder().subjectBuilder
    ]);
Builder dogsReactor(BuilderOptions options) => DogReactorBuilder();
