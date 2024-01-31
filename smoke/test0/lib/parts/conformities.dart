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

void testConformities() {
  testSimple(ConformityBasic.variant0, ConformityBasic.variant1);
  testSimple(ConformityData.variant0, ConformityData.variant1);
  testSimple(ConformityDataArg.variant0, ConformityDataArg.variant1);
  testSimple(ConformityBean.variant0, ConformityBean.variant1);
}

void testSimple<T>(T Function() a, T Function() b) {
  var va0 = a();
  var vb0 = b();
  var ea = dogs.toJson<T>(va0);
  var eb = dogs.toJson<T>(vb0);
  var da = dogs.fromJson<T>(ea);
  var db = dogs.fromJson<T>(eb);
  var rea = dogs.toJson<T>(da);
  var reb = dogs.toJson<T>(db);
  expect(ea, rea);
  expect(eb, reb);
}