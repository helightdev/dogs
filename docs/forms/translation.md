To add a simple translations, just use the built-in MultiMapTranslationResolver or MapTranslationResolver.
This also allows you to hook any arbitrary translation library into the form by hardcoding
the bindings into the translation resolver, if you don't have too many translation keys.

```dart
DogsForm<Person>(
  reference: formRef,
  translationResolver: const MultiMapTranslationResolver({
    "de": {
      "happy": "Wie glücklich bist du?",
      "number-minimum": "Muss größer als %min% sein (%minExclusive%)."
    },
    "en": {
      "happy": "How happy you are?",
    }
  })
)
```

In case you have a lot of translation keys, you can also use the [intl](https://pub.dev/packages/intl)
package. To use translations from the intl package, you simply implement a binding TranslationResolver
class that loads your translations. Since it is a bit tricky adding and testing the intl package
in a library, this is left to you.