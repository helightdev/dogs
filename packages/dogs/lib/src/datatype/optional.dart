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

import "package:dogs_core/dogs_core.dart";

/// Port of Java's Optional (https://docs.oracle.com/javase/8/docs/api/java/util/Optional.html)
class Optional<T> {
  /// Common instance for [Optional.empty].
  final T? value;

  /// Constructs an [Optional] with the given [value].
  const Optional([this.value]);

  /// Constructs an empty [Optional].
  const Optional.empty() : this(null);

  /// Constructs an [Optional] with the given non-null [value].
  const Optional.of(T value) : this(value);

  /// Constructs an [Optional] with the given [value] or empty if [value] is null.
  const Optional.nullable(T? value) : this(value);

  /// Returns an empty [Optional] instance.
  bool get isPresent => value != null;

  /// If a value is present in this [Optional], returns the value,
  T get() => value!;

  /// If a value is present, performs the given action with the value,
  void ifPresent(Function(T) consumer) {
    final current = value;
    if (current != null) consumer(current);
  }

  /// If a value is present, performs the given action with the value and
  /// returns it in an [Optional] wrapper, otherwise returns an empty [Optional].
  Optional<R> map<R>(R? Function(T) mapper) {
    final current = value;
    if (current == null) return Optional<R>.empty();
    return Optional(mapper(current));
  }

  /// If a value is present, returns the value, otherwise returns [other].
  T orElse(T other) => value ?? other;

  /// Returns the value if present, otherwise returns [null].
  T? orElseGet(T Function() supplier) {
    final current = value;
    if (current == null) {
      return supplier();
    }
    return current;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Optional &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// [NTreeArgConverter] for [Optional]s.
class OptionalNTreeArgConverter<T> extends NTreeArgConverter<Optional> {
  @override
  Optional deserialize(value, DogEngine engine) {
    return Optional<T>(value == null ? null : deserializeArg(value, 0, engine));
  }

  @override
  serialize(Optional value, DogEngine engine) {
    return value.isPresent ? serializeArg(value.get(), 0, engine) : null;
  }
}
