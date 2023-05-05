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
import 'package:dogs_core/dogs_core.dart';
import 'package:equatable/equatable.dart';
import 'package:mock_data/mock_data.dart';

part 'dataclasses.g.dart';

@serializable
class DogBenchmarkDataclassEntity with Dataclass<DogBenchmarkDataclassEntity> {

  final String name;
  final int age;
  final List<String> tags;

  @polymorphic
  final Map<String,String> fields;

  DogBenchmarkDataclassEntity(this.name, this.age, this.tags, this.fields);
}

class NativeBenchmarkDataclassEntity {

  final String name;
  final int age;
  final List<String> tags;
  final Map<String,String> fields;

  NativeBenchmarkDataclassEntity(this.name, this.age, this.tags, this.fields);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NativeBenchmarkDataclassEntity &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          age == other.age &&
          deepEquality.equals(tags, other.tags) &&
          deepEquality.equals(fields, other.fields);

  @override
  int get hashCode =>
      name.hashCode ^ age.hashCode ^ deepEquality.hash(tags) ^ deepEquality.hash(fields);
}

class EquatableBenchmarkDataclassEntity extends Equatable {

  final String name;
  final int age;
  final List<String> tags;
  final Map<String,String> fields;

  EquatableBenchmarkDataclassEntity(this.name, this.age, this.tags, this.fields);

  @override
  List<Object?> get props => [name, age, tags, fields];

}

abstract class BuiltBenchmarkDataclassEntity implements Built<BuiltBenchmarkDataclassEntity, BuiltBenchmarkDataclassEntityBuilder> {
  static Serializer<BuiltBenchmarkDataclassEntity> get serializer => _$builtBenchmarkDataclassEntitySerializer;

  String get name;
  int get age;
  BuiltList<String> get tags;
  BuiltMap<String,String> get fields;


  factory BuiltBenchmarkDataclassEntity([Function(BuiltBenchmarkDataclassEntityBuilder) updates]) = _$BuiltBenchmarkDataclassEntity;
  BuiltBenchmarkDataclassEntity._();
}

Map<DogBenchmarkDataclassEntity, int> dogMap(int count) {
  var map = <DogBenchmarkDataclassEntity, int>{};
  for (var i = 0; i < count; i++) {
    map[DogBenchmarkDataclassEntity(
        mockName(),
        mockInteger(),
        List.generate(mockInteger(), (index) => mockString()),
        Map.fromEntries(List.generate(mockInteger(), (index) => MapEntry<String,String>("$index-k", mockColor())))
    )] = i;
  }
  return map;
}

Map<NativeBenchmarkDataclassEntity, int> nativeMap(int count) {
  var map = <NativeBenchmarkDataclassEntity, int>{};
  for (var i = 0; i < count; i++) {
    map[NativeBenchmarkDataclassEntity(
        mockName(),
        mockInteger(),
        List.generate(mockInteger(), (index) => mockString()),
        Map.fromEntries(List.generate(mockInteger(), (index) => MapEntry<String,String>("$index-k", mockColor())))
    )] = i;
  }
  return map;
}

Map<EquatableBenchmarkDataclassEntity, int> equatableMap(int count) {
  var map = <EquatableBenchmarkDataclassEntity, int>{};
  for (var i = 0; i < count; i++) {
    map[EquatableBenchmarkDataclassEntity(
        mockName(),
        mockInteger(),
        List.generate(mockInteger(), (index) => mockString()),
        Map.fromEntries(List.generate(mockInteger(), (index) => MapEntry<String,String>("$index-k", mockColor())))
    )] = i;
  }
  return map;
}

Map<BuiltBenchmarkDataclassEntity, int> builtMap(int count) {
  var map = <BuiltBenchmarkDataclassEntity, int>{};
  for (var i = 0; i < count; i++) {
    map[BuiltBenchmarkDataclassEntity((builder) => builder
        ..name = mockName()
        ..age = mockInteger()
        ..tags = ListBuilder(List.generate(mockInteger(), (index) => mockString()))
        ..fields = MapBuilder(Map.fromEntries(List.generate(mockInteger(), (index) => MapEntry<String,String>("$index-k", mockColor()))))
    )] = i;
  }
  return map;
}