import 'dart:core';
import 'package:dogs_core/dogs_core.dart' as gen;
import 'package:lyell/lyell.dart' as gen;
import 'dart:core' as gen0;
import 'package:cloud_firestore_platform_interface/src/timestamp.dart' as gen1;
import 'package:cloud_firestore_platform_interface/src/geo_point.dart' as gen2;
import 'package:example/models/person.dart' as gen3;
import 'package:dogs_firestore/src/annotations.dart' as gen4;
import 'package:example/models/town.dart' as gen5;
import 'package:example/models/person.dart';

class PersonConverter extends gen.DefaultStructureConverter<gen3.Person> {
  PersonConverter()
      : super(
            struct: const gen.DogStructure<gen3.Person>(
                'Person',
                gen.StructureConformity.dataclass,
                [
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.String>(), gen.TypeToken<gen0.String>(), null, gen.IterableKind.none, 'name', false, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.int>(), gen.TypeToken<gen0.int>(), null, gen.IterableKind.none, 'age', false, false, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen0.DateTime>(), gen.TypeToken<gen0.DateTime>(), null, gen.IterableKind.none, 'birthDate', true, true, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen1.Timestamp>(), gen.TypeToken<gen1.Timestamp>(), null, gen.IterableKind.none, 'timestamp', true, true, []),
                  gen.DogStructureField(gen.QualifiedTerminal<gen2.GeoPoint>(), gen.TypeToken<gen2.GeoPoint>(), null, gen.IterableKind.none, 'location', true, true, [])
                ],
                [gen4.Collection(subcollectionOf: gen5.Town)],
                gen.ObjectFactoryStructureProxy<gen3.Person>(_activator, [_$name, _$age, _$birthDate, _$timestamp, _$location], _values, _hash, _equals)));

  static dynamic _$name(gen3.Person obj) => obj.name;

  static dynamic _$age(gen3.Person obj) => obj.age;

  static dynamic _$birthDate(gen3.Person obj) => obj.birthDate;

  static dynamic _$timestamp(gen3.Person obj) => obj.timestamp;

  static dynamic _$location(gen3.Person obj) => obj.location;

  static List<dynamic> _values(gen3.Person obj) => [obj.name, obj.age, obj.birthDate, obj.timestamp, obj.location];

  static gen3.Person _activator(List list) {
    return Person(list[0], list[1], list[2], list[3], list[4]);
  }

  static int _hash(gen3.Person obj) => obj.name.hashCode ^ obj.age.hashCode ^ obj.birthDate.hashCode ^ obj.timestamp.hashCode ^ obj.location.hashCode;

  static bool _equals(
    gen3.Person a,
    gen3.Person b,
  ) =>
      (a.name == b.name && a.age == b.age && a.birthDate == b.birthDate && a.timestamp == b.timestamp && a.location == b.location);
}

class PersonBuilder {
  PersonBuilder([gen3.Person? $src]) {
    if ($src == null) {
      $values = List.filled(5, null);
    } else {
      $values = PersonConverter._values($src);
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

  set birthDate(gen0.DateTime? value) {
    $values[2] = value;
  }

  gen0.DateTime? get birthDate => $values[2];

  set timestamp(gen1.Timestamp? value) {
    $values[3] = value;
  }

  gen1.Timestamp? get timestamp => $values[3];

  set location(gen2.GeoPoint? value) {
    $values[4] = value;
  }

  gen2.GeoPoint? get location => $values[4];

  gen3.Person build() => PersonConverter._activator($values);
}

extension PersonDogsExtension on gen3.Person {
  @Deprecated("Use rebuild() instead")
  gen3.Person builder(Function(PersonBuilder builder) func) {
    var builder = PersonBuilder(this);
    func(builder);
    return builder.build();
  }

  gen3.Person rebuild(Function(PersonBuilder b) f) {
    var builder = PersonBuilder(this);
    f(builder);
    return builder.build();
  }

  PersonBuilder toBuilder() {
    return PersonBuilder(this);
  }

  Map<String, dynamic> toNative() {
    return gen.dogs.convertObjectToNative(this, gen3.Person);
  }
}
