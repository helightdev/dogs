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

/// Initializer for form field values.
sealed class Initializer {
  const Initializer();

  Object? call() => null;
}

/// Non constant initializer for form field values.
class FactoryInitializer implements Initializer {
  final Object? Function() factory;

  const FactoryInitializer(this.factory);

  @override
  Object? call() => factory();
}

/// Constant initializer for form field values.
class ValueInitializer implements Initializer {
  final Object? value;

  const ValueInitializer(this.value);

  @override
  Object? call() => value;
}

/// Default initializer for form field values.
/// Similar to [NullInitializer] but will get replaced with a possible default
/// value by a [AutoFormFieldFactory].
class DefaultInitializer implements Initializer {
  const DefaultInitializer();

  @override
  Object? call() => null;
}

/// Null initializer for form field values.
class NullInitializer implements Initializer {
  const NullInitializer();

  @override
  Object? call() => null;
}

/// Null initializer for form field values.
const nullInitializer = DefaultInitializer();

/// Default initializer for form field values.
/// Similar to [NullInitializer] but will get replaced with a possible default
/// value by a [AutoFormFieldFactory].
const defaultInitializer = DefaultInitializer();
