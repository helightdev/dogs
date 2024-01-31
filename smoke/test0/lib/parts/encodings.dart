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


void testCbor() {
  testEncoding(dogs.cborSerializer, ModelA.variant0, ModelA.variant1);
  testEncoding(dogs.cborSerializer, ModelA.variant1, ModelA.variant2);
  testEncoding(dogs.cborSerializer, ModelB.variant0, ModelB.variant1);
  testEncoding(dogs.cborSerializer, ModelC.variant0, ModelC.variant1);
  testEncoding(dogs.cborSerializer, ModelD.variant0, ModelD.variant1);
  testEncoding(dogs.cborSerializer, ModelE.variant0, ModelE.variant1);
  testEncoding(dogs.cborSerializer, ModelF.variant0, ModelF.variant1);
  testEncoding(dogs.cborSerializer, ModelG.variant0, ModelG.variant1);
  testEncoding(dogs.cborSerializer, Note.variant0, Note.variant1);
}

void testYaml() {
  var serializer = dogs.yamlSerializer;
  var decode = (v, t) => serializer.deserialize(v, t);
  var encode = (v, t) => serializer.serialize(v, t);
  testNewEncoding<ModelA>(encode, decode, ModelA.variant0, ModelA.variant1);
  testNewEncoding<ModelA>(encode, decode, ModelA.variant1, ModelA.variant2);
  testNewEncoding<ModelB>(encode, decode, ModelB.variant0, ModelB.variant1);
  testNewEncoding<ModelC>(encode, decode, ModelC.variant0, ModelC.variant1);
  testNewEncoding<ModelD>(encode, decode, ModelD.variant0, ModelD.variant1);
  testNewEncoding<ModelE>(encode, decode, ModelE.variant0, ModelE.variant1);
  testNewEncoding<ModelF>(encode, decode, ModelF.variant0, ModelF.variant1);
  // testNewEncoding<ModelG>(encode, decode, ModelG.variant0, ModelG.variant1);
  testNewEncoding<Note>(encode, decode, Note.variant0, Note.variant1);
}

void testToml() {
  testEncoding(dogs.tomlSerializer, ModelA.variant0, ModelA.variant1);
  testEncoding(dogs.tomlSerializer, ModelA.variant1, ModelA.variant2);
  testEncoding(dogs.tomlSerializer, ModelB.variant0, ModelB.variant1);
  testEncoding(dogs.tomlSerializer, ModelC.variant0, ModelC.variant1);
  testEncoding(dogs.tomlSerializer, ModelD.variant0, ModelD.variant1);
  testEncoding(dogs.tomlSerializer, ModelE.variant0, ModelE.variant1);
  testEncoding(dogs.tomlSerializer, ModelF.variant0, ModelF.variant1);
  // testEncoding(dogs.tomlSerializer, ModelG.variant0, ModelG.variant1);
  testEncoding(dogs.tomlSerializer, Note.variant0, Note.variant1);
}

void testEncoding<T>(DogSerializer serializer, T Function() a, T Function() b) {
  var va0 = a();
  var va1 = a();
  var vb0 = b();
  var vb1 = b();
  var ga = dogs.convertObjectToGraph(va0, T);
  var gb = dogs.convertObjectToGraph(vb0, T);
  var ea = serializer.serialize(ga);
  var eb = serializer.serialize(gb);
  var gda = serializer.deserialize(ea);
  var gdb = serializer.deserialize(eb);
  var da = dogs.convertObjectFromGraph(gda, T);
  var db = dogs.convertObjectFromGraph(gdb, T);
  expect(va1, da, reason: "Non-pure serialization");
  expect(va0, da, reason: "Non-pure serialization");
  expect(vb1, db, reason: "Non-pure serialization");
  expect(vb0, db, reason: "Non-pure serialization");
  expect(ea, isNot(eb), reason: "Wrong equality");
}

void testNewEncoding<T>(dynamic Function(dynamic, Type) encode, dynamic Function(dynamic, Type) decode, T Function() a, T Function() b) {
  var va0 = a();
  var va1 = a();
  var vb0 = b();
  var vb1 = b();
  var ea = encode(va0, T);
  var eb = encode(vb0, T);
  var da = decode(ea, T);
  var db = decode(eb, T);
  expect(va1, da, reason: "Non-pure serialization");
  expect(va0, da, reason: "Non-pure serialization");
  expect(vb1, db, reason: "Non-pure serialization");
  expect(vb0, db, reason: "Non-pure serialization");
  expect(ea, isNot(eb), reason: "Wrong equality");
}