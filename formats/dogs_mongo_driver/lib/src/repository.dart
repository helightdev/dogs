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

import 'package:dogs_mongo_driver/dogs_mongo_driver.dart';
import 'package:dogs_odm/dogs_odm.dart';

abstract class MongoRepository<T extends Object, ID extends Object> extends Repository<T, ID> with
        RepositoryMixin<T, ID, MongoOdmSystem, MongoDatabase, MongoDatabase<T>, ObjectId>,
        QueryableRepositoryMixin<T, ID, MongoOdmSystem, MongoDatabase, MongoDatabase<T>, ObjectId>,
        PageableRepositoryMixin<T, ID, MongoOdmSystem, MongoDatabase, MongoDatabase<T>, ObjectId> {

  final String? collectionName;

  MongoRepository({this.collectionName});

  factory MongoRepository.plain({String? collectionName}) {
    return _MongoRepositoryImpl<T, ID>(collectionName: collectionName);
  }
}

class _MongoRepositoryImpl<T extends Object, ID extends Object> extends MongoRepository<T,ID> {
  _MongoRepositoryImpl({super.collectionName}) : super();
}