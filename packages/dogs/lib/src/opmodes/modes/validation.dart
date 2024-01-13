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

abstract class ValidationMode<T> implements OperationMode<T> {
  bool validate(T value, DogEngine engine);
  AnnotationResult annotate(T value, DogEngine engine);

  static ValidationMode<T> create<T, IR>(
      {IR? Function(DogEngine engine)? initializer,
      AnnotationResult Function(T value, DogEngine engine, IR? cached)?
          annotator,
      required bool Function(T value, DogEngine engine, IR? cached)
          validator}) {
    IR? Function(DogEngine) initializerFunc =
        initializer ?? _InlineValidationMode._noInit;
    AnnotationResult Function(T, DogEngine, IR?) annotatorFunc =
        annotator ?? _InlineValidationMode._noAnnotate;
    return _InlineValidationMode(initializerFunc, validator, annotatorFunc);
  }
}

class _InlineValidationMode<T, IR> extends ValidationMode<T>
    with TypeCaptureMixin<T> {
  static IR? _noInit<IR>(DogEngine engine) => null;
  static AnnotationResult _noAnnotate<T, IR>(
          T value, DogEngine engine, IR? cached) =>
      AnnotationResult.empty();

  IR? Function(DogEngine engine) initializer;
  bool Function(T value, DogEngine engine, IR? cached) validator;
  AnnotationResult Function(T value, DogEngine engine, IR? cached) annotator;

  IR? _ir;

  _InlineValidationMode(this.initializer, this.validator, this.annotator);

  @override
  void initialise(DogEngine engine) {
    _ir = initializer(engine);
  }

  @override
  bool validate(T value, DogEngine engine) => validator(value, engine, _ir);

  @override
  AnnotationResult annotate(T value, DogEngine engine) =>
      annotator(value, engine, _ir);
}
