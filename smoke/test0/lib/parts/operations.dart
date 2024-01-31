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

void testOperations() {
  testOperation(ModelA, ModelA.variant0(), deepEquality.equals);
  testOperation(ModelA, ModelA.variant1(), deepEquality.equals);
  testOperation(ModelA, ModelA.variant2(), deepEquality.equals);
  testOperation(ModelB, ModelB.variant0(), deepEquality.equals);
  testOperation(ModelB, ModelB.variant1(), deepEquality.equals);
  testOperation(ModelC, ModelC.variant0(), deepEquality.equals);
  testOperation(ModelC, ModelC.variant1(), deepEquality.equals);
  testOperation(ModelD, ModelD.variant0(), deepEquality.equals);
  testOperation(ModelD, ModelD.variant1(), deepEquality.equals);
  testOperation(ModelE, ModelE.variant0(), deepEquality.equals);
  testOperation(ModelE, ModelE.variant1(), deepEquality.equals);
  testOperation(ModelF, ModelF.variant0(), deepEquality.equals);
  testOperation(ModelF, ModelF.variant1(), deepEquality.equals);
  testOperation(ModelG, ModelG.variant0(), deepEquality.equals);
  testOperation(ModelG, ModelG.variant1(), deepEquality.equals);
}

void testOperation(Type type, dynamic initialValue, bool Function(dynamic a, dynamic b) comparator) {
  var nativeOperation = dogs.modeRegistry.nativeSerialization.forType(type, dogs);
  var graphOperation = dogs.modeRegistry.graphSerialization.forType(type, dogs);
  var resultGraph = graphOperation.serialize(initialValue, dogs);
  var resultNative = nativeOperation.serialize(initialValue, dogs);
  var reGraph = graphOperation.deserialize(resultGraph, dogs);
  var reNative = nativeOperation.deserialize(resultNative, dogs);
  expect(true, comparator(reGraph, initialValue), reason: "Graph result not equal: $reGraph != $initialValue");
  expect(true, comparator(reNative, initialValue), reason: "Native result not equal: $reNative != $initialValue");
}