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

import 'package:dogs_odm/dogs_odm.dart';
import 'package:dogs_odm/memory/database.dart';

import 'odm.dart';

class MemoryRepository<T extends Object, ID extends Object>
    extends Repository<T, ID> with
        RepositoryMixin<T, ID, MemoryOdmSystem, MemoryDatabase, MemoryDatabase<T>, String>,
        QueryableRepositoryMixin<T, ID, MemoryOdmSystem, MemoryDatabase, MemoryDatabase<T>, String>,
        PageableRepositoryMixin<T, ID, MemoryOdmSystem, MemoryDatabase, MemoryDatabase<T>, String> {

}
