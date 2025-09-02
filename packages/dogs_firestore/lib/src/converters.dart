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

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogs_core/dogs_core.dart';

/// Override the [DateTimeConverter] to use [Timestamp] instead of [String] as the native representation.
class DateTimeToTimestampConverter extends DogConverter<DateTime> with OperationMapMixin<DateTime> {
  DateTimeToTimestampConverter()
      : super(isAssociated: true, struct: DogStructure.synthetic("DateTime"));

  @override
  Map<Type, OperationMode<DateTime> Function()> get modes => {
        NativeSerializerMode: () => NativeSerializerMode.create(
              serializer: (value, engine) => Timestamp.fromDate(value),
              deserializer: (value, engine) => (value as Timestamp).toDate(),
            ),
      };
}

/// Override the [Uint8ListConverter] to use [Blob] instead of [String] as the native representation.
class Uint8ListToBlobConverter extends DogConverter<Uint8List> with OperationMapMixin<Uint8List> {
  Uint8ListToBlobConverter()
      : super(isAssociated: true, struct: DogStructure.synthetic("Uint8List"));

  @override
  Map<Type, OperationMode<Uint8List> Function()> get modes => {
        NativeSerializerMode: () => NativeSerializerMode.create(
              serializer: (value, engine) => Blob(value),
              deserializer: (value, engine) => (value as Blob).bytes,
            ),
      };
}
