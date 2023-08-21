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
import 'package:dogs_core/src/opmodes/operation.dart';
import 'package:dogs_core/src/opmodes/structure/native.dart';

import '../opmodes/structure/graph.dart';

abstract class DefaultStructureConverter<T> extends DogConverter<T>
    implements Copyable<T>, Validatable<T> {
  
  bool _hasValidation = false;
  late Map<ClassValidator, dynamic> _cachedClassValidators;
  late Map<int, List<MapEntry<FieldValidator, dynamic>>> _cachedFieldValidators;

  bool _hasCachedConverters = false;
  late List<DogConverter?> _cachedConverters;
  Map<String, dynamic> cache = {};
  
  final DogStructure<T> _struct;

  DefaultStructureConverter({required DogStructure<T> s}) : _struct = s, super(struct: s);

  @override
  DogConverter<T> fork(DogEngine forkEngine) {
    return DogStructureConverterImpl<T>(_struct);
  }

  @override
  OperationMode<T>? resolveOperationMode(Type opmodeType) {
    if (opmodeType == NativeSerializerMode) return StructureNativeSerialization(_struct);
    if (opmodeType == GraphSerializerMode) return StructureGraphSerialization(_struct);
    return null;
  }

  @override
  void registrationCallback(DogEngine engine) {
    // Create and cache validators eagerly
    _cachedClassValidators =
        Map.fromEntries(_struct.annotationsOf<ClassValidator>().where((e) {
      var applicable = e.isApplicable(_struct);
      if (applicable) {
        _hasValidation = true;
      } else {
        print("$e is not applicable in $struct");
      }
      return applicable;
    }).map((e) => MapEntry(e, e.getCachedValue(_struct))));

    _cachedFieldValidators =
        Map.fromEntries(_struct.fields.mapIndexed((index, field) {
      var validators = field
          .annotationsOf<FieldValidator>()
          .where((e) {
            var applicable = e.isApplicable(_struct, field);
            if (applicable) {
              _hasValidation = true;
            } else {
              print("$e is not applicable for $field in $struct");
            }
            return applicable;
          })
          .map((e) => MapEntry(e, e.getCachedValue(_struct, field)))
          .toList();
      return MapEntry(index, validators);
    }));

    // Run annotation callbacks
    _struct.annotationsOf<RegistrationHook>().forEach((e) {
      e.onRegistration(engine, this);
    });
    _struct.fields
        .expand((e) => e.annotationsOf<RegistrationHook>())
        .forEach((e) {
      e.onRegistration(engine, this);
    });
  }

  void initConverters(DogEngine engine) {
    _cachedConverters = List.filled(_struct.fields.length, null);
    for (var i = 0; i < _struct.fields.length; i++) {
      var element = _struct.fields[i];
      _cachedConverters[i] = getConverter(engine, element, true);
    }
    _hasCachedConverters = true;
  }

  DogConverter? getConverter(
      DogEngine engine, DogStructureField field, bool cachePhase) {
    final supplier = field.firstAnnotationOf<ConverterSupplyingVisitor>();
    if (supplier != null) {
      return supplier.resolve(_struct, field, engine);
    }

    if (field.converterType != null) {
      return engine.findConverter(field.converterType!);
    }

    if (engine.codec.isNative(field.serial.typeArgument)) {
      return null;
    }

    var directConverter = engine.findAssociatedConverter(field.type.qualified.typeArgument);
    if (directConverter != null) return directConverter;

    // Return serial converter
    return engine.findAssociatedConverter(field.serial.typeArgument);
  }

  @override
  APISchemaObject get output {
    if (_struct.isSynthetic) return APISchemaObject.empty();
    return APISchemaObject()
      ..referenceURI = Uri(path: "/components/schemas/${_struct.serialName}");
  }

  @override
  bool validate(T value, DogEngine engine) {
    if (!_hasValidation) return true;
    return !_cachedFieldValidators.entries.any((pair) {
          var fieldValue = _struct.proxy.getField(value, pair.key);
          return pair.value
              .any((e) => !e.key.validate(e.value, fieldValue, engine));
        }) &&
        !_cachedClassValidators.entries
            .any((e) => !e.key.validate(e.value, value, engine));
  }

  @override
  T copy(T src, DogEngine engine, Map<String, dynamic>? overrides) {
    if (overrides == null) {
      return _struct.proxy.instantiate(_struct.proxy.getFieldValues(src));
    } else {
      var map = overrides.map(
          (key, value) => MapEntry(_struct.indexOfFieldName(key)!, value));
      var values = [];
      for (var i = 0; i < _struct.fields.length; i++) {
        if (map.containsKey(i)) {
          values.add(map[i]);
        } else {
          values.add(_struct.proxy.getField(src, i));
        }
      }
      return _struct.proxy.instantiate(values);
    }
  }
}

class DogStructureConverterImpl<T> extends DefaultStructureConverter<T> {
  DogStructureConverterImpl(DogStructure<T> structure) : super(s: structure);
}
