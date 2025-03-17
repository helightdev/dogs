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

import "package:dogs_core/dogs_core.dart";
import "package:dogs_core/src/schema/spec.dart";

/// A [SchemaFieldVisitor] that adds a description to an [APISchemaObject].
class Description extends StructureMetadata
    implements SchemaFieldVisitor {
  /// The description which will be added to the [APISchemaObject].
  final String description;

  /// Creates a field description containing the supplied [description].
  const Description(this.description);

  @override
  void visitSchemaField(SchemaField object) {
    object[SchemaProperties.description] = description;
  }
}
