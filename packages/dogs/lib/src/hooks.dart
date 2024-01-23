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

/// `SerializationHook` is an abstract class that implements `StructureMetadata`.
/// It provides two methods for handling serialization and deserialization events.
///
/// Serialization hooks are by default only used by [NativeSerializerMode] and descendants.
abstract class SerializationHook implements StructureMetadata {
  /// Default constructor for `SerializationHook`.
  const SerializationHook();

  /// This method is called after an object is serialized by [NativeSerializerMode].
  ///
  /// It takes four parameters:
  /// - `obj`: The object that has been serialized.
  /// - `map`: The map representation of the serialized object.
  /// - `structure`: The `DogStructure` instance associated with the serialized object.
  /// - `engine`: The `DogEngine` instance that performed the serialization.
  void postSerialization(dynamic obj, Map<String, dynamic> map,
      DogStructure structure, DogEngine engine) {}

  /// This method is called before a map is deserialized by [NativeSerializerMode].
  ///
  /// It takes three parameters:
  /// - `map`: The map representation of the object to be deserialized.
  /// - `structure`: The `DogStructure` instance associated with the object to be deserialized.
  /// - `engine`: The `DogEngine` instance that will perform the deserialization.
  void beforeDeserialization(
      Map<String, dynamic> map, DogStructure structure, DogEngine engine) {}
}

typedef MigrationFunction = Function(
    Map<String, dynamic> map, DogStructure structure, DogEngine engine);

/// `LightweightMigration` is a class that extends `SerializationHook`.
/// It provides a lightweight way to handle migrations by executing a list of migration functions before deserialization.
///
/// The class has one property:
/// - `functions`: A list of migration functions to be executed before deserialization.
class LightweightMigration extends SerializationHook {
  /// The list of migration functions to be executed before deserialization.
  final List<MigrationFunction> migrations;

  /// Constructs a `LightweightMigration` instance.
  ///
  /// Takes a list of migration functions as a parameter.
  const LightweightMigration(this.migrations);

  /// Executes each migration function in the `migrations` list before deserialization.
  @override
  void beforeDeserialization(
      Map<String, dynamic> map, DogStructure structure, DogEngine engine) {
    for (var value in migrations) {
      value(map, structure, engine);
    }
  }
}

/// `RevisionMigration` is a class that extends `SerializationHook`.
/// It provides a way to handle migrations by executing a list of migration functions before deserialization and after serialization.
///
/// The class has two properties:
/// - `revisionKey`: A string that represents the key for the revision number in the serialized object. Defaults to "_rev".
/// - `functions`: A list of migration functions to be executed before deserialization and after serialization.
///
/// It differs from `LightweightMigration` in that it also stores the current revision number in the serialized object and
/// only executes the migration functions that correspond to newer revisions. If no migrations are currently defined, the revision number
/// will be set to 0. Otherwise, it will be set to the number of migration functions, representing the latest revision.
class RevisionMigration extends SerializationHook {
  /// The key for the revision number in the serialized object.
  final String revisionKey;

  /// The list of migration functions to be executed before deserialization and after serialization.
  final List<MigrationFunction> migrations;

  /// Constructs a `RevisionMigration` instance.
  ///
  /// Takes a list of migration functions and an optional revision key as parameters.
  const RevisionMigration(this.migrations, {this.revisionKey = "_rev"});

  /// Executes each migration function in the `migrations` list that corresponds to
  /// a version number greater than or equal to the current version.
  @override
  void beforeDeserialization(
      Map<String, dynamic> map, DogStructure structure, DogEngine engine) {
    final version = map[revisionKey] as int? ?? 0;
    for (var i = version; i < migrations.length; i++) {
      if (i >= version) {
        migrations[i](map, structure, engine);
      }
    }
  }

  /// Updates the revision number in the serialized object to the number of migration functions.
  @override
  void postSerialization(dynamic obj, Map<String, dynamic> map,
      DogStructure structure, DogEngine engine) {
    map[revisionKey] = migrations.length;
  }
}
