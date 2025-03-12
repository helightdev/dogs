// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unused_field, unused_import, public_member_api_docs, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

import 'dart:core';
import 'package:dogs_core/dogs_core.dart' as gen;
import 'package:lyell/lyell.dart' as gen;
import 'dart:core' as gen0;
import 'package:benchmarks/dataclasses.dart' as gen1;
import 'package:benchmarks/dataclasses.dart';

class DogBenchmarkDataclassEntityConverter extends gen.DefaultStructureConverter<gen1.DogBenchmarkDataclassEntity> {
  DogBenchmarkDataclassEntityConverter()
    : super(
        struct: const gen.DogStructure<gen1.DogBenchmarkDataclassEntity>(
          'DogBenchmarkDataclassEntity',
          gen.StructureConformity.dataclass,
          [
            gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), gen.TypeToken<gen0.String>(), null, gen.IterableKind.none, 'name', false, false, []),
            gen.DogStructureField(gen.QualifiedTerminal<gen0.int>(), gen.TypeToken<gen0.int>(), null, gen.IterableKind.none, 'age', false, false, []),
            gen.DogStructureField(
              gen.QualifiedTypeTreeN<gen0.List<gen0.String>, gen0.List<dynamic>>([gen.QualifiedTerminal<gen0.String>()]),
              gen.TypeToken<gen0.String>(),
              null,
              gen.IterableKind.list,
              'tags',
              false,
              false,
              [],
            ),
            gen.DogStructureField(
              gen.QualifiedTypeTreeN<gen0.Map<gen0.String, gen0.String>, gen0.Map<dynamic, dynamic>>([gen.QualifiedTerminal<gen0.String>(), gen.QualifiedTerminal<gen0.String>()]),
              gen.TypeToken<gen0.Map<gen0.String, gen0.String>>(),
              null,
              gen.IterableKind.none,
              'fields',
              false,
              true,
              [],
            ),
          ],
          [],
          gen.ObjectFactoryStructureProxy<gen1.DogBenchmarkDataclassEntity>(_activator, [_$name, _$age, _$tags, _$fields], _values, _hash, _equals),
        ),
      );

  static dynamic _$name(gen1.DogBenchmarkDataclassEntity obj) => obj.name;

  static dynamic _$age(gen1.DogBenchmarkDataclassEntity obj) => obj.age;

  static dynamic _$tags(gen1.DogBenchmarkDataclassEntity obj) => obj.tags;

  static dynamic _$fields(gen1.DogBenchmarkDataclassEntity obj) => obj.fields;

  static List<dynamic> _values(gen1.DogBenchmarkDataclassEntity obj) => [obj.name, obj.age, obj.tags, obj.fields];

  static gen1.DogBenchmarkDataclassEntity _activator(List list) {
    return gen1.DogBenchmarkDataclassEntity(list[0], list[1], list[2].cast<gen0.String>(), list[3]);
  }

  static int _hash(gen1.DogBenchmarkDataclassEntity obj) => obj.name.hashCode ^ obj.age.hashCode ^ gen.deepEquality.hash(obj.tags) ^ gen.deepEquality.hash(obj.fields);

  static bool _equals(gen1.DogBenchmarkDataclassEntity a, gen1.DogBenchmarkDataclassEntity b) =>
      (a.name == b.name && a.age == b.age && gen.deepEquality.equals(a.tags, b.tags) && gen.deepEquality.equals(a.fields, b.fields));
}

class DogBenchmarkDataclassEntityBuilder {
  DogBenchmarkDataclassEntityBuilder([gen1.DogBenchmarkDataclassEntity? $src]) {
    if ($src == null) {
      $values = List.filled(4, null);
    } else {
      $values = DogBenchmarkDataclassEntityConverter._values($src);
      this.$src = $src;
    }
  }

  late List<dynamic> $values;

  gen1.DogBenchmarkDataclassEntity? $src;

  set name(gen0.String value) {
    $values[0] = value;
  }

  gen0.String get name => $values[0];

  set age(gen0.int value) {
    $values[1] = value;
  }

  gen0.int get age => $values[1];

  set tags(gen0.List<gen0.String> value) {
    $values[2] = value;
  }

  gen0.List<gen0.String> get tags => $values[2];

  set fields(gen0.Map<gen0.String, gen0.String> value) {
    $values[3] = value;
  }

  gen0.Map<gen0.String, gen0.String> get fields => $values[3];

  gen1.DogBenchmarkDataclassEntity build() {
    var instance = DogBenchmarkDataclassEntityConverter._activator($values);

    return instance;
  }
}

extension DogBenchmarkDataclassEntityDogsExtension on gen1.DogBenchmarkDataclassEntity {
  gen1.DogBenchmarkDataclassEntity rebuild(Function(DogBenchmarkDataclassEntityBuilder b) f) {
    var builder = DogBenchmarkDataclassEntityBuilder(this);
    f(builder);
    return builder.build();
  }

  DogBenchmarkDataclassEntityBuilder toBuilder() {
    return DogBenchmarkDataclassEntityBuilder(this);
  }

  Map<String, dynamic> toNative() {
    return gen.dogs.convertObjectToNative(this, gen1.DogBenchmarkDataclassEntity);
  }
}
