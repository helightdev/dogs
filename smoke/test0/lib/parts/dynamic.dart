part of "../test.dart";

void testDynamic() {
  testDynamicSerialization("Simple Model", ModelA.variant0());
  testDynamicSerialization("Simple List", [ModelA.variant0(), ModelB.variant1()]);
  testDynamicSerialization("Simpel Map", {
    "a": ModelA.variant0(),
    "b": ModelB.variant1(),
  });
  testDynamicSerialization("Null", null);
  testDynamicSerialization("String", "hello");
  testDynamicSerialization("Int", 42);
  testDynamicSerialization("Double", 3.14);
  testDynamicSerialization("Bool", true);
  testDynamicSerialization("Primitive List", [1, 2, 3, 4, 5]);
  testDynamicSerialization("Primitive Map", {
    "a": 1,
    "b": 2,
    "c": 3,
  });
}

void testDynamicSerialization(String name, dynamic input) {
  test(name, () {
    final encoded = dogs.toNative(input);
    final decoded = dogs.fromNative(encoded);
    final reencoded = dogs.toNative(decoded);
    expect(reencoded, deepEquals(encoded));
    expect(input.toString(), decoded.toString());
  });
}