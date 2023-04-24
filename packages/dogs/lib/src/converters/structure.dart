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

import 'package:collection/collection.dart';
import 'package:conduit_open_api/v3.dart';
import 'package:dogs_core/dogs_core.dart';

abstract class ConverterSupplyingVisitor extends StructureMetadata {
  const ConverterSupplyingVisitor();

  bool get ephemeral => false;
  DogConverter resolve(DogStructure structure, DogStructureField field, DogEngine engine);
}

abstract class DefaultStructureConverter<T> extends DogConverter<T>
    with StructureEmitter<T>
    implements Copyable<T>, Validatable<T> {
  @override
  DogStructure<T> get structure;

  bool _hasValidation = false;
  late Map<ClassValidator, dynamic> _cachedClassValidators;
  late Map<int, List<MapEntry<FieldValidator, dynamic>>> _cachedFieldValidators;
  
  bool _hasCachedConverters = false;
  late List<DogConverter?> _cachedConverters;

  DefaultStructureConverter() {
    // Create and cache validators eagerly
    _cachedClassValidators =
        Map.fromEntries(structure.annotationsOf<ClassValidator>().where((e) {
      var applicable = e.isApplicable(structure);
      if (applicable) {
        _hasValidation = true;
      } else {
        print("$e is not applicable in $structure");
      }
      return applicable;
    }).map((e) => MapEntry(e, e.getCachedValue(structure))));

    _cachedFieldValidators =
        Map.fromEntries(structure.fields.mapIndexed((index, field) {
      var validators = field
          .annotationsOf<FieldValidator>()
          .where((e) {
            var applicable = e.isApplicable(structure, field);
            if (applicable) {
              _hasValidation = true;
            } else {
              print("$e is not applicable for $field in $structure");
            }
            return applicable;
          })
          .map((e) => MapEntry(e, e.getCachedValue(structure, field)))
          .toList();
      return MapEntry(index, validators);
    }));
  }
  
  void initConverters(DogEngine engine) {
    _cachedConverters = List.filled(structure.fields.length, null);
    structure.fields.mapIndexed((index, element) {
      _cachedConverters[index] = getConverter(engine, element, true);
    });
    _hasCachedConverters = true;
  }

  DogConverter? getConverter(DogEngine engine, DogStructureField field, bool cachePhase) {
    final supplier = field.firstAnnotationOf<ConverterSupplyingVisitor>();
    if (supplier != null) {
      if (supplier.ephemeral && cachePhase) return null;
      return supplier.resolve(structure, field, engine);
    }

    if (field.converterType != null) {
      return engine.findConverter(field.converterType!);
    }

    if (field.structure) {
      var directConverter = engine.findAssociatedConverter(field.type);
      if (directConverter != null) return directConverter;

      // Return serial converter
      return engine.findAssociatedConverter(field.serial.typeArgument);
    }

    return null; // Primitives
  }
  
  @override
  APISchemaObject get output {
    if (structure.isSynthetic) return APISchemaObject.empty();
    return APISchemaObject()
      ..referenceURI = Uri(path: "/components/schemas/${structure.serialName}");
  }

  @override
  T convertFromGraph(DogGraphValue value, DogEngine engine) {
    if (!_hasCachedConverters) {
      initConverters(engine);
    }
    if (value is! DogMap) {
      throw Exception(
          "Expected a DogMap for structure ${structure.typeArgument} but go ${value.runtimeType}");
    }
    var map = value.value;
    var values = [];
    for (int i = 0; i < _cachedConverters.length; i++) {
      var field = structure.fields[i];
      var fieldValue = map[DogString(field.name)] ?? DogNull();

      if (fieldValue is DogNull) {
        if (field.optional) {
          values.add(null);
          continue;
        }
        throw Exception("Expected a value of serial type ${field.serial.typeArgument} at ${field.name} but got ${fieldValue.coerceString()}");
      }

      var converter = _cachedConverters[i];
      if (converter == null && field.structure) {
        converter = getConverter(engine, field, false);
      }

      if (converter == null) {
        values.add(adjustIterable(fieldValue.coerceNative(), field.iterableKind));
      } else {
        if (converter.keepIterables) {
          values.add(converter.convertFromGraph(fieldValue, engine));
        } else {
          values.add(converter.convertIterableFromGraph(fieldValue, engine, field.iterableKind));
        }
      }
    }
    return structure.proxy.instantiate(values);
  }

  @override
  DogGraphValue convertToGraph(T value, DogEngine engine) {
    if (!_hasCachedConverters) {
      initConverters(engine);
    }
    var map = <DogGraphValue, DogGraphValue>{};
    var values = structure.getters.map((e) => e(value)).toList();
    for (int i = 0; i < _cachedConverters.length; i++) {
      var field = structure.fields[i];
      var fieldValue = values.removeAt(0);
      var converter = _cachedConverters[i];
      if (converter == null && field.structure) {
        converter = getConverter(engine, field, false);
      }
      if (converter == null) {
        map[DogString(field.name)] = DogGraphValue.fromNative(fieldValue);
      } else {
        if (fieldValue == null) {
          if (!field.optional) throw Exception("Expected a value of type ${field.type} but got null");
          map[DogString(field.name)] = DogNull();
        }
        if (converter.keepIterables) {
          map[DogString(field.name)] = converter.convertToGraph(fieldValue, engine);
        } else {
          map[DogString(field.name)] = converter.convertIterableToGraph(fieldValue, engine, field.iterableKind);
        }
      }
    }
    return DogMap(map);
  }

  @override
  bool validate(T value, DogEngine engine) {
    if (!_hasValidation) return true;
    return !_cachedFieldValidators.entries.any((pair) {
          var fieldValue = structure.proxy.getField(value, pair.key);
          return pair.value
              .any((e) => !e.key.validate(e.value, fieldValue, engine));
        }) &&
        !_cachedClassValidators.entries
            .any((e) => !e.key.validate(e.value, value, engine));
  }

  @override
  T copy(T src, DogEngine engine, Map<String, dynamic>? overrides) {
    if (overrides == null) {
      return structure.proxy
          .instantiate(structure.getters.map((e) => e(src)).toList());
    } else {
      var map = overrides.map(
          (key, value) => MapEntry(structure.indexOfFieldName(key)!, value));
      var values = [];
      for (var i = 0; i < structure.fields.length; i++) {
        if (map.containsKey(i)) {
          values.add(map[i]);
        } else {
          values.add(structure.proxy.getField(src, i));
        }
      }
      return structure.proxy.instantiate(values);
    }
  }
}

class DogStructureConverterImpl<T> extends DefaultStructureConverter<T> {
  @override
  final DogStructure<T> structure;

  DogStructureConverterImpl(this.structure);
}
