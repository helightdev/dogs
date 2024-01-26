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
import 'package:dogs_odm/src/analysis.dart';
import 'package:dogs_odm/src/database.dart';

abstract class OdmSystem<SYS_DB extends CrudDatabase, SYS_ID extends Object> {

  static final Map<Type, OdmSystem> _ormSystems = <Type, OdmSystem>{};

  static T get<T extends OdmSystem>() {
    return _ormSystems[T]! as T;
  }

  static OdmSystem? get any {
    return _ormSystems.values.firstOrNull;
  }
  
  static void register<T extends OdmSystem>(T system) {
    _ormSystems[T] = system;
  }
  
  OdmSystem();

  final Map<Type, EntityAnalysis> _entityAnalysis = <Type, EntityAnalysis>{};

  DogEngine get engine;

  EntityAnalysis<T,SYS_DB,SYS_ID> getAnalysis<T extends Object>() {
    return _entityAnalysis.putIfAbsent(T, () => EntityAnalysis<T,SYS_DB,SYS_ID>(
        engine.findStructureByType(T)! as DogStructure<T>, this
    )) as EntityAnalysis<T,SYS_DB,SYS_ID>;
  }
  
  dynamic serializeObject(dynamic entity, Type type) {
    return engine.modeRegistry.nativeSerialization.forType(type, engine)
        .serialize(entity, engine);
  }
  
  dynamic deserializeObject(dynamic serialized, Type type) {
    return engine.modeRegistry.nativeSerialization.forType(type, engine)
        .deserialize(serialized, engine);
  }

  SYS_ID? resolveId<T extends Object>(T entity) {
    return getAnalysis<T>().getId(entity);
  }

  SYS_ID generateId<T extends Object>(T entity);

  SYS_ID? transformId<FOREIGN>(FOREIGN? id);
  FOREIGN inverseTransformId<FOREIGN>(SYS_ID id);
  
  CrudDatabase<T,SYS_ID> getDatabase<T extends Object>();
}