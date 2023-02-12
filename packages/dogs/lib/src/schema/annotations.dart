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

import 'package:conduit_open_api/v3.dart';
import 'package:dogs_core/dogs_core.dart';

class ApiDescription extends StructureMetadata
    implements APISchemaObjectMetaVisitor {
  final String description;
  const ApiDescription(this.description);

  @override
  void visit(APISchemaObject object) {
    object.description = description;
  }
}

class Range extends StructureMetadata implements APISchemaObjectMetaVisitor {
  final num? min;
  final num? max;
  final bool minExclusive;
  final bool maxExclusive;

  const Range({
    this.min,
    this.max,
    this.minExclusive = false,
    this.maxExclusive = false,
  });

  @override
  void visit(APISchemaObject object) {
    object.minimum = min;
    object.maximum = max;
    object.exclusiveMinimum = minExclusive;
    object.exclusiveMaximum = maxExclusive;
  }
}

class Minimum extends StructureMetadata implements APISchemaObjectMetaVisitor {
  final num? min;
  final bool minExclusive;

  const Minimum({
    this.min,
    this.minExclusive = false,
  });

  @override
  void visit(APISchemaObject object) {
    object.minimum = min;
    object.exclusiveMinimum = minExclusive;
  }
}

class Maximum extends StructureMetadata implements APISchemaObjectMetaVisitor {
  final num? max;
  final bool maxExclusive;

  const Maximum({
    this.max,
    this.maxExclusive = false,
  });

  @override
  void visit(APISchemaObject object) {
    object.maximum = max;
    object.exclusiveMaximum = maxExclusive;
  }
}

class SizeRange extends StructureMetadata
    implements APISchemaObjectMetaVisitor {
  final int? min;
  final int? max;

  const SizeRange({this.min, this.max});

  @override
  void visit(APISchemaObject object) {
    object.minItems = min;
    object.maxItems = max;
  }
}

class LengthRange extends StructureMetadata
    implements APISchemaObjectMetaVisitor {
  final int? min;
  final int? max;

  const LengthRange({this.min, this.max});

  @override
  void visit(APISchemaObject object) {
    object.minLength = min;
    object.maxLength = max;
  }
}
