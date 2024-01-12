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
import 'package:flutter/foundation.dart';

/// If this is set to true, the latest snapshot of a document will be cached and reused.
/// This is useful if you want to reduce the amount of reads to Firestore, but it will increase
/// the amount of memory used by the application and has also slightly higher performance costs.
bool kConserveSnapshot = true;

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

  /// This is the latest snapshot of this document, used for cursor queries.
  DocumentSnapshot? _latestSnapshot;

  /// Returns the collection reference of this document.
  CollectionReference<T> get selfCollection {
    return DogFirestoreEngine.instance.collection<T>(_injectedPath);
  }

  /// Returns the document reference of this document.
  DocumentReference<T> get selfDocument {
    var reference = selfCollection.doc(id);
    id = reference.id; // Set the auto-generated ID that is created by using a null ID
    return reference;
  }

  /// Returns a future of the latest snapshot of this document.
  /// This is purely for use with queries, and should not be used for anything else.
  ///
  /// **Note that this feature is not optimized for performance, but for a lower amount of reads to
  /// reduce Firestore costs.**
  Future<DocumentSnapshot> snapshot() async {
    var latestSnapshot = _latestSnapshot;
    if (latestSnapshot != null && latestSnapshot.exists && latestSnapshot.id == id) {
      // This object is injected, we need to deserialize it again to compare it
      if (latestSnapshot is DocumentSnapshot<Map<String, dynamic>>) {
        var capableEngine = DogFirestoreEngine.instance.engine;
        var decoded = DogFirestoreEngine.instance.mode.forType(T, capableEngine).deserialize(latestSnapshot, capableEngine);
        if (decoded == this) return latestSnapshot; // Compare if the object is the same
        // This object is not injected, we can compare it directly
      } else if (latestSnapshot.data() == this) {
        return latestSnapshot;
      }
    }
    if (kDebugMode) print("Snapshot cache miss for $id");

    // No similar snapshot exists - This is either a new object, or the object has been modified
    var currentSnapshot = selfDocument.get();
    _latestSnapshot = await currentSnapshot;
    return currentSnapshot;
  }

  /// Returns a stream of the document changes.
  /// This stream will emit the current document immediately, and then emit any changes to the document.
  Stream<T?> get documentChanges => selfDocument.snapshots().map((event) => event.data());

  CollectionReference<R> getSubCollection<R extends FirestoreEntity<R>>() {
    assert(DogFirestoreEngine.instance.checkSubcollection<T, R>());
    var subcollectionName = DogFirestoreEngine.instance.collectionName<R>();
    return selfCollection.doc(id).collection(subcollectionName).withStructure<R>();
  }

  /// Sets the parent collection of this document. This is required for subcollections.
  T withParent<R extends FirestoreEntity<R>>(R parent) {
    assert(DogFirestoreEngine.instance.checkSubcollection<R, T>());
    _injectedPath = "${parent.selfDocument.path}/${DogFirestoreEngine.instance.collectionName<T>()}";
    return this as T;
  }

  /// Saves the document to Firestore. If the document does not exist, it will be created.
  /// If this document doesn't have an ID yet, a new ID will be generated and instantly updated,
  /// you don't have to wait for the Future to complete to get the ID.
  Future<T> save() async {
    if (_injectedPath == null) {
      assert(
          DogFirestoreEngine.instance.checkRootCollection<T>(),
          "This entity is not a root "
          "collection, and no parent has been set. Use withParent() to set the parent.");
    }
    var document = selfCollection.doc(id);
    id = document.id; // Set the auto-generated ID that is created by using a null ID
    await document.set(this as T);
    return this as T;
  }

  /// Updates the document in Firestore. If the document does not exist, this method does nothing.
  /// Warning: This method takes normal firestore data and does not use converters.
  Future<T> update(Map<String, dynamic> data) async {
    if (_injectedPath == null) {
      assert(
          DogFirestoreEngine.instance.checkRootCollection<T>(),
          "This entity is not a root "
          "collection, and no parent has been set. Use withParent() to set the parent.");
    }
    var document = selfCollection.doc(id);
    id = document.id; // Set the auto-generated ID that is created by using a null ID
    await document.update(data);
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

  // <editor-fold desc="Instance DAO methods">
  /// Returns all [R] entities in the corresponding subcollection of this entity matching the [query].
  Future<List<R>> $query<R extends FirestoreEntity<R>>({Query<R> Function(Query<R> query)? query, R? startAfter, R? endBefore, R? startAt, R? endAt}) async {
    var subCollection = getSubCollection<R>();
    Query<R> q = subCollection;
    if (query != null) {
      q = query(q);
    }

    // Cursor start
    if (startAfter != null) {
      q = q.startAfterDocument(await startAfter.snapshot());
    } else if (startAt != null) {
      q = q.startAtDocument(await startAt.snapshot());
    }

    // Cursor end
    if (endBefore != null) {
      q = q.endBeforeDocument(await endBefore.snapshot());
    } else if (endAt != null) {
      q = q.endAtDocument(await endAt.snapshot());
    }
    var snapshot = await q.get();
    return snapshot.docs.map((e) => e.data()).toList();
  }

  /// Finds the first [R] entity in the corresponding subcollection of this entity matching the [query].
  /// Returns null if no entity was found.
  Future<R?> $find<R extends FirestoreEntity<R>>({Query<R> Function(Query<R> query)? query}) async {
    var subCollection = getSubCollection<R>();
    Query<R> q = subCollection;
    if (query != null) {
      q = query(q);
    }
    var snapshot = await q.get();
    if (snapshot.size == 0) return null;
    return snapshot.docs.first.data();
  }

  Future<R?> $get<R extends FirestoreEntity<R>>(String id, {R Function()? orCreate}) async {
    assert(DogFirestoreEngine.instance.checkSubcollection<T, R>());
    var documentReference = getSubCollection<R>().doc(id);
    var snapshot = await documentReference.get();
    if (snapshot.exists) {
      return snapshot.data()!;
    } else {
      if (orCreate != null) {
        var entity = orCreate();
        entity.id = id;
        entity.withParent(this as T);
        return await entity.save();
      }
      return null;
    }
  }

  /// Stores an [R] entity which in the corresponding subcollection of this entity.
  Future<R?> $store<R extends FirestoreEntity<R>>(R entity) async {
    return await entity.withParent(this as T).save();
  }
  // </editor-fold>

  // <editor-fold desc="Static DAO methods">
  /// Gets the document from Firestore. If the document does not exist, this method returns null.
  static Future<T?> get<T extends FirestoreEntity<T>>(String id, {T Function()? orCreate}) async {
    assert(DogFirestoreEngine.instance.checkRootCollection<T>());
    var documentReference = DogFirestoreEngine.instance.collection<T>().doc(id);
    var snapshot = await documentReference.get();
    if (snapshot.exists) {
      return snapshot.data()!;
    } else {
      if (orCreate != null) {
        var entity = orCreate();
        entity.id = id;
        return await entity.save();
      }
      return null;
    }
  }

  static Future<List<T>> query<T extends FirestoreEntity<T>>({Query<T> Function(Query<T> query)? query, T? startAfter, T? endBefore, T? startAt, T? endAt}) async {
    var collection = DogFirestoreEngine.instance.collection<T>();
    Query<T> q = collection;
    if (query != null) {
      q = query(q);
    }

    // Cursor start
    if (startAfter != null) {
      q = q.startAfterDocument(await startAfter.snapshot());
    } else if (startAt != null) {
      q = q.startAtDocument(await startAt.snapshot());
    }

    // Cursor end
    if (endBefore != null) {
      q = q.endBeforeDocument(await endBefore.snapshot());
    } else if (endAt != null) {
      q = q.endAtDocument(await endAt.snapshot());
    }

    var snapshot = await q.get();
    return snapshot.docs.map((e) => e.data()).toList();
  }

  static Future<T?> find<T extends FirestoreEntity<T>>({Query<T> Function(Query<T> query)? query}) async {
    var collection = DogFirestoreEngine.instance.collection<T>();
    Query<T> q = collection;
    if (query != null) {
      q = query(q);
    }
    var snapshot = await q.get();
    if (snapshot.size == 0) return null;
    return snapshot.docs.first.data();
  }
  // </editor-fold>
}

void setInjectedSnapshot(FirestoreEntity entity, DocumentSnapshot snapshot) {
  var id = snapshot.id;
  var path = snapshot.reference.path;
  entity.id = id;
  entity._injectedPath = path.substring(0, path.length - id.length - 1);
  if (kConserveSnapshot) entity._latestSnapshot = snapshot;
}
