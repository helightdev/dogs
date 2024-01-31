import "package:collection/collection.dart";
import "package:dogs_core/dogs_core.dart";
import "package:test/test.dart";

void main() {
  test("from native coercion", () {
    final codec = DefaultNativeCodec();
    expect(DogString("string"), codec.fromNative("string"));
    expect(DogInt(1337), codec.fromNative(1337));
    expect(DogDouble(1337.0), codec.fromNative(1337.0));
    expect(DogBool(true), codec.fromNative(true));
    expect(DogNull(), codec.fromNative(null));
    expect(DogList([DogInt(1), DogInt(2)]).value,
        containsAll(codec.fromNative([1, 2]).asList!.value));
    expect(DogMap({DogString("a"): DogInt(1), DogString("b"): DogInt(2)}),
        codec.fromNative({"a": 1, "b": 2}));
  });

  test("to native coercion", () {
    expect("string", DogString("string").coerceNative());
    expect(1337, DogInt(1337).coerceNative());
    expect(1337.0, DogDouble(1337.0).coerceNative());
    expect(true, DogBool(true).coerceNative());
    expect(null, DogNull().coerceNative());
    expect(
        true,
        ListEquality()
            .equals([1, 2], DogList([DogInt(1), DogInt(2)]).coerceNative()));
    expect(
        true,
        MapEquality().equals(
            {"a": 1, "b": 2},
            DogMap({DogString("a"): DogInt(1), DogString("b"): DogInt(2)})
                .coerceNative()));
  });
}
