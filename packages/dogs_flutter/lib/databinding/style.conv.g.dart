// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unused_field, unused_import, public_member_api_docs, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

import 'dart:core';
import 'package:dogs_core/dogs_core.dart' as gen;
import 'package:lyell/lyell.dart' as gen;
import 'dart:core' as gen0;
import 'package:flutter/src/widgets/framework.dart' as gen1;
import 'package:dogs_flutter/databinding/style.dart' as gen2;
import 'package:dogs_flutter/structure/theme.dart' as gen3;
import 'package:dogs_core/src/converter.dart' as gen4;
import 'package:dogs_flutter/databinding/style.dart';

class BindingStyleConverter extends gen.DefaultStructureConverter<gen2.BindingStyle> {
  BindingStyleConverter()
    : super(
        struct: const gen.DogStructure<gen2.BindingStyle>(
          'BindingStyle',
          gen.StructureConformity.basic,
          [
            gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), null, 'label', true, false, []),
            gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), null, 'hint', true, false, []),
            gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), null, 'helper', true, false, []),
            gen.DogStructureField(gen.QualifiedTerminal<gen1.Widget>(), null, 'prefix', true, true, []),
            gen.DogStructureField(gen.QualifiedTerminal<gen1.Widget>(), null, 'suffix', true, true, []),
            gen.DogStructureField(
              gen.QualifiedTypeTreeN<gen0.List<gen2.BindingStyleExtension<dynamic>>, gen0.List<dynamic>>([
                gen.QualifiedTypeTreeN<gen2.BindingStyleExtension<dynamic>, gen2.BindingStyleExtension<dynamic>>([gen.QualifiedTerminal<dynamic>()]),
              ]),
              null,
              'extensions',
              false,
              true,
              [gen3.MergeFunction(gen2.BindingStyle.mergeExtensions)],
            ),
          ],
          [gen4.Structure()],
          gen.ObjectFactoryStructureProxy<gen2.BindingStyle>(_activator, [_$label, _$hint, _$helper, _$prefix, _$suffix, _$extensions], _values),
        ),
      );

  static dynamic _$label(gen2.BindingStyle obj) => obj.label;

  static dynamic _$hint(gen2.BindingStyle obj) => obj.hint;

  static dynamic _$helper(gen2.BindingStyle obj) => obj.helper;

  static dynamic _$prefix(gen2.BindingStyle obj) => obj.prefix;

  static dynamic _$suffix(gen2.BindingStyle obj) => obj.suffix;

  static dynamic _$extensions(gen2.BindingStyle obj) => obj.extensions;

  static List<dynamic> _values(gen2.BindingStyle obj) => [obj.label, obj.hint, obj.helper, obj.prefix, obj.suffix, obj.extensions];

  static gen2.BindingStyle _activator(List list) {
    return gen2.BindingStyle(label: list[0], hint: list[1], helper: list[2], prefix: list[3], suffix: list[4], extensions: list[5]);
  }
}

abstract class BindingStyle$Copy {
  gen2.BindingStyle call({gen0.String? label, gen0.String? hint, gen0.String? helper, gen1.Widget? prefix, gen1.Widget? suffix, gen0.List<gen2.BindingStyleExtension<dynamic>>? extensions});
}

class BindingStyleBuilder implements BindingStyle$Copy {
  BindingStyleBuilder([gen2.BindingStyle? $src]) {
    if ($src == null) {
      $values = List.filled(6, null);
    } else {
      $values = BindingStyleConverter._values($src);
      this.$src = $src;
    }
  }

  late List<dynamic> $values;

  gen2.BindingStyle? $src;

  set label(gen0.String? value) {
    $values[0] = value;
  }

  gen0.String? get label => $values[0];

  set hint(gen0.String? value) {
    $values[1] = value;
  }

  gen0.String? get hint => $values[1];

  set helper(gen0.String? value) {
    $values[2] = value;
  }

  gen0.String? get helper => $values[2];

  set prefix(gen1.Widget? value) {
    $values[3] = value;
  }

  gen1.Widget? get prefix => $values[3];

  set suffix(gen1.Widget? value) {
    $values[4] = value;
  }

  gen1.Widget? get suffix => $values[4];

  set extensions(gen0.List<gen2.BindingStyleExtension<dynamic>> value) {
    $values[5] = value;
  }

  gen0.List<gen2.BindingStyleExtension<dynamic>> get extensions => $values[5];

  @override
  gen2.BindingStyle call({Object? label = #sentinel, Object? hint = #sentinel, Object? helper = #sentinel, Object? prefix = #sentinel, Object? suffix = #sentinel, Object? extensions = #sentinel}) {
    if (label != #sentinel) {
      this.label = label as gen0.String?;
    }
    if (hint != #sentinel) {
      this.hint = hint as gen0.String?;
    }
    if (helper != #sentinel) {
      this.helper = helper as gen0.String?;
    }
    if (prefix != #sentinel) {
      this.prefix = prefix as gen1.Widget?;
    }
    if (suffix != #sentinel) {
      this.suffix = suffix as gen1.Widget?;
    }
    if (extensions != #sentinel) {
      this.extensions = extensions as gen0.List<gen2.BindingStyleExtension<dynamic>>;
    }
    return build();
  }

  gen2.BindingStyle build() {
    var instance = BindingStyleConverter._activator($values);

    return instance;
  }
}

extension BindingStyleDogsExtension on gen2.BindingStyle {
  gen2.BindingStyle rebuild(Function(BindingStyleBuilder b) f) {
    var builder = BindingStyleBuilder(this);
    f(builder);
    return builder.build();
  }

  BindingStyle$Copy get copy => toBuilder();
  BindingStyleBuilder toBuilder() {
    return BindingStyleBuilder(this);
  }

  Map<String, dynamic> toNative() {
    return gen.dogs.convertObjectToNative(this, gen2.BindingStyle);
  }
}
