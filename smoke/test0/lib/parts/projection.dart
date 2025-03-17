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

void testProjection() {
  var result = dogs.project<Note>(Note.variant0(), {
    "tags": {"new"},
  }, [
    {"content": "AABBCC"}
  ]);
  if (result.title != Note.variant0().title)
    throw Exception("Object to FieldMap doesn't work");
  if (result.tags.first != "new") throw Exception("Properties don't work");
  if (result.content != "AABBCC") throw Exception("Iterables don't work");
  testProjectionOperation(ModelA.variant0);
  testProjectionOperation(ModelB.variant0);
  testProjectionOperation(ModelC.variant0);
  testProjectionOperation(ModelD.variant0);
  testProjectionOperation(ModelE.variant0);
  testProjectionOperation(ModelF.variant0);
  testProjectionOperation(ModelG.variant0);
  testProjectionOperation(Note.variant0);

  testComplexOverride();
}

void testComplexOverride() {
  var a = ModelA.variant0();

  var projection = Projection<ModelA>()
      .merge(a)
      .set("complex", Note.variant1())
      .perform();
  expect(projection.string, a.string);
  expect(projection.complex, Note.variant1());
}

void testProjectionOperation<T extends Object>(T Function() a) {
  var value = a();
  var projected = Projection<T>().merge(value).perform();
  expect(value, deepEquals(projected), reason: "Projection invalid");
}
