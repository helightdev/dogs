library dogs_firestore;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogs_firestore/src/engine.dart';

export 'src/annotations.dart';
export 'src/entity.dart' hide setInjectedSnapshot;
export 'src/opmode.dart';
export 'src/interop.dart';

extension DogFirestoreExtension on FirebaseFirestore {
  /// Returns a [CollectionReference] for the specified [T] type that uses a [DogStructure] based
  /// converter.
  CollectionReference<T> structureCollection<T>() {
    return DogFirestoreEngine.instance.collection<T>();
  }
}

extension DogCollectionReferenceExtension<T> on CollectionReference<Map<String, dynamic>> {
  /// Applies a DOGs based document converter to this collection reference using [withConverter].
  CollectionReference<R> withStructure<R>() => DogFirestoreEngine.instance.applyConverter<R>(this);
}
