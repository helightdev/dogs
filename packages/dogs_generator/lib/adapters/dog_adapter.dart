// Notice: This code is pretty much copied from darwin, where it is used to
// enable third party generators. Since it's a bit hard to abstract into a
// package and not really time efficient, I basically 'Ctrl C + Ctrl V'ed
// it and reused it here. So no copyright problems here.
// ~ Christoph
import 'dart:async';
import 'dart:convert';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:lyell_gen/lyell_gen.dart';
import 'package:source_gen/source_gen.dart';

import 'package:dogs_generator/dogs_generator.dart';

abstract class DogsAdapter<TAnnotation>
    extends SubjectAdapter<TAnnotation, Element> {
  DogsAdapter({
    required super.archetype,
    required super.annotation,
  }) : super(descriptorExtension: 'dogs');
}
