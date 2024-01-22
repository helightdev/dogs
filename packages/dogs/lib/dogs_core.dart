// ignore_for_file: invalid_export_of_internal_element

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

library dogs_core;

// Include lyell
export 'package:lyell/lyell.dart';

export 'src/converters/common.dart';
export 'src/converters/enum.dart';
export 'src/converters/native.dart';
export 'src/converters/polymorphic.dart';
export 'src/structure/converter.dart';

export 'src/opmodes/operation.dart';
export 'src/opmodes/factory.dart';

export 'src/schema/schema.dart';
export 'src/schema/visitor.dart';

export 'src/structure/field.dart';
export 'src/structure/graph.dart';
export 'src/structure/harbinger.dart';
export 'src/structure/native.dart';
export 'src/structure/proxy.dart';
export 'src/structure/structure.dart';
export 'src/structure/validator.dart';

export 'src/visitors/null_exclusion.dart';
export 'src/visitors/string_keyed.dart';

export 'src/converter.dart';
export 'src/codec.dart';
export 'src/dataclass.dart';
export 'src/engine.dart';
export 'src/extensions.dart';
export 'src/global.dart';
export 'src/graph_value.dart';
export 'src/hooks.dart';
export 'src/json.dart';
export 'src/optional.dart';
export 'src/projections.dart';
export 'src/serializer.dart';
export 'src/trees.dart';
export 'src/visitor.dart';
