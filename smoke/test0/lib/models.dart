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
import 'package:smoke_test_0/special.dart';

abstract class ABInterface {}

@serializable
class ModelA with Dataclass<ModelA> implements ABInterface {

  final String string;
  final int integer;
  @PropertyName("double")
  final double $double;
  final bool boolean;
  final DateTime nonStruct;
  final Note complex;

  ModelA(this.string, this.integer, this.$double, this.boolean, this.nonStruct, this.complex);

  factory ModelA.variant0() {
    return ModelA("str", 1, 1.337, true, DateTime(1999), Note.variant0());
  }

  factory ModelA.variant1() {
    return ModelA("_", 100, -420.420, true, DateTime(2023), Note.variant1());
  }
}

@serializable
class ModelB with Dataclass<ModelB> implements ABInterface {

  final List<String> stringList;
  final List<int> intList;
  final List<double> doubleList;
  final List<bool> booleanList;

  ModelB(this.stringList, this.intList, this.doubleList, this.booleanList);

  factory ModelB.variant0() {
    return ModelB(["A", "B"], [1,2], [0.01, 0.02], [true, true, false]);
  }

  factory ModelB.variant1() {
    return ModelB(["C", "D"], [-1,-2], [-0.01, -0.02], [false]);
  }
}

@serializable
class ModelC with Dataclass<ModelC> {

  String? nullablePrimitive;
  List<String>? nullableList;
  Note? nullableComplex;
  Set<Note>? nullableComplexSet;

  ModelC(this.nullablePrimitive, this.nullableList, this.nullableComplex,
      this.nullableComplexSet);

  factory ModelC.variant0() {
    return ModelC(null, null, null, null);
  }

  factory ModelC.variant1() {
    return ModelC("string", ["A", "B", "C"], Note.variant0(), {Note.variant0(), Note.variant1()});
  }
}

@serializable
class ModelD with Dataclass<ModelD> {

  final Set<String> stringList;
  final Set<int> intList;
  final Set<double> doubleList;
  final Set<bool> booleanList;

  ModelD(this.stringList, this.intList, this.doubleList, this.booleanList);

  factory ModelD.variant0() {
    return ModelD({"A", "B"}, {1,2}, {0.01, 0.02}, {true, false});
  }

  factory ModelD.variant1() {
    return ModelD({"C", "D"}, {-1,-2}, {-0.01, -0.02}, {false});
  }
}

@serializable
class ModelE with Dataclass<ModelE> {

  @polymorphic
  final List polymorphicList;

  @polymorphic
  final List<ABInterface> restrictedPolymorphicList;

  ModelE(this.polymorphicList, this.restrictedPolymorphicList);

  factory ModelE.variant0() {
    return ModelE([ModelA.variant0(), ModelB.variant0(), ModelC.variant0(), ModelD.variant0()], [ModelA.variant1(), ModelB.variant0()]);
  }

  factory ModelE.variant1() {
    return ModelE([ModelA.variant1(), ModelB.variant1(), ModelC.variant1(), ModelD.variant1()], [ModelA.variant0(), ModelB.variant1()]);
  }
}

@serializable
class ModelF with Dataclass<ModelF> {

  ConvertableA a;
  EnumA enumeration;

  ModelF(this.a, this.enumeration);

  factory ModelF.variant0() {
    return ModelF(ConvertableA(3, 9), EnumA.a);
  }

  factory ModelF.variant1() {
    return ModelF(ConvertableA(7, 49), EnumA.c);
  }
}

@serializable
class ModelG with Dataclass<ModelG> {

  List<List<int>>? ints;
  Map<String, Set<double>>? m;
  Map<String, List<Object>> dyna;

  ModelG(this.ints, this.m, this.dyna);

  factory ModelG.variant0() {
    return ModelG([[1,2,3],[4,5,6]], {"a": {1,2,3}, "b" : {1.1,2.2,3.3}}, {
      "test": [Note.variant0(), "Hello World"]
    });
  }

  factory ModelG.variant1() {
    return ModelG(null, null, {});
  }
}

@serializable
class Note with Dataclass<Note> {
  String? title;
  String content;
  bool private;
  DateTime timestamp;
  Set<String> tags;

  Note(this.title, this.content, this.private, this.timestamp, this.tags);

  factory Note.variant0() {
    return Note("Hello World", "Lorem Ipsum", false, DateTime(2023), {"note","dart"});
  }

  factory Note.variant1() {
    return Note(null, "Lorem Ipsum Dolor", true, DateTime(2022), {});
  }
}