// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unused_field, unused_import, public_member_api_docs, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

import 'dart:core';
import 'package:dogs_core/dogs_core.dart' as gen;
import 'package:lyell/lyell.dart' as gen;
import 'dart:core' as gen0;
import 'package:dogs_core/validation/length.dart' as gen1;
import 'package:dogs_core/validation/range.dart' as gen2;
import 'package:dogs_flutter/databinding/material/style.dart' as gen3;
import 'package:flutter/src/material/input_decorator.dart' as gen4;
import 'package:flutter/src/material/input_border.dart' as gen5;
import 'package:dogs_core/validation/must_match.dart' as gen6;
import 'package:dogs_flutter/databinding/style.dart' as gen7;
import 'package:example/models.dart' as gen8;
import 'package:dogs_core/src/converter.dart' as gen9;
import 'package:example/models.dart';

class PersonConverter extends gen.DefaultStructureConverter<gen8.Person> {
  PersonConverter()
    : super(
        struct: const gen.DogStructure<gen8.Person>(
          'Person',
          gen.StructureConformity.dataclass,
          [
            gen.DogStructureField(
              gen.QualifiedTerminal<gen0.String>(),
              null,
              'name',
              false,
              false,
              [gen1.LengthRange(min: 3, max: 10)],
            ),
            gen.DogStructureField(
              gen.QualifiedTerminal<gen0.String>(),
              null,
              'surname',
              false,
              false,
              [gen1.LengthRange(min: 3)],
            ),
            gen.DogStructureField(
              gen.QualifiedTerminal<gen0.int>(),
              null,
              'age',
              false,
              false,
              [gen2.Range(min: 18, max: 99)],
            ),
            gen.DogStructureField(
              gen.QualifiedTerminal<gen0.double>(),
              null,
              'balance',
              false,
              false,
              [],
            ),
            gen.DogStructureField(
              gen.QualifiedTerminal<gen0.bool>(),
              null,
              'isActive',
              false,
              false,
              [],
            ),
            gen.DogStructureField(
              gen.QualifiedTerminal<gen0.String>(),
              null,
              'plate',
              false,
              false,
              [],
            ),
            gen.DogStructureField(
              gen.QualifiedTerminal<gen0.String>(),
              null,
              'tag',
              true,
              false,
              [],
            ),
            gen.DogStructureField(
              gen.QualifiedTerminal<gen0.String>(),
              null,
              'password',
              false,
              false,
              [
                gen1.LengthRange(min: 3),
                gen3.MaterialBindingStyle.inputTheme(
                  gen4.InputDecorationThemeData(
                    border: gen5.OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            gen.DogStructureField(
              gen.QualifiedTerminal<gen0.String>(),
              null,
              'confirm',
              false,
              false,
              [
                gen6.MustMatch('password'),
                gen7.BindingStyle(
                  hint: 'Repeat the password',
                  label: 'Confirm password',
                ),
              ],
            ),
          ],
          [gen9.serializable],
          gen.ObjectFactoryStructureProxy<gen8.Person>(
            _activator,
            [
              _$name,
              _$surname,
              _$age,
              _$balance,
              _$isActive,
              _$plate,
              _$tag,
              _$password,
              _$confirm,
            ],
            _values,
            _hash,
            _equals,
          ),
        ),
      );

  static dynamic _$name(gen8.Person obj) => obj.name;

  static dynamic _$surname(gen8.Person obj) => obj.surname;

  static dynamic _$age(gen8.Person obj) => obj.age;

  static dynamic _$balance(gen8.Person obj) => obj.balance;

  static dynamic _$isActive(gen8.Person obj) => obj.isActive;

  static dynamic _$plate(gen8.Person obj) => obj.plate;

  static dynamic _$tag(gen8.Person obj) => obj.tag;

  static dynamic _$password(gen8.Person obj) => obj.password;

  static dynamic _$confirm(gen8.Person obj) => obj.confirm;

  static List<dynamic> _values(gen8.Person obj) => [
    obj.name,
    obj.surname,
    obj.age,
    obj.balance,
    obj.isActive,
    obj.plate,
    obj.tag,
    obj.password,
    obj.confirm,
  ];

  static gen8.Person _activator(List list) {
    return gen8.Person(
      list[0],
      list[1],
      list[2],
      list[3],
      list[4],
      list[5],
      list[6],
      list[7],
      list[8],
    );
  }

  static int _hash(gen8.Person obj) =>
      obj.name.hashCode ^
      obj.surname.hashCode ^
      obj.age.hashCode ^
      obj.balance.hashCode ^
      obj.isActive.hashCode ^
      obj.plate.hashCode ^
      obj.tag.hashCode ^
      obj.password.hashCode ^
      obj.confirm.hashCode;

  static bool _equals(gen8.Person a, gen8.Person b) =>
      (a.name == b.name &&
      a.surname == b.surname &&
      a.age == b.age &&
      a.balance == b.balance &&
      a.isActive == b.isActive &&
      a.plate == b.plate &&
      a.tag == b.tag &&
      a.password == b.password &&
      a.confirm == b.confirm);
}

abstract class Person$Copy {
  gen8.Person call({
    gen0.String? name,
    gen0.String? surname,
    gen0.int? age,
    gen0.double? balance,
    gen0.bool? isActive,
    gen0.String? plate,
    gen0.String? tag,
    gen0.String? password,
    gen0.String? confirm,
  });
}

class PersonBuilder implements Person$Copy {
  PersonBuilder([gen8.Person? $src]) {
    if ($src == null) {
      $values = List.filled(9, null);
    } else {
      $values = PersonConverter._values($src);
      this.$src = $src;
    }
  }

  late List<dynamic> $values;

  gen8.Person? $src;

  set name(gen0.String value) {
    $values[0] = value;
  }

  gen0.String get name => $values[0];

  set surname(gen0.String value) {
    $values[1] = value;
  }

  gen0.String get surname => $values[1];

  set age(gen0.int value) {
    $values[2] = value;
  }

  gen0.int get age => $values[2];

  set balance(gen0.double value) {
    $values[3] = value;
  }

  gen0.double get balance => $values[3];

  set isActive(gen0.bool value) {
    $values[4] = value;
  }

  gen0.bool get isActive => $values[4];

  set plate(gen0.String value) {
    $values[5] = value;
  }

  gen0.String get plate => $values[5];

  set tag(gen0.String? value) {
    $values[6] = value;
  }

  gen0.String? get tag => $values[6];

  set password(gen0.String value) {
    $values[7] = value;
  }

  gen0.String get password => $values[7];

  set confirm(gen0.String value) {
    $values[8] = value;
  }

  gen0.String get confirm => $values[8];

  @override
  gen8.Person call({
    Object? name = #sentinel,
    Object? surname = #sentinel,
    Object? age = #sentinel,
    Object? balance = #sentinel,
    Object? isActive = #sentinel,
    Object? plate = #sentinel,
    Object? tag = #sentinel,
    Object? password = #sentinel,
    Object? confirm = #sentinel,
  }) {
    if (name != #sentinel) {
      this.name = name as gen0.String;
    }
    if (surname != #sentinel) {
      this.surname = surname as gen0.String;
    }
    if (age != #sentinel) {
      this.age = age as gen0.int;
    }
    if (balance != #sentinel) {
      this.balance = balance as gen0.double;
    }
    if (isActive != #sentinel) {
      this.isActive = isActive as gen0.bool;
    }
    if (plate != #sentinel) {
      this.plate = plate as gen0.String;
    }
    if (tag != #sentinel) {
      this.tag = tag as gen0.String?;
    }
    if (password != #sentinel) {
      this.password = password as gen0.String;
    }
    if (confirm != #sentinel) {
      this.confirm = confirm as gen0.String;
    }
    return build();
  }

  gen8.Person build() {
    var instance = PersonConverter._activator($values);

    return instance;
  }
}

extension PersonDogsExtension on gen8.Person {
  gen8.Person rebuild(Function(PersonBuilder b) f) {
    var builder = PersonBuilder(this);
    f(builder);
    return builder.build();
  }

  Person$Copy get copy => toBuilder();
  PersonBuilder toBuilder() {
    return PersonBuilder(this);
  }

  Map<String, dynamic> toNative() {
    return gen.dogs.convertObjectToNative(this, gen8.Person);
  }
}
