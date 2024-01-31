import "package:dogs_core/dogs_core.dart";
import "package:test/test.dart";

void main() {
  test("basic rebuild", () async {
    final original = DogEngine(registerBaseConverters: false);
    final forked = original.fork();
    expect(original.findAssociatedConverter(DateTime), null);
    expect(forked.findAssociatedConverter(DateTime), null);
    expect(original.findConverter(DateTimeConverter), null);
    expect(forked.findConverter(DateTimeConverter), null);
    original.registerAutomatic(DateTimeConverter());
    expect(original.findAssociatedConverter(DateTime), isNotNull);
    expect(forked.findAssociatedConverter(DateTime), isNotNull);
    expect(original.findConverter(DateTimeConverter), isNotNull);
    expect(forked.findConverter(DateTimeConverter), isNotNull);
  });
}
