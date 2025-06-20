/*
 *    Copyright 2022, the DOGs authors
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:dogs_core/dogs_core.dart' as dogs;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mock_data/mock_data.dart';

part 'serializables.freezed.dart';
part 'serializables.g.dart';
part 'serializables.mapper.dart';

DogPerson dogPerson() {
  return DogPerson(
      mockString(), mockInteger(), List.generate(5, (index) => mockString()));
}

JsonSerializablePerson jsonSerializablePerson() {
  return JsonSerializablePerson(
      mockString(), mockInteger(), List.generate(5, (index) => mockString()));
}

BuiltPerson builtPerson() {
  return BuiltPerson((func) => func
    ..name = mockString()
    ..age = mockInteger()
    ..tags = ListBuilder(List.generate(5, (index) => mockString())));
}

NativePerson nativePerson() {
  return NativePerson(
      name: mockString(),
      age: mockInteger(),
      tags: List.generate(5, (index) => mockString()));
}

FreezedPerson freezedPerson() {
  return FreezedPerson(
      name: mockString(),
      age: mockInteger(),
      tags: List.generate(5, (index) => mockString()));
}

MappablePerson mappablePerson() {
  return MappablePerson(
      mockString(), mockInteger(), List.generate(5, (index) => mockString()));
}

@dogs.serializable
class DogPerson {
  String name;
  int age;
  List<String> tags;

  DogPerson(this.name, this.age, this.tags);
}

abstract class BuiltPerson implements Built<BuiltPerson, BuiltPersonBuilder> {
  static Serializer<BuiltPerson> get serializer => _$builtPersonSerializer;

  String get name;
  int get age;
  BuiltList<String> get tags;

  factory BuiltPerson([Function(BuiltPersonBuilder) updates]) = _$BuiltPerson;
  BuiltPerson._();
}

class NativePerson {
  String name;
  int age;
  List<String> tags;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'tags': tags,
    };
  }

  factory NativePerson.fromMap(Map<String, dynamic> map) {
    return NativePerson(
      name: map['name'] as String,
      age: map['age'] as int,
      tags: (map['tags'] as List).cast<String>(),
    );
  }

  NativePerson({
    required this.name,
    required this.age,
    required this.tags,
  });
}

@MappableClass()
class MappablePerson with MappablePersonMappable {
  String name;
  int age;
  List<String> tags;

  MappablePerson(this.name, this.age, this.tags);
}

@JsonSerializable()
class JsonSerializablePerson {
  String name;
  int age;
  List<String> tags;

  JsonSerializablePerson(this.name, this.age, this.tags);

  /// factory.
  factory JsonSerializablePerson.fromJson(Map<String, dynamic> json) =>
      _$JsonSerializablePersonFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$JsonSerializablePersonToJson(this);
}

@freezed
@JsonSerializable()
class FreezedPerson with _$FreezedPerson {
  final String name;
  final int age;
  final List<String> tags;

  const FreezedPerson({
    required this.name,
    required this.age,
    required this.tags,
  });

  Map<String, dynamic> toJson() => _$FreezedPersonToJson(this);

  factory FreezedPerson.fromJson(Map<String, dynamic> json) =>
      _$FreezedPersonFromJson(json);
}

@SerializersFor([BuiltPerson])
Serializers serializers = _$serializers;
