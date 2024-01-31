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

import 'package:forms_example/form_print_wrapper.dart';
import 'package:forms_example/models/address.dart';
import 'package:flutter/material.dart';

class AddressPage extends StatelessWidget {
  const AddressPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormPrintWrapper<Address>(
      exampleValue: Address(
        "123 Main Street",
        "Anytown",
        "12345",
      ),
      modelCode: """
@serializable
@AutoForm(decorator: AddressDecorator())
class Address {
  @AutoFormField(flex: 6)
  final String street;
  @AutoFormField(flex: 3)
  final String city;

  @AutoFormField(constraints: BoxConstraints(maxWidth: 96), flex: -1)
  @LengthRange(min: 5, max: 5)
  final String zip;

  Address(this.street, this.city, this.zip);
}

class AddressDecorator extends FormColumnDecorator<Address> {
  const AddressDecorator();

  @override
  void decorate(BuildContext context, FormStackConfigurator configurator) {
    configurator.row(["street", "city", "zip"]);
    return super.decorate(context, configurator);
  }
}
""".trim(),
    );
  }
}
