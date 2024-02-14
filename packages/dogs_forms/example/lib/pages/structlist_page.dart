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

import 'package:flutter/material.dart';
import 'package:forms_example/form_print_wrapper.dart';
import 'package:forms_example/models/address.dart';
import 'package:forms_example/models/structlist.dart';

class StructListPage extends StatelessWidget {
  const StructListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormPrintWrapper<StructList>(
      exampleValue: StructList(
        [
          Address("street1", "city1", "zip1"),
          Address("street2", "city2", "zip2"),
        ],
        [
          Address("street3", "city3", "zip3"),
          Address("street4", "city4", "zip4"),
        ],
      ),
      modelCode: """
@serializable
class StructList with Dataclass<StructList> {

  @AutoFormField(
    factory: CustomizedStructureFormFieldFactory<Address>(
      listTileBuilder: buildAddressTile
    )
  )
  final List<Address> customized;
  
  final List<Address> addresses;

  StructList(this.customized, this.addresses);
  
}

Widget buildAddressTile(BuildContext context, FormFieldState state, StructureDialogCreator<Address> showStructureDialog) {
  var address = state.value as Address?;
  return ListTile(
    leading: const Icon(Icons.location_on),
    title: const Text("Address"),
    trailing: const Icon(Icons.edit),
    subtitle: switch(address) {
      null => const Text("No address"),
      _ => Text("\${address.street}, \${address.city}, \${address.zip}")
    },
    onTap: () {
      showStructureDialog(context, state.value, (value) {
        state.didChange(value);
      });
    },
  );
}
"""
          .trim(),
    );
  }
}
