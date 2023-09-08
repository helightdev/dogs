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

class NativeRetentionConverter<T> extends DogConverter<T> with OperationMapMixin<T> {

  const NativeRetentionConverter() : super();

  @override
  Map<Type, OperationMode<T> Function()> get modes => {
    NativeSerializerMode: () => NativeSerializerMode.create(
        serializer: (value,engine) => value,
        deserializer: (value,engine) => value
    ),
    GraphSerializerMode: () => GraphSerializerMode.create(
        serializer: (value,engine) => engine.codec.fromNative(value),
        deserializer: (value,engine) => (value as DogNative).value as T
    )
  };

  @override
  String toString() {
    return 'Native<$T>';
  }
}