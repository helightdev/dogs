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
import "dart:developer";

import "package:dogs_core/dogs_core.dart";
import "package:meta/meta.dart";

part "trees/defaults.dart";
part "trees/iterables.dart";
part "trees/nargs.dart";

/// A factory for [DogConverter]s that are derived from a [TypeTree].
abstract class TreeBaseConverterFactory implements DogLinkable {
  /// The base type this factory handles. Must be set before linking.
  TypeCapture? baseType;

  @override
  void link(DogEngine engine, bool emitChanges) {
    if (baseType == null) {
      log("Cannot link TreeBaseConverterFactory without a baseType, please manually register the factory.");
      return;
    }
    engine.registerTreeBaseFactory(baseType!, this);
  }

  /// Resolves the converter for a [tree].
  /// [allowPolymorphic] defines if the returned converter may be a
  /// [PolymorphicConverter]. This property must be respected by the
  /// implementation of this method and should be passed on to child
  /// converters.
  DogConverter getConverter(TypeTree tree, DogEngine engine, bool allowPolymorphic);

  @internal

  /// Cached polymorphic converter.
  static final PolymorphicConverter polymorphicConverter = PolymorphicConverter();

  /// Returns the converter for a [tree].
  static DogConverter treeConverter(TypeTree tree, DogEngine engine, bool allowPolymorphic) {
    if (tree.isTerminal && tree.base.typeArgument == dynamic && !tree.isSynthetic) {
      return polymorphicConverter;
    }
    return engine.getTreeConverter(tree, allowPolymorphic);
  }

  /// Returns a list of converters for the type arguments of a [tree].
  /// If [allowPolymorphic] is true, the returned converters may be
  /// [PolymorphicConverter]s.
  ///
  /// This is a helper method for custom implementations of
  /// [TreeBaseConverterFactory].
  static List<DogConverter> argumentConverters(
      TypeTree tree, DogEngine engine, bool allowPolymorphic) {
    return tree.arguments.map((e) {
      return treeConverter(e, engine, allowPolymorphic);
    }).toList();
  }

  /// Creates a factory for a [BASE] type that is representable by an iterable.
  /// The [wrap] function is called with an iterable of the type argument and
  /// must return an instance of [BASE]. The [unwrap] function is the inverse
  /// of [wrap] and must transform a [BASE] instance into an iterable of the
  /// type argument.
  static TreeBaseConverterFactory createIterableFactory<BASE>({
    required BASE Function<T>(Iterable<T> entries) wrap,
    required Iterable Function<T>(BASE value) unwrap,
  }) =>
      _IterableTreeBaseConverterFactory<BASE>(wrap, unwrap);

  /// Creates a factory for a [BASE] type that has [nargs] type arguments.
  /// The [consume] function is called with the type arguments in order and must
  /// return an instance of `NTreeArgConverter<BASE>`.
  /// Example:
  /// ```dart
  /// TreeBaseConverterFactory.createNargsFactory<MyCollection>(
  ///   nargs: 3,
  ///   consume: <A,B,C>() => MyConverter<A,B,C>()
  /// )
  /// ```
  static TreeBaseConverterFactory createNargsFactory<BASE>({
    required int nargs,
    required Function consume,
  }) =>
      _NargsTreeBaseConverterFactory<BASE>(nargs, consume);
}
