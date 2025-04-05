import 'package:dogs_core/dogs_core.dart';
import 'package:flutter/material.dart';

mixin AutoThemeMixin<SELF> implements Mergeable<SELF> {

  DogStructure get _structure {
    final structure = DogEngine.instance.findStructureByType(SELF);
    if (structure == null) {
      throw Exception("No structure found for type $SELF");
    }
    return structure;
  }

  @override
  SELF merge(SELF? other) {
    if (other == null) return this as SELF;
    final structure = _structure;
    final proxy = structure.proxy;
    final selfValues = proxy.getFieldValues(this);
    final otherValues = proxy.getFieldValues(other);
    final values = List.generate(selfValues.length, (i) {
      final selfValue = selfValues[i];
      final otherValue = otherValues[i];
      final field = structure.fields[i];

      if (selfValue == null || otherValue == null) {
        return selfValue ?? otherValue;
      }
      if (selfValue.runtimeType == otherValue.runtimeType) {
        if (selfValue is Mergeable) {
          return selfValue.merge(otherValue);
        }

        final mergeableFunction = field.firstAnnotationOf<MergeFunction>();
        if (mergeableFunction != null) {
          return mergeableFunction.mergeFunction(selfValue, otherValue);
        }

        return selfValue;
      }
      return selfValue;
    });
    return proxy.instantiate(values) as SELF;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final structure = _structure;
    final a = structure.proxy.getFieldValues(this);
    final b = structure.proxy.getFieldValues(other);
    return deepEquality.equals(a, b);
  }

  @override
  int get hashCode {
    final structure = _structure;
    final proxy = structure.proxy;
    final values = proxy.getFieldValues(this);
    return deepEquality.hash(values);
  }
}

abstract class Mergeable<T> {
  T merge(T? other);
}

class MergeFunction implements StructureMetadata {
  final dynamic Function(dynamic a, dynamic b) mergeFunction;
  const MergeFunction(this.mergeFunction);
}
