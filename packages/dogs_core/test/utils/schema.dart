import "package:collection/collection.dart";
import "package:dogs_core/dogs_core.dart";
import "package:test/test.dart";

class ReserializationMatcher extends Matcher {
  ReserializationMatcher();

  @override
  bool matches(item, Map matchState) {
    if (item is! SchemaType) return false;
    final properties = item.toProperties();
    final parsed = SchemaType.fromProperties(properties);
    return DeepCollectionEquality.unordered().equals(properties, parsed.toProperties());
  }

  @override
  Description describe(Description description) {
    return description.add("Correct Reserialization");
  }

  @override
  Description describeMismatch(
      dynamic item, Description mismatchDescription, Map matchState, bool verbose) {
    if (item is! SchemaType) return mismatchDescription.add("Not a SchemaType");
    final properties = item.toProperties();
    final parsed = SchemaType.fromProperties(properties);
    return mismatchDescription.add("Reserialized: ${parsed.toJson()}, Original: ${item.toJson()}");
  }
}

ReserializationMatcher doesReserialize = ReserializationMatcher();

class UnorderedEqualityMatcher extends Matcher {
  final dynamic expected;

  UnorderedEqualityMatcher(this.expected);

  @override
  bool matches(item, Map matchState) {
    return DeepCollectionEquality.unordered().equals(item, expected);
  }

  @override
  Description describe(Description description) {
    return description.add("Unordered equals $expected");
  }

  @override
  Description describeMismatch(
      dynamic item, Description mismatchDescription, Map matchState, bool verbose) {
    return mismatchDescription.add("Unordered: $item, Expected: $expected");
  }
}

UnorderedEqualityMatcher unorderedDeepEquals(dynamic expected) =>
    UnorderedEqualityMatcher(expected);
