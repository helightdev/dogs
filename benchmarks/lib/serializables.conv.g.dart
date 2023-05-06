import 'dart:core';
import 'package:dogs_core/dogs_core.dart' as gen;
import 'package:lyell/lyell.dart' as gen;
import 'dart:core' as gen0;
import 'package:benchmarks/serializables.dart' as gen1;
import 'package:benchmarks/serializables.dart';

class DogPersonConverter extends gen.DefaultStructureConverter<gen1.DogPerson> {
  @override
  final gen.DogStructure<gen1.DogPerson> structure = const gen.DogStructure<gen1.DogPerson>(
      'DogPerson',
      gen.StructureConformity.basic,
      [
        gen.DogStructureField(gen0.String, gen.TypeToken<gen0.String>(), null, gen.IterableKind.none, 'name', false, false, []),
        gen.DogStructureField(gen0.int, gen.TypeToken<gen0.int>(), null, gen.IterableKind.none, 'age', false, false, []),
        gen.DogStructureField(gen0.List<gen0.String>, gen.TypeToken<gen0.String>(), null, gen.IterableKind.list, 'tags', false, false, [])
      ],
      [],
      gen.ObjectFactoryStructureProxy<gen1.DogPerson>(_activator, [_name, _age, _tags], _values));

  static dynamic _name(gen1.DogPerson obj) => obj.name;
  static dynamic _age(gen1.DogPerson obj) => obj.age;
  static dynamic _tags(gen1.DogPerson obj) => obj.tags;
  static List<dynamic> _values(gen1.DogPerson obj) => [obj.name, obj.age, obj.tags];
  static gen1.DogPerson _activator(List list) {
    return DogPerson(list[0], list[1], list[2].cast<gen0.String>());
  }
}

class DogPersonBuilder {
  DogPersonBuilder([gen1.DogPerson? $src]) {
    if ($src == null) {
      $values = List.filled(3, null);
    } else {
      $values = DogPersonConverter._values($src);
    }
  }

  late List<dynamic> $values;

  set name(gen0.String value) {
    $values[0] = value;
  }

  set age(gen0.int value) {
    $values[1] = value;
  }

  set tags(gen0.List<gen0.String> value) {
    $values[2] = value;
  }

  gen1.DogPerson build() => DogPersonConverter._activator($values);
}

extension DogPersonDogsExtension on gen1.DogPerson {
  @Deprecated("Use rebuild() instead")
  DogPerson builder(Function(DogPersonBuilder builder) func) {
    var builder = DogPersonBuilder(this);
    func(builder);
    return builder.build();
  }

  DogPerson rebuild(Function(DogPersonBuilder b) f) {
    var builder = DogPersonBuilder(this);
    f(builder);
    return builder.build();
  }

  DogPersonBuilder toBuilder() {
    return DogPersonBuilder(this);
  }
}