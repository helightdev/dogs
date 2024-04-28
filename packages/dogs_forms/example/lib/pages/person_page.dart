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

import 'package:dogs_forms/dogs_forms.dart';
import 'package:forms_example/form_print_wrapper.dart';
import 'package:forms_example/models/address.dart';
import 'package:forms_example/models/person.dart';
import 'package:flutter/material.dart';

class PersonPage extends StatelessWidget {
  const PersonPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormPrintWrapper<Person>(
      exampleValue: Person(
          name: "John",
          surname: "Doe",
          age: 42,
          active: true,
          birthday: DateTime(1981, 12, 1),
          gender: Gender.male,
          happiness: 8,
          favouriteColor: ColorFormFieldUtils.encodeColor(Colors.indigo),
      ),
      modelCode: """
@serializable
@AutoForm(decorator: PersonDecorator())
class Person with Dataclass<Person> {
  String name;

  @LengthRange(min: 2, max: 10)
  String surname;

  @Minimum(18)
  @AutoFormField()
  int age;

  DateTime birthday;

  @AutoFormField(
      subtitle: "This is a subtitle",
      constraints: BoxConstraints(maxWidth: 200)
  )
  Gender gender;

  @AutoFormField(
      title: "Is Active",
      subtitle: "Is the person active?"
  )
  bool active;

  @AutoFormField(
    factory: IntSliderFormFieldFactory(),
    subtitle: "Select how happy you are",
    subtitleTranslationKey: "happy",
  )
  @Range(min: 0, max: 10)
  int happiness;

  @AutoFormField(
    factory: ColorFormFieldFactory(),
    title: "Favourite Color",
    subtitle: "Select your favourite color",
  )
  String favouriteColor;

  Person(
      {required this.name,
      required this.surname,
      required this.age,
      required this.birthday,
      required this.gender,
      required this.active,
      required this.happiness,
      required this.favouriteColor
  });
}

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
""".trim(),
    );
  }
}
