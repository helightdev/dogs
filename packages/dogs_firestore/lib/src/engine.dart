// ignore_for_file: prefer_initializing_formals

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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_firestore/dogs_firestore.dart';

class DogFirestoreEngine {
  static DogFirestoreEngine get instance {
    return dogs.getMeta<DogFirestoreEngine>();
  }

  late final DogEngine engine;
  late final FirebaseFirestore firestore;
  late final OperationModeCacheEntry<FirestoreDocumentOpmode> mode;

  DogFirestoreEngine(DogEngine engine, FirebaseFirestore firestore) {
    this.engine = engine;
    this.firestore = firestore;
    mode = engine.modeRegistry.entry<FirestoreDocumentOpmode>();
  }

  String collectionName<T>() {
    var structure = engine.findStructureByType(T)!;
    var collectionAnnotation = structure.annotationsOf<Collection>().firstOrNull;
    if (collectionAnnotation != null) {
      return collectionAnnotation.name ?? structure.serialName;
    }
    return structure.serialName;
  }

  bool checkSubcollection<T, R>() {
    var structure = engine.findStructureByType(R)!;
    var collectionAnnotation = structure.annotationsOf<Collection>().firstOrNull;
    if (collectionAnnotation != null) {
      return collectionAnnotation.subcollectionOf == T;
    }
    return false;
  }

  bool checkRootCollection<T>() {
    var structure = engine.findStructureByType(T)!;
    var collectionAnnotation = structure.annotationsOf<Collection>().firstOrNull;
    if (collectionAnnotation != null) {
      return collectionAnnotation.subcollectionOf == null;
    }
    return true;
  }

  CollectionReference<T> applyConverter<T>(CollectionReference<Map<String, dynamic>> collection) {
    return collection.withConverter<T>(
        fromFirestore: (snapshot, options) {
          return mode.forType(T, engine).deserialize(snapshot, engine);
        },
        toFirestore: (value, options) => mode.forType(T, engine).serialize(value, engine));
  }

  CollectionReference<T> collection<T>([String? path]) {
    var actualPath = path ?? collectionName<T>();
    return applyConverter<T>(firestore.collection(actualPath));
  }
}
