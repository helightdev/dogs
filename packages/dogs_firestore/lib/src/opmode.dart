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

import 'entity.dart';

abstract class FirestoreDocumentOpmode<T> extends TypeToken<T> implements OperationMode<T>{
  T deserialize(DocumentSnapshot<Map<String, dynamic>> snapshot, DogEngine engine);
  Map<String, dynamic> serialize(T value, DogEngine engine);
}

class DefaultFirestoreDocumentOpmode<T> extends FirestoreDocumentOpmode<T> {

  DogStructure<T> structure;
  
  DefaultFirestoreDocumentOpmode(this.structure);

  @override
  T deserialize(DocumentSnapshot<Map<String, dynamic>> snapshot, DogEngine engine) {
    var obj = engine.convertObjectFromNative(snapshot.data() ?? <String,dynamic>{}, T);
    if (obj is FirestoreEntity) {
      setInjectedSnapshot(obj, snapshot);
    }
    return obj;
  }

  @override
  Map<String, dynamic> serialize(T value, DogEngine engine) {
    return engine.convertObjectToNative(value, T) as Map<String, dynamic>;
  }

  @override
  void initialise(DogEngine engine) {

  }
}


class FirestoreDocumentOpmodeFactory extends OperationModeFactory<FirestoreDocumentOpmode> {
  @override
  FirestoreDocumentOpmode? forConverter(DogConverter<dynamic> converter, DogEngine engine) {
    if (converter.struct != null) {
      var structure = converter.struct!;
      return structure.consumeTypeArg(forType, structure);
    }
    return null;
  }

  DefaultFirestoreDocumentOpmode<T> forType<T>(DogStructure structure) {
    return DefaultFirestoreDocumentOpmode<T>(structure as DogStructure<T>);
  }
}