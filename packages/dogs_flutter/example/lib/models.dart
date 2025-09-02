/*
 *    Copyright 2022, the DOGs authors
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License
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

import 'package:dogs_flutter/dogs_flutter.dart';
import 'package:flutter/material.dart';

@serializable
class Person with Dataclass<Person> {
  @LengthRange(min: 3, max: 10)
  String name;

  @LengthRange(min: 3)
  String surname;

  @Range(min: 18, max: 99)
  int age;

  double balance;

  bool isActive;

  String plate;

  String? tag;

  @LengthRange(min: 3)
  @MaterialBindingStyle.inputTheme(
    InputDecorationThemeData(border: OutlineInputBorder()),
  )
  String password;

  @MustMatch("password")
  @BindingStyle(hint: "Repeat the password", label: "Confirm password")
  String confirm;

  Person(
    this.name,
    this.surname,
    this.age,
    this.balance,
    this.isActive,
    this.plate,
    this.tag,
    this.password,
    this.confirm,
  );
}
