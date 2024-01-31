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

void testModels() {
  testSingleModel<ModelA>(ModelA.variant0, ModelA.variant1);
  testSingleModel<ModelB>(ModelB.variant0, ModelB.variant1);
  testSingleModel<ModelC>(ModelC.variant0, ModelC.variant1);
  testSingleModel<ModelD>(ModelD.variant0, ModelD.variant1);
  testSingleModel<ModelE>(ModelE.variant0, ModelE.variant1);
  testSingleModel<ModelF>(ModelF.variant0, ModelF.variant1);
  testSingleModel<ModelG>(ModelG.variant0, ModelG.variant1);
  testSingleModel<Note>(Note.variant0, Note.variant1);
  testSingleModel<DeepPolymorphic>(DeepPolymorphic.variant0, DeepPolymorphic.variant1);
  testSingleModel<CustomBaseImpl>(CustomBaseImpl.variant0, CustomBaseImpl.variant1);
  testSingleModel<InitializersModel>(InitializersModel.variant0, InitializersModel.variant1);
  testSingleModel<ConstructorBodyModel>(ConstructorBodyModel.variant0, ConstructorBodyModel.variant1);
  testSingleModel<GetterModel>(GetterModel.variant0, GetterModel.variant1);
}

void testSingleModel<T>(T Function() a, T Function() b) {
  var va0 = a();
  var va1 = a();
  var vb0 = b();
  var vb1 = b();
  var ea = dogs.toJson<T>(va0);
  var eb = dogs.toJson<T>(vb0);
  var da = dogs.fromJson<T>(ea);
  var db = dogs.fromJson<T>(eb);
  expect(va1, da, reason: "Non-pure serialization");
  expect(va0, da, reason: "Non-pure serialization");
  expect(vb1, db, reason: "Non-pure serialization");
  expect(vb0, db, reason: "Non-pure serialization");
  expect(ea, isNot(eb), reason: "Wrong equality");
}
