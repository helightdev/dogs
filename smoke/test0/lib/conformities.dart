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

@serializable
class ConformityBean {

  late String id;
  String? name;
  int? age;

  @beanIgnore
  String? ignored;

  ConformityBean();

  factory ConformityBean.variant0() {
    return ConformityBean()
      ..id = "p0"
      ..name = "Alex"
      ..age = 20
    ;
  }


  factory ConformityBean.variant1() {
    return ConformityBean()
      ..id = "p1"
      ..name = "Ben"
      ..age = 25
    ;
  }

}

@serializable
class ConformityBasic {

  String id;
  String? name;
  int? age;

  ConformityBasic(this.id, this.name, this.age);

  factory ConformityBasic.variant0() {
    return ConformityBasic("p0", "Alex", 20);
  }

  factory ConformityBasic.variant1() {
    return ConformityBasic("p1", "Ben", 25);
  }
}

@serializable
class ConformityData with Dataclass<ConformityData> {

  final String id;
  final String? name;
  final int? age;

  ConformityData(this.id, this.name, this.age);


  factory ConformityData.variant0() {
    return ConformityData("p0", "Alex", 20);
  }

  factory ConformityData.variant1() {
    return ConformityData("p1", "Ben", 25);
  }
}