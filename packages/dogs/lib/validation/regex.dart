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

import 'package:conduit_open_api/v3.dart';
import 'package:dogs_core/dogs_core.dart';

/// Reduced version of a RFC 5322 email regex from https://www.regular-expressions.info/email.html
/// This regex omits IP addresses, double quotes and square brackets.
const email = Regex(
    "[a-z0-9!#\$%&'*+/=?^_‘{|}~-]+(?:\\.[a-z0-9!#\$%&'*+/=?^_‘{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");

class Regex extends StructureMetadata
    implements APISchemaObjectMetaVisitor, FieldValidator {
  final String pattern;

  const Regex(this.pattern);

  @override
  getCachedValue(DogStructure<dynamic> structure, DogStructureField field) {
    return _RegexCacheEntry(
        RegExp(pattern), field.iterableKind != IterableKind.none);
  }

  @override
  bool isApplicable(DogStructure structure, DogStructureField field) {
    return field.serial.typeArgument == String;
  }

  @override
  bool validate(cached, value, DogEngine engine) {
    var entry = cached as _RegexCacheEntry;
    if (entry.isIterable) {
      if (value == null) return true;
      return (value as Iterable).every((e) => validateSingle(entry.matcher, e));
    } else {
      return validateSingle(entry.matcher, value);
    }
  }

  bool validateSingle(RegExp matcher, dynamic value) {
    if (value == null) return true;
    var str = value as String;
    var firstMatch = matcher.firstMatch(str);
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
  void visit(APISchemaObject object) {
    object.pattern = pattern;
  }
}

class _RegexCacheEntry {
  RegExp matcher;
  bool isIterable;

  _RegexCacheEntry(this.matcher, this.isIterable);
}
