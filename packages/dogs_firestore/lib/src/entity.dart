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
import 'package:dogs_firestore/src/engine.dart';

/// This drop-in replacement for [Dataclass] adds support for common Firestore operations and allows
/// access to the Firestore document ID.
abstract class FirestoreEntity<T extends FirestoreEntity<T>> with Dataclass<T> {

  /// This is the Firestore ID of the document. Will be automatically set when storing a new
  /// document, but can also be set manually.
  String? id;

  /// This is the path of the parent collection, if this is a subcollection.
  /// Will be automatically set by the framework when reading from Firestore, otherwise must
  /// be set manually using [withParent]. Do not modify this field manually.
  String? _injectedPath;

  CollectionReference<T> get selfCollection {
    return DogFirestoreEngine.instance.collection<T>(_injectedPath);
  }

  DocumentReference<T> get selfDocument {
    var reference = selfCollection.doc(id);
    id = reference.id; // Set the auto-generated ID that is created by using a null ID
    return reference;
  }

  CollectionReference<R> getSubCollection<R extends FirestoreEntity<R>>() {
    assert(DogFirestoreEngine.instance.checkSubcollection<T,R>());
    var subcollectionName = DogFirestoreEngine.instance.collectionName<R>();
    return selfCollection.doc(id).collection(subcollectionName).withStructure<R>();
  }

  T withParent<R extends FirestoreEntity<R>>(R parent) {
    assert(DogFirestoreEngine.instance.checkSubcollection<R,T>());
    _injectedPath = "${parent.selfDocument.path}/${DogFirestoreEngine.instance.collectionName<T>()}";
    return this as T;
  }

  /// Saves the document to Firestore. If the document does not exist, it will be created.
  /// If this document doesn't have an ID yet, a new ID will be generated and instantly updated,
  /// you don't have to wait for the Future to complete to get the ID.
  Future<T> save() async {
    if (_injectedPath == null) {
      assert(DogFirestoreEngine.instance.checkRootCollection<T>(), "This entity is not a root "
          "collection, and no parent has been set. Use withParent() to set the parent.");
    }
    var document = selfCollection.doc(id);
    id = document.id; // Set the auto-generated ID that is created by using a null ID
    await document.set(this as T);
    return this as T;
  }

  /// Deletes the document from Firestore. If the document does not exist, this method does nothing.
  Future delete() async {
    var documentReference = selfCollection.doc(id);
    await documentReference.delete();
  }

  /// Checks if the document exists in Firestore.
  Future<bool> exists() async {
    var documentReference = selfCollection.doc(id);
    var snapshot = await documentReference.get();
    return snapshot.exists;
  }

  /// Gets the document from Firestore. If the document does not exist, this method returns null.
  static Future<T?> get<T extends FirestoreEntity<T>>(String id) async {
    assert(DogFirestoreEngine.instance.checkRootCollection<T>());
    var documentReference = DogFirestoreEngine.instance.collection<T>().doc(id);
    var snapshot = await documentReference.get();
    if (snapshot.exists) {
      return snapshot.data()!;
    } else {
      return null;
    }
  }
}

void setInjectedPath(FirestoreEntity entity, String path) {
  entity._injectedPath = path;
}