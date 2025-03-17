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
  testSingleModel<DefaultValueModel>(DefaultValueModel.variant0, DefaultValueModel.variant1);
  
  test("Default Values", () {
    var defaultValues = DefaultValueModel.variant0();
    var defaultMap = dogs.toNative(defaultValues) as Map;
    expect(defaultMap.containsKey("a"), false);
    expect(defaultMap.containsKey("b"), false);

    var customValues = DefaultValueModel.variant1();
    var customMap = dogs.toNative(customValues) as Map;
    expect(customMap.containsKey("a"), true);
    expect(customMap.containsKey("b"), true);
  });
}

void testSingleModel<T>(T Function() a, T Function() b) => group("$T", () {

  SchemaPass.run((pass) {
    print(dogs.findAssociatedConverter(T)!.describeOutput(dogs, SchemaConfig()).toJson());
  });

  var va0 = a();
  var va1 = a();
  var vb0 = b();
  var vb1 = b();

  test("Base", () {
    var ea = dogs.toJson<T>(va0);
    var eb = dogs.toJson<T>(vb0);
    var da = dogs.fromJson<T>(ea);
    var db = dogs.fromJson<T>(eb);
    expect(va1, da, reason: "Non-pure serialization");
    expect(va0, da, reason: "Non-pure serialization");
    expect(vb1, db, reason: "Non-pure serialization");
    expect(vb0, db, reason: "Non-pure serialization");
    expect(ea, isNot(eb), reason: "Wrong equality");
  });

  // Test Iterable kind based serialization
  group("Kind", () {
    test("List", () => _testListKind<T>(va0, va1, vb0, vb1));
    test("Set", () => _testSetKind<T>(va0, va1, vb0, vb1));
  });

  group("Type Tree", () {
    test("Map", () => _testMap<T>(va0, va1));
    test("Optional A", () => _testOptional<T>(va0));
    test("Optional B", () => _testOptional<T>(va1));
  });
});

void _testListKind<T>(T va0, T va1, T vb0, T vb1) {
  var list = [va0, va1, vb0, vb1];
  var encodedList = dogs.toJson(list,
      type: T, kind: IterableKind.list
  );
  var decodedList = dogs.fromJson(encodedList,
      type: T, kind: IterableKind.list
  );
  expect(decodedList, orderedEquals(list));
}

void _testSetKind<T>(T va0, T va1, T vb0, T vb1) {
  var list = {va0, va1, vb0, vb1};
  expect(list, hasLength(2));
  var encodedList = dogs.toJson(list,
      type: T, kind: IterableKind.set
  );
  var decodedList = dogs.fromJson(encodedList,
      type: T, kind: IterableKind.set
  );
  expect(decodedList, orderedEquals(list));
}

void _testMap<T>(T va0, T va1) {
  var map = {
    "a": va0,
    "b": va1,
  };
  var tree = QualifiedTypeTree.map<String, T>();
  var encodedMap = dogs.toJson(map, tree: tree);
  var decodedMap = dogs.fromJson<Map<String, T>>(encodedMap, tree: tree);
  expect(decodedMap, deepEquals(map));
}

void _testOptional<T>(T val) {
  var va0 = val;
  var va1 = null;
  var tree = QualifiedTypeTree.arg1<Optional<T>, Optional, T>();
  var ea = dogs.toJson(Optional(va0), tree: tree);
  var eb = dogs.toJson(Optional(va1), tree: tree);
  var da = dogs.fromJson<Optional<T>>(ea, tree: tree);
  var db = dogs.fromJson<Optional<T>>(eb, tree: tree);
  expect(va0, da.value, reason: "Non-pure serialization");
  expect(va1, db.value, reason: "Non-pure serialization");
}