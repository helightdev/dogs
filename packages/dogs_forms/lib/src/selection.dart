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

import 'package:flutter/widgets.dart';

/// A data provider for dogs_forms selection fields like [DataDropdownFormField],
/// [DataRadioGroupFormField] or [DataChoiceChipFormField].
abstract class SelectionDataProvider<T> {
  /// A data provider for dogs_forms selection fields like [DataDropdownFormField],
  /// [DataRadioGroupFormField] or [DataChoiceChipFormField].
  const SelectionDataProvider();

  /// Returns a widget that represents the given value.
  Widget represent(BuildContext context, T? value) =>
      Text(value?.toString() ?? "---");

  /// Returns the data to be used for the selection field.
  List<T> getData(BuildContext context);
}

/// A [SelectionDataProvider] that provides a list of [String]s.

class StringSelectionDataProvider extends SelectionDataProvider<String> {
  /// The list of selectable [String]s.
  final List<String> values;

  /// A [SelectionDataProvider] that provides a list of [String]s.
  const StringSelectionDataProvider(this.values);

  @override
  List<String> getData(BuildContext context) {
    return values;
  }
}
