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

/// Encodes this [value] to json, using the [DogConverter] associated with [T].
String toJson<T>(T value) => DogEngine.instance.jsonEncode<T>(value);

/// Decodes this [json] to an [T] instance, using the [DogConverter] associated with [T].
T fromJson<T>(String json) => DogEngine.instance.jsonDecode(json);

/// Copies the [src] object and applies [overrides] to the created instance
/// using the [Copyable] mixin associated with [T].
T copy<T>(T src, [Map<String, dynamic>? overrides]) =>
    DogEngine.instance.copy(src, overrides);
