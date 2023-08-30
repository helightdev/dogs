import 'dart:core';
import 'package:dogs_core/dogs_core.dart' as gen;
import 'package:lyell/lyell.dart' as gen;
import 'dart:core' as gen0;
import 'package:dogs_core/src/converter.dart' as gen1;
import 'package:benchmarks/dataclasses.dart' as gen2;
import 'package:benchmarks/dataclasses.dart';

class DogBenchmarkDataclassEntityConverter extends gen.DefaultStructureConverter<gen2.DogBenchmarkDataclassEntity> {
  DogBenchmarkDataclassEntityConverter()
      : super(
            struct: const gen.DogStructure<gen2.DogBenchmarkDataclassEntity>(
                'DogBenchmarkDataclassEntity',
                gen.StructureConformity.dataclass,
                [
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), gen.TypeToken<gen0.String>(), null, gen.IterableKind.none, 'name', false, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.int>(), gen.TypeToken<gen0.int>(), null, gen.IterableKind.none, 'age', false, false, []),
                  gen.DogStructureField(gen.QualifiedTypeTreeN<gen0.List<gen0.String>, gen0.List<dynamic>>([gen.QualifiedTerminal<gen0.String>()]), gen.TypeToken<gen0.String>(), null,
                      gen.IterableKind.list, 'tags', false, false, []),
                  gen.DogStructureField(
                      gen.QualifiedTypeTreeN<gen0.Map<gen0.String, gen0.String>, gen0.Map<dynamic, dynamic>>([gen.QualifiedTerminal<gen0.String>(), gen.QualifiedTerminal<gen0.String>()]),
                      gen.TypeToken<gen0.Map<gen0.String, gen0.String>>(),
                      null,
                      gen.IterableKind.none,
                      'fields',
                      false,
                      true,
                      [gen1.polymorphic])
                ],
                [],
                gen.ObjectFactoryStructureProxy<gen2.DogBenchmarkDataclassEntity>(_activator, [_name, _age, _tags, _fields], _values, _hash, _equals)));

  static dynamic _name(gen2.DogBenchmarkDataclassEntity obj) => obj.name;
  static dynamic _age(gen2.DogBenchmarkDataclassEntity obj) => obj.age;
  static dynamic _tags(gen2.DogBenchmarkDataclassEntity obj) => obj.tags;
  static dynamic _fields(gen2.DogBenchmarkDataclassEntity obj) => obj.fields;
  static List<dynamic> _values(gen2.DogBenchmarkDataclassEntity obj) => [obj.name, obj.age, obj.tags, obj.fields];
  static gen2.DogBenchmarkDataclassEntity _activator(List list) {
    return DogBenchmarkDataclassEntity(list[0], list[1], list[2].cast<gen0.String>(), list[3]);
  }

  static int _hash(gen2.DogBenchmarkDataclassEntity obj) => obj.name.hashCode ^ obj.age.hashCode ^ gen.deepEquality.hash(obj.tags) ^ gen.deepEquality.hash(obj.fields);
  static bool _equals(
    gen2.DogBenchmarkDataclassEntity a,
    gen2.DogBenchmarkDataclassEntity b,
  ) =>
      (a.name == b.name && a.age == b.age && gen.deepEquality.equals(a.tags, b.tags) && gen.deepEquality.equals(a.fields, b.fields));
}

class DogBenchmarkDataclassEntityBuilder {
  DogBenchmarkDataclassEntityBuilder([gen2.DogBenchmarkDataclassEntity? $src]) {
    if ($src == null) {
      $values = List.filled(4, null);
    } else {
      $values = DogBenchmarkDataclassEntityConverter._values($src);
    }
  }

  late List<dynamic> $values;

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
  gen2.DogBenchmarkDataclassEntity build() => DogBenchmarkDataclassEntityConverter._activator($values);
}

extension DogBenchmarkDataclassEntityDogsExtension on gen2.DogBenchmarkDataclassEntity {
  @Deprecated("Use rebuild() instead")
  gen2.DogBenchmarkDataclassEntity builder(Function(DogBenchmarkDataclassEntityBuilder builder) func) {
    var builder = DogBenchmarkDataclassEntityBuilder(this);
    func(builder);
    return builder.build();
  }

  gen2.DogBenchmarkDataclassEntity rebuild(Function(DogBenchmarkDataclassEntityBuilder b) f) {
    var builder = DogBenchmarkDataclassEntityBuilder(this);
    f(builder);
    return builder.build();
  }

  DogBenchmarkDataclassEntityBuilder toBuilder() {
    return DogBenchmarkDataclassEntityBuilder(this);
  }

  Map<String, dynamic> toNative() {
    return gen.dogs.convertObjectToNative(this, gen2.DogBenchmarkDataclassEntity);
  }
}
