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

import 'package:collection/collection.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_odm/dogs_odm.dart';

class EntityAnalysis<T extends Object,SYS_DB extends CrudDatabase, SYS_ID extends Object> {

  DogStructure<T> structure;
  OdmSystem<SYS_DB,SYS_ID> system;

  late DogStructureField idProperty;
  late int idPropertyIndex;
  late String idPropertyName;
  late StructureNativeSerialization nativeSerialization;

  EntityAnalysis(this.structure, this.system) {
    var idProperty = structure.fields
        .firstWhereOrNull((element) => element.firstAnnotationOf<Id>() != null);
    idProperty ??= structure.fields.where((element) => element.name == "id").firstOrNull;
    if (idProperty == null) {
      throw ArgumentError("Entity ${structure.typeArgument} does not have an id property");
    }
    this.idProperty = idProperty;
    idPropertyIndex = structure.fields.indexOf(idProperty);
    idPropertyName = idProperty.name;

    var opmode = system.engine.modeRegistry
        .nativeSerialization.forType(T, system.engine);
    if (opmode is! StructureNativeSerialization) {
      throw ArgumentError("Native serialization for type $T is not a structure");
    }
    nativeSerialization = opmode;
  }
  
  EntityIntermediate<SYS_ID> encode<FOREIGN_ID extends Object>(T entity) {
    var id = getId(entity);
    id ??= system.generateId<T>(entity);
    Map<String, dynamic> native = nativeSerialization.serialize(entity, system.engine);
    native.remove(idPropertyName);
    return EntityIntermediate(id, native);
  }
  
  T decode(EntityIntermediate<SYS_ID> intermediate) {
    var map = Map<String,dynamic>.of(intermediate.native);
    map[idPropertyName] = toForeignId(intermediate.id!);
    return nativeSerialization.deserialize(map, system.engine);
  }

  //<editor-fold desc="Ids">
  SYS_ID? getId(T entity) {
    return idProperty.type.qualifiedOrBase.consumeTypeArg(_getId, entity);
  }

  Object toForeignId(SYS_ID id) {
    return idProperty.type.qualifiedOrBase.consumeTypeArg(_toForeignId, id);
  }

  Object _toForeignId<FOREIGN_ID>(SYS_ID id) {
    FOREIGN_ID fid = system.inverseTransformId<FOREIGN_ID>(id);
    return fid as Object;
  }

  SYS_ID? _getId<FOREIGN_ID>(T entity) {
    var obj = getIdFieldValue(entity);
    return system.transformId<FOREIGN_ID>(obj as FOREIGN_ID?);
  }
  
  Object? getIdFieldValue(T entity) {
    return structure.proxy.getField(entity, idPropertyIndex);
  }
  //</editor-fold>
}

class EntityIntermediate<SYS_ID extends Object> {
  final SYS_ID? id;
  final Map<String, dynamic> native;

  EntityIntermediate(this.id, this.native);

  EntityIntermediate<SYS_ID> copyWith({SYS_ID? id, Map<String,dynamic>? native}) {
    return EntityIntermediate<SYS_ID>(id ?? this.id, native ?? this.native);
  }
}