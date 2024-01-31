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
import 'package:forms_example/models/lists.dart';
import 'package:forms_example/models/post.dart';
import 'package:flutter/material.dart';

class ListsPage extends StatelessWidget {
  const ListsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormPrintWrapper<Lists>(
      exampleValue: Lists(
        [0,1,2,3],
        [0.5, 1.5, 2.5, 3.5],
        ['a','b','c','d'],
        [DateTime(2022), DateTime(2023), DateTime(2024)]
      ),
      modelCode: """
@serializable
class Lists {

  List<int> ints;
  List<double> doubles;
  List<String> strings;

  Lists(this.ints, this.doubles, this.strings);
}
""".trim(),
    );
  }
}
