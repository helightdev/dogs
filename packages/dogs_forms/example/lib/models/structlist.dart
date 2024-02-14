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
import 'package:dogs_forms/dogs_forms.dart';
import 'package:flutter/material.dart';
import 'package:forms_example/models/address.dart';

@serializable
class StructList with Dataclass<StructList> {
  @AutoFormField(
      factory: CustomizedStructureFormFieldFactory<Address>(
          listTileBuilder: buildAddressTile),
      listReorderable: true)
  final List<Address> customized;

  final List<Address> addresses;

  StructList(this.customized, this.addresses);
}

Widget buildAddressTile(BuildContext context, FormFieldState state,
    StructureDialogCreator<Address> showStructureDialog) {
  var address = state.value as Address?;
  return ListTile(
    leading: const Icon(Icons.location_on),
    title: switch (address) {
      null => const Text("No Street"),
      _ => Text(address.street)
    },
    subtitle: switch (address) {
      null => const Text("No City"),
      _ => Text("${address.zip}, ${address.city}")
    },
    onTap: () {
      showStructureDialog(context, state.value, (value) {
        state.didChange(value);
      });
    },
  );
}
