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

import 'package:dogs_core/dogs_core.dart';
import 'package:flutter/widgets.dart';

/// Resolves translations for [DogForm]s.
/// Default implementations:
/// - [DefaultTranslationResolver] returns null for all keys
/// - [MapTranslationResolver] returns the value for the key from the map
/// - [MultiMapTranslationResolver] same as [MapTranslationResolver] but with
/// maps for different locales
abstract class TranslationResolver {
  const TranslationResolver();

  /// Returns the translation for the given [key] and [locale].
  String? translate(BuildContext context, String key, Locale? locale);

  /// Translates the messages in the given [AnnotationResult] using [translate].
  AnnotationResult translateAnnotation(
      BuildContext context, AnnotationResult result, Locale? locale) {
    var messages = result.messages
        .map(
            (e) => e.withMessage(translate(context, e.id, locale) ?? e.message))
        .toList();
    return AnnotationResult(messages: messages);
  }
}

/// Default implementation of [TranslationResolver] that returns null for all keys.
class DefaultTranslationResolver extends TranslationResolver {
  const DefaultTranslationResolver();

  @override
  String? translate(BuildContext context, String key, Locale? locale) {
    return null;
  }
}

/// Implementation of [TranslationResolver] that returns the associated
/// translation from a map.
class MapTranslationResolver extends TranslationResolver {
  final Map<String, String> translations;

  const MapTranslationResolver(this.translations);

  @override
  String? translate(BuildContext context, String key, Locale? locale) {
    return translations[key];
  }
}

/// Implementation of [TranslationResolver] that returns the associated translation
/// for the given [locale] from a locale-keyed map.
class MultiMapTranslationResolver extends TranslationResolver {
  /// The translations for different locales.
  ///
  ///
  /// Example:
  /// ```json
  /// {
  ///   "en": {
  ///     "key1": "value1",
  ///     "key2": "value2"
  ///    }
  /// }
  /// ```
  final Map<String, Map<String, String>> translations;

  const MultiMapTranslationResolver(this.translations);

  @override
  String? translate(BuildContext context, String key, Locale? locale) {
    if (locale == null) {
      return translations.values.first[key];
    }
    var localeTranslations = translations[locale.languageCode];
    if (localeTranslations == null) {
      return null;
    }
    return localeTranslations[key];
  }
}
