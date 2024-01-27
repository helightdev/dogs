/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

import 'package:dogs_odm/dogs_odm.dart';
import 'package:dogs_odm/query_dsl.dart';
import 'package:mongo_dart/mongo_dart.dart';

export 'package:mongo_dart/mongo_dart.dart' hide all, Type;

export 'src/codec.dart';
export 'src/database.dart';
export 'src/odm.dart';
export 'src/query.dart';
export 'src/repository.dart';

extension SelectorBuilderExtension on SelectorBuilder {
  FilterExpr get asFilter => nativeFilter(this);
}