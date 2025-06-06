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

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_firestore/dogs_firestore.dart';
import 'package:dogs_firestore/src/codec.dart';
import 'package:dogs_firestore/src/converters.dart';
import 'package:dogs_firestore/src/engine.dart';

// ignore: non_constant_identifier_names
DogPlugin FirebaseDogsPlugin({
  FirebaseFirestore? firestore,
  bool registerInteropConverters = true,
}) =>
    (engine) {
      firestore ??= FirebaseFirestore.instance;

      if (firestore == null) {
        throw ArgumentError(
            "FirebaseFirestore instance must be provided or initialized before using FirebaseDogsPlugin.");
      }

      if (registerInteropConverters) {
        engine.registerAutomatic(FirebaseTimestampConverter());
        engine.registerAutomatic(FirebaseGeoPointConverter());
        engine.registerAutomatic(FirebaseBlobConverter());
      }

      var forked = engine.getChildOrFork(#Firebase,
          codec: FirebaseNativeCodec(), callback: (engine) {
        engine.registerAutomatic(DateTimeToTimestampConverter());
        engine.registerAutomatic(Uint8ListToBlobConverter());
        engine.registerModeFactory(FirestoreDocumentOpmodeFactory());
      });

      final firestoreEngine = DogFirestoreEngine(forked, firestore!);
      engine.setMeta<DogFirestoreEngine>(firestoreEngine);
    };

class FirebaseTimestampConverter extends DogConverter<Timestamp>
    with OperationMapMixin<Timestamp> {
  FirebaseTimestampConverter()
      : super(
            isAssociated: true,
            struct: DogStructure<Timestamp>.synthetic("Timestamp"));

  @override
  Map<Type, OperationMode<Timestamp> Function()> get modes => {
        NativeSerializerMode: () => NativeSerializerMode.create(
              serializer: (value, engine) =>
                  engine.convertObjectToNative(value.toDate(), DateTime),
              deserializer: (value, engine) => Timestamp.fromDate(
                  engine.convertObjectFromNative(value, DateTime)),
            ),
      };
}

class FirebaseGeoPointConverter extends DogConverter<GeoPoint>
    with OperationMapMixin<GeoPoint> {
  FirebaseGeoPointConverter()
      : super(
            isAssociated: true,
            struct: DogStructure<GeoPoint>.synthetic("GeoPoint"));

  @override
  Map<Type, OperationMode<GeoPoint> Function()> get modes => {
        NativeSerializerMode: () => NativeSerializerMode.create(
              serializer: (value, engine) => encode(value),
              deserializer: (value, engine) => decode(value),
            ),
      };

  static String encode(GeoPoint value) =>
      "${value.latitude},${value.longitude}";

  static GeoPoint decode(String value) {
    var parts = value.split(", ");
    return GeoPoint(
        double.parse(parts[0].trim()), double.parse(parts[1].trim()));
  }
}

class FirebaseBlobConverter extends DogConverter<Blob>
    with OperationMapMixin<Blob> {
  FirebaseBlobConverter()
      : super(isAssociated: true, struct: DogStructure<Blob>.synthetic("Blob"));

  @override
  Map<Type, OperationMode<Blob> Function()> get modes => {
        NativeSerializerMode: () => NativeSerializerMode.create(
              serializer: (value, engine) => base64Encode(value.bytes),
              deserializer: (value, engine) => Blob(base64Decode(value)),
            ),
      };
}
