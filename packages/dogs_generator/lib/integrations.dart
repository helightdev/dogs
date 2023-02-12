import 'package:build/build.dart';
import 'package:dogs_generator/builders/converter_builder.dart';
import 'package:dogs_generator/builders/link_builder.dart';
import 'package:dogs_generator/builders/reactor_builder.dart';

Builder dogsLinking(BuilderOptions options) => LinkBuilder().descriptorBuilder;
Builder dogsBindings(BuilderOptions options) =>
    ConverterBuilder().descriptorBuilder;
Builder dogsConverters(BuilderOptions options) =>
    ConverterBuilder().subjectBuilder;
Builder dogsReactor(BuilderOptions options) => DogReactorBuilder();
