import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_flutter/databinding/validation.dart';
import 'package:dogs_flutter/structure/theme.dart';
import 'package:flutter/material.dart';

@Structure()
class BindingStyle
    with AutoThemeMixin<BindingStyle>
    implements StructureMetadata, BindingStyleModifier {
  final String? label;
  final String? hint;
  final String? helper;
  final Widget? prefix;
  final Widget? suffix;

  @MergeFunction(mergeExtensions)
  final List<BindingStyleExtension> extensions;

  const BindingStyle({
    this.label,
    this.hint,
    this.helper,
    this.prefix,
    this.suffix,
    this.extensions = const [],
  });

  T? getExtension<T extends BindingStyleExtension>() {
    return extensions.firstWhereOrNullDogs((e) => e is T) as T?;
  }

  static List<BindingStyleExtension> mergeExtensions(dynamic a, dynamic b) {
    final merged = List<BindingStyleExtension>.from(
      a as List<BindingStyleExtension>,
    );
    for (var extension in (b as List<BindingStyleExtension>)) {
      final index = merged.indexWhere(
        (e) => e.runtimeType == extension.runtimeType,
      );
      if (index == -1) {
        merged.add(extension);
      } else {
        merged[index] = (extension as Mergeable).merge(
          merged[index] as Mergeable,
        );
      }
    }
    return merged;
  }

  @override
  BindingStyle createStyleOverrides() => this;
}

abstract class BindingStyleModifier {
  const BindingStyleModifier();

  BindingStyle createStyleOverrides();
}

abstract class BindingStyleExtension<SELF> implements Mergeable<SELF> {
  const BindingStyleExtension();
}