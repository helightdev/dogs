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

part of "../test.dart";

void testTrees() {
  // Iterable
  testTypeTree(QualifiedTypeTree.iterable<ModelA>(), [ModelA.variant0(), ModelA.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.iterable<ModelB>(), [ModelB.variant0(), ModelB.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.iterable<ModelC>(), [ModelC.variant0(), ModelC.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.iterable<ModelD>(), [ModelD.variant0(), ModelD.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.iterable<ModelE>(), [ModelE.variant0(), ModelE.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.iterable<ModelF>(), [ModelF.variant0(), ModelF.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.iterable<ModelG>(), [ModelG.variant0(), ModelG.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.iterable<dynamic>(), [ModelA.variant0(), ModelA.variant1()], deepEquality.equals);
  // Lists
  testTypeTree(QualifiedTypeTree.list<ModelA>(), [ModelA.variant0(), ModelA.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.list<ModelB>(), [ModelB.variant0(), ModelB.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.list<ModelC>(), [ModelC.variant0(), ModelC.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.list<ModelD>(), [ModelD.variant0(), ModelD.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.list<ModelE>(), [ModelE.variant0(), ModelE.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.list<ModelF>(), [ModelF.variant0(), ModelF.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.list<ModelG>(), [ModelG.variant0(), ModelG.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.list<dynamic>(), [ModelA.variant0(), ModelA.variant1()], deepEquality.equals);
  // Sets
  testTypeTree(QualifiedTypeTree.set<ModelA>(), {ModelA.variant0(), ModelA.variant1()}, deepEquality.equals);
  testTypeTree(QualifiedTypeTree.set<ModelB>(), {ModelB.variant0(), ModelB.variant1()}, deepEquality.equals);
  testTypeTree(QualifiedTypeTree.set<ModelC>(), {ModelC.variant0(), ModelC.variant1()}, deepEquality.equals);
  testTypeTree(QualifiedTypeTree.set<ModelD>(), {ModelD.variant0(), ModelD.variant1()}, deepEquality.equals);
  testTypeTree(QualifiedTypeTree.set<ModelE>(), {ModelE.variant0(), ModelE.variant1()}, deepEquality.equals);
  testTypeTree(QualifiedTypeTree.set<ModelF>(), {ModelF.variant0(), ModelF.variant1()}, deepEquality.equals);
  testTypeTree(QualifiedTypeTree.set<ModelG>(), {ModelG.variant0(), ModelG.variant1()}, deepEquality.equals);
  testTypeTree(QualifiedTypeTree.set<dynamic>(), {ModelA.variant0(), ModelA.variant1()}, deepEquality.equals);

  testTypeTree(QualifiedTypeTree.map<String, int>(), {"Hello": 12, "value": 35}, deepEquality.equals);
  testTypeTree(
      QualifiedTypeTreeN<Map<dynamic, List<dynamic>>, Map>([
        QualifiedTypeTree.terminal<dynamic>(),
        QualifiedTypeTree.list<dynamic>(),
      ]),
      {
        ModelA.variant0(): [ModelB.variant0()],
        ModelA.variant1(): [ModelB.variant1()],
      },
      deepEquality.equals);
  testTypeTree(
      QualifiedTypeTree.map<ModelA, ModelB>(),
      {
        ModelA.variant0(): ModelB.variant0(),
        ModelA.variant1(): ModelB.variant1(),
      },
      deepEquality.equals);
  testTypeTree(
      QualifiedTypeTree.map<ModelC, ModelD>(),
      {
        ModelC.variant0(): ModelD.variant0(),
        ModelC.variant1(): ModelD.variant1(),
      },
      deepEquality.equals);
  testTypeTree(
      QualifiedTypeTree.map<ModelE, ModelF>(),
      {
        ModelE.variant0(): ModelF.variant0(),
        ModelE.variant1(): ModelF.variant1(),
      },
      deepEquality.equals);
}

void testTypeTree(TypeTree tree, dynamic initialValue, bool Function(dynamic a, dynamic b) comparator) {
  var converter = dogs.getTreeConverter(tree);
  GraphSerializerMode graphMode = dogs.modeRegistry.graphSerialization.forConverter(converter, dogs);
  NativeSerializerMode nativeMode = dogs.modeRegistry.nativeSerialization.forConverter(converter, dogs);
  var resultGraph = graphMode.serialize(initialValue, dogs);
  var resultNative = nativeMode.serialize(initialValue, dogs);
  var reGraph = graphMode.deserialize(resultGraph, dogs);
  var reNative = nativeMode.deserialize(resultNative, dogs);
  expect(true, comparator(reGraph, initialValue), reason: "Graph result not equal: $reGraph != $initialValue");
  expect(true, comparator(reNative, initialValue), reason: "Native result not equal: $reNative != $initialValue");
}
