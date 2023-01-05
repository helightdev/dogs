import 'package:build/build.dart';
import 'package:dogs_generator/builders/converter_builder.dart';
import 'package:dogs_generator/builders/link_builder.dart';
import 'package:dogs_generator/builders/reactor_builder.dart';

Builder dogsLinking(BuilderOptions options) => LinkBuilder().bindingBuilder;
Builder dogsBindings(BuilderOptions options) =>
    ConverterBuilder().bindingBuilder;
Builder dogsConverters(BuilderOptions options) =>
    ConverterBuilder().converterBuilder;
Builder dogsReactor(BuilderOptions options) => DogReactorBuilder();
