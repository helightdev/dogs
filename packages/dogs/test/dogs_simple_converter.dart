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

import 'dart:convert';

import 'package:dogs_core/dogs_core.dart';
import 'package:test/test.dart';

class Person {
  final String name;
  final int age;

  Person({required this.name, required this.age});

  @override
  String toString() {
    return 'Person{name: $name, age: $age}';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
    };
  }

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      name: map['name'] as String,
      age: map['age'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Person &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          age == other.age;

  @override
  int get hashCode => name.hashCode ^ age.hashCode;
}

class FakeDogConverter extends SimpleDogConverter<Person> {
  FakeDogConverter() : super(serialName: "Person");

  @override
  dynamic serialize(Person value, DogEngine engine) {
    return jsonEncode(value.toMap());
  }

  @override
  Person deserialize(dynamic value, DogEngine engine) {
    return Person.fromMap(jsonDecode(value));
  }
}

void main() {
  group('SimpleDogConverter', () {
    final fakeEngine = DogEngine();
    fakeEngine.registerAutomatic(FakeDogConverter());

    test('Serialization', () {
      final encoded = fakeEngine.jsonEncode<Person>(
          Person(name: "John", age: 42)
      );
      expect(encoded, r'"{\"name\":\"John\",\"age\":42}"');
      var decoded = fakeEngine.jsonDecode<Person>(encoded);
      expect(decoded, Person(name: "John", age: 42));
    });

    test("Exists structure", () {
      expect(fakeEngine.findStructureByType(Person), isNotNull);
    });

    test("Exists associated converter", () {
      expect(fakeEngine.findAssociatedConverter(Person), isNotNull);
    });
  });
}