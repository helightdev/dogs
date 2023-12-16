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

import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_core/dogs_validation.dart';
import 'package:dogs_forms/dogs_forms.dart';
import 'package:example/models/address.dart';
import 'package:flutter/material.dart';

class CallableObj {

  const CallableObj();

  Object? call() {
    return null;
  }

}

@serializable
@AutoForm(decorator: PersonDecorator())
class Person with Dataclass<Person> {
  String name;
  @LengthRange(min: 2, max: 10)
  String surname;
  @Minimum(18)
  int age;

  DateTime birthday;

  @AutoFormField(subtitle: "This is a subtitle", constraints: BoxConstraints(maxWidth: 200))
  Gender gender;

  @AutoFormField(title: "Is Active", subtitle: "Is the person active?")
  bool active;

  @AutoFormField(
    factory: IntSliderFormFieldFactory(),
    subtitle: "Select how happy you are",
    subtitleTranslationKey: "happy"
  )
  @Range(min: 0, max: 10)
  int happiness;

  @AutoFormField(
      factory: DataDropdownFormFieldFactory(#choose, allowNullSelection: true),
  )
  String choose;

  @AutoFormField(
      factory: DataChoiceChipFormFieldFactory(#choose),
  )
  String choose2;

  @AutoFormField(
      factory: DataRadioGroupFormFieldFactory(#choose),
  )
  String choose3;

  @AutoFormField(
    itemInitializer: FactoryInitializer(stringGenerator),
  )
  List<String> tags;

  List<int> ints;

  @AutoFormField(
    itemInitializer: ValueInitializer(0.5),
  )
  List<double> doubles;

  Address address;

  Person(
      {required this.name,
      required this.surname,
      required this.age,
      required this.birthday,
      required this.gender,
      required this.active,
      required this.happiness,
      required this.choose,
      required this.choose2,
      required this.choose3,
      required this.tags,
      required this.ints,
      required this.doubles,
      required this.address});

  void test() {}
}

String stringGenerator() => "Hello World";

const InputBorder noInputBorder = InputBorder.none;

@serializable
enum Gender {
  male,
  female,
  diverse,
}

class PersonDecorator extends FormColumnDecorator<Person> {
  const PersonDecorator();

  @override
  void decorate(BuildContext context, FormStackConfigurator configurator) {
    configurator.row(["name", "surname"]);
    configurator.row(["age", "birthday"]);
    configurator.field("gender");
    configurator.field("active");
    super.decorate(context, configurator);
  }
}
