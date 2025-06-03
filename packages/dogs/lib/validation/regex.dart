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

import "package:dogs_core/dogs_core.dart";
import "package:dogs_core/validation/utils.dart";
import "package:meta/meta.dart";

/// Reduced version of a RFC 5322 email regex from https://www.regular-expressions.info/email.html
/// This regex omits IP addresses, double quotes and square brackets.
const email = Regex(
    "[a-z0-9!#\$%&'*+/=?^_‘{|}~-]+(?:\\.[a-z0-9!#\$%&'*+/=?^_‘{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?",
    messageId: "invalid-email",
    message: "Invalid email address.");

/// A [FieldValidator] that validates a [String] using a [RegExp].
class Regex extends FieldValidator<RegexCacheEntry>
    implements SchemaFieldVisitor, StructureMetadata {
  /// The regex pattern.
  final String pattern;

  /// The message id used for the annotation result.
  final String? messageId;

  /// The message used for the annotation result.
  final String? message;

  /// Validates a [String] using a [RegExp].
  const Regex(this.pattern, {this.messageId, this.message});

  /// The default message id used for the annotation result.
  static const String defaultMessageId = "regex";

  @override
  RegexCacheEntry getCachedValue(DogStructureField field) {
    return RegexCacheEntry(
        RegExp(pattern), field.iterableKind != IterableKind.none);
  }

  @override
  void verifyUsage(DogStructureField field) {
    if (field.serial.typeArgument != String) throw DogException("Field '${field.name}' must be a String/-List/-Iterable to use @Regex().");
  }

  @override
  bool validate(RegexCacheEntry cached, value, DogEngine engine) {
    if (cached.isIterable) {
      if (value == null) return true;
      return (value as Iterable)
          .every((e) => _validateSingle(cached.matcher, e));
    } else {
      return _validateSingle(cached.matcher, value);
    }
  }

  bool _validateSingle(RegExp matcher, dynamic value) {
    if (value == null) return true;
    final str = value as String;
    final firstMatch = matcher.firstMatch(str);
    // Check for any match
    if (firstMatch == null) return false;
    // Return if first match is right and don't check for other matches
    if (firstMatch.start == 0 && firstMatch.end == str.length) return true;
    // Check all matches for a full match.
    return matcher
        .allMatches(str)
        .any((element) => element.start == 0 && element.end == str.length);
  }

  @override
  void visitSchemaField(SchemaField object) {
    final target = itemSchemaTarget(object);
    target[SchemaProperties.pattern] = pattern;
  }

  @override
  AnnotationResult annotate(RegexCacheEntry cached, value, DogEngine engine) {
    final isValid = validate(cached, value, engine);
    if (isValid) return AnnotationResult.empty();
    return AnnotationResult(messages: [
      AnnotationMessage(
          id: messageId ?? defaultMessageId,
          message: message ?? "Invalid format")
    ]);
  }
}

class RegexCacheEntry {
  RegExp matcher;
  bool isIterable;

  RegexCacheEntry(this.matcher, this.isIterable);
}
