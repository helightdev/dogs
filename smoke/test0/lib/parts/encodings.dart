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

typedef FromFunc<T> = T Function<T>(String encoded,
    {IterableKind kind, Type? type, TypeTree? tree});
typedef ToFunc<T> = String Function<T>(T decoded,
    {IterableKind kind, Type? type, TypeTree? tree});

void testToFrom<T>(T value, FromFunc<T> from, ToFunc<T> to) {
  // Explicit type argument
  var a1 = to<T>(value);
  var b1 = from<T>(a1);
  expect(b1, value);

  // Explicit type
  var a2 = to(value, type: T);
  var b2 = from(a2, type: T);
  expect(b2, value);

  // Explicit tree
  var tree = QualifiedTypeTree.terminal<T>();
  var a3 = to(value, tree: tree);
  var b3 = from(a3, tree: tree);
  expect(b3, value);

  // Explicit kind
  var a4 = to([value], type: T, kind: IterableKind.list);
  var b4 = from<List<T>>(a4, type: T, kind: IterableKind.list);
  expect(b4, deepEquals([value]));

  // Nullable base type
  var a5 = to<T?>(value, type: T);
  var b5 = from<T?>(a5, type: T);
  expect(b5, value);
  var a6 = to<T?>(null, type: T);
  var b6 = from<T?>(a6, type: T);
  expect(b6, null);

  // Nullable dynamic
  var a7 = to(null, type: T);
  var b7 = from(a7, type: T);
  expect(b7, null);

  // Nullable Tree
  var a8 = to<T?>(null, tree: tree);
  var b8 = from<T?>(a8, tree: tree);
  expect(b8, null);
}

void testEncoding(FromFunc from, ToFunc to) {
  testToFrom<ModelA>(ModelA.variant0(), from, to);
  testToFrom<ModelA>(ModelA.variant1(), from, to);
  testToFrom<ModelA>(ModelA.variant2(), from, to);
  testToFrom<ModelB>(ModelB.variant0(), from, to);
  testToFrom<ModelB>(ModelB.variant1(), from, to);
  testToFrom<ModelC>(ModelC.variant0(), from, to);
  testToFrom<ModelC>(ModelC.variant1(), from, to);
  testToFrom<ModelD>(ModelD.variant0(), from, to);
  testToFrom<ModelD>(ModelD.variant1(), from, to);
  testToFrom<ModelE>(ModelE.variant0(), from, to);
  testToFrom<ModelE>(ModelE.variant1(), from, to);
  testToFrom<ModelF>(ModelF.variant0(), from, to);
  testToFrom<ModelF>(ModelF.variant1(), from, to);
  testToFrom<ModelG>(ModelG.variant0(), from, to);
  testToFrom<ModelG>(ModelG.variant1(), from, to);
  testToFrom<Note>(Note.variant0(), from, to);
  testToFrom<Note>(Note.variant1(), from, to);
  testToFrom<DeepPolymorphic>(DeepPolymorphic.variant0(), from, to);
  testToFrom<DeepPolymorphic>(DeepPolymorphic.variant1(), from, to);
}