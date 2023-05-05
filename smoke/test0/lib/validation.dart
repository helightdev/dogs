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

@serializable
class ValidateA with Dataclass<ValidateA> {

  @LengthRange(min: 2, max: 4)
  String str;

  ValidateA(this.str);

  static List<ValidateA> trues() {
    return [ValidateA("123"), ValidateA("12"), ValidateA("1234")];
  }

  static List<ValidateA> falses() {
    return [ValidateA("1"), ValidateA("12345")];
  }
}

@serializable
class ValidateB with Dataclass<ValidateB> {

  @Range(min: 1, max: 2)
  double number;
  
  ValidateB(this.number);

  static List<ValidateB> trues() {
    return [ValidateB(1.0), ValidateB(1.5), ValidateB(2.0)];
  }

  static List<ValidateB> falses() {
    return [ValidateB(0.9), ValidateB(2.1)];
  }
}

@serializable
class ValidateC with Dataclass<ValidateC> {

  @Range(min: 1, max: 2, minExclusive: true, maxExclusive: true)
  double number;

  ValidateC(this.number);

  static List<ValidateC> trues() {
    return [ValidateC(1.1), ValidateC(1.5), ValidateC(1.9)];
  }

  static List<ValidateC> falses() {
    return [ValidateC(1.0), ValidateC(2.0), ValidateC(3.0)];
  }
}

@serializable
class ValidateD with Dataclass<ValidateD> {

  @SizeRange(min: 1, max: 2)
  List<int> list;

  ValidateD(this.list);

  static List<ValidateD> trues() {
    return [ValidateD([1]), ValidateD([1,2])];
  }

  static List<ValidateD> falses() {
    return [ValidateD([]), ValidateD([1,2,3])];
  }
}

@serializable
class ValidateE with Dataclass<ValidateE> {

  @notBlank
  String str;

  ValidateE(this.str);

  static List<ValidateE> trues() {
    return [ValidateE("      1   "), ValidateE("_ ")];
  }

  static List<ValidateE> falses() {
    return [ValidateE(" "), ValidateE("\n")];
  }
}

@serializable
class ValidateF with Dataclass<ValidateF> {
  @validated
  ValidateA a;

  ValidateF(this.a);

  static List<ValidateF> trues() {
    return [ValidateF(ValidateA("123")), ValidateF(ValidateA("12")), ValidateF(ValidateA("1234"))];
  }

  static List<ValidateF> falses() {
    return [ValidateF(ValidateA("1")), ValidateF(ValidateA("12345"))];
  }
}