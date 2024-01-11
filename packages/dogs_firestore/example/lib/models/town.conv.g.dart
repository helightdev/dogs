import 'dart:core';
import 'package:dogs_core/dogs_core.dart' as gen;
import 'package:lyell/lyell.dart' as gen;
import 'dart:core' as gen0;
import 'package:example/models/town.dart' as gen1;
import 'package:dogs_firestore/src/annotations.dart' as gen2;
import 'package:example/models/town.dart';

class TownConverter extends gen.DefaultStructureConverter<gen1.Town> {
  TownConverter()
      : super(
            struct: const gen.DogStructure<gen1.Town>(
                'Town',
                gen.StructureConformity.dataclass,
                [
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), gen.TypeToken<gen0.String>(), null, gen.IterableKind.none, 'name', false, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), gen.TypeToken<gen0.String>(), null, gen.IterableKind.none, 'country', false, false, [])
                ],
                [gen2.Collection()],
                gen.ObjectFactoryStructureProxy<gen1.Town>(_activator, [_$name, _$country], _values, _hash, _equals)));

  static dynamic _$name(gen1.Town obj) => obj.name;

  static dynamic _$country(gen1.Town obj) => obj.country;

  static List<dynamic> _values(gen1.Town obj) => [obj.name, obj.country];

  static gen1.Town _activator(List list) {
    return Town(list[0], list[1]);
  }

  static int _hash(gen1.Town obj) => obj.name.hashCode ^ obj.country.hashCode;

  static bool _equals(
    gen1.Town a,
    gen1.Town b,
  ) =>
      (a.name == b.name && a.country == b.country);
}

class TownBuilder {
  TownBuilder([gen1.Town? $src]) {
    if ($src == null) {
      $values = List.filled(2, null);
    } else {
      $values = TownConverter._values($src);
    }
  }

  late List<dynamic> $values;

  set name(gen0.String value) {
    $values[0] = value;
  }

  gen0.String get name => $values[0];

  set country(gen0.String value) {
    $values[1] = value;
  }

  gen0.String get country => $values[1];

  gen1.Town build() => TownConverter._activator($values);
}

extension TownDogsExtension on gen1.Town {
  @Deprecated("Use rebuild() instead")
  gen1.Town builder(Function(TownBuilder builder) func) {
    var builder = TownBuilder(this);
    func(builder);
    return builder.build();
  }

  gen1.Town rebuild(Function(TownBuilder b) f) {
    var builder = TownBuilder(this);
    f(builder);
    return builder.build();
  }

  TownBuilder toBuilder() {
    return TownBuilder(this);
  }

  Map<String, dynamic> toNative() {
    return gen.dogs.convertObjectToNative(this, gen1.Town);
  }
}
