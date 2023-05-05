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
import 'package:equatable/equatable.dart';

import 'dogs.g.dart';

void main() {
  var engine = DogEngine();
  engine.setSingleton();
  installExampleConverters();
  cacheDataclassHashCodes = true;

  var a = DataclassTest("Alice", 1, ["We", "Are", "Family"]);
  var b = DataclassTest("Bob", 2, ["Test", "Data", "Filler"]);
  var c = DataclassTest("Alice", 1, ["We", "Are", "Family"]);
  print(a == a);
  print(a == b);
  print(a == c);
  print("===");
  print(a.hashCode == a.hashCode);
  print(a.hashCode == b.hashCode);
  print(a.hashCode == c.hashCode);
}


@serializable
class DataclassTest with Dataclass<DataclassTest> {

  final String string;
  final int integer;
  final List<String> tags;

  DataclassTest(this.string, this.integer, this.tags);
}