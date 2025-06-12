// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unused_field, unused_import, public_member_api_docs, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_flutter/converters/geometric.dart' as gen0;
import 'package:dogs_flutter/converters/geometric.dart';
import 'package:dogs_flutter/converters/various.dart' as gen1;
import 'package:dogs_flutter/converters/various.dart';
import 'package:dogs_flutter/databinding/style.conv.g.dart' as gen2;
import 'package:dogs_flutter/databinding/style.conv.g.dart';

export 'package:dogs_flutter/converters/geometric.dart';
export 'package:dogs_flutter/converters/various.dart';
export 'package:dogs_flutter/databinding/style.conv.g.dart';

final dogsFlutterConverters = <DogConverter>[
  gen0.FlutterOffsetConverter(),
  gen0.FlutterSizeConverter(),
  gen0.FlutterRectConverter(),
  gen0.FlutterEdgeInsetsConverter(),
  gen0.FlutterRadiusConverter(),
  gen0.FlutterBorderRadiusConverter(),
  gen0.FlutterRRectConverter(),
  gen1.FlutterColorConverter(),
  gen2.BindingStyleConverter(),
];

DogPlugin DogsFlutterGeneratedModelsPlugin() => (engine) {
  engine.registerAllConverters(dogsFlutterConverters);
};
