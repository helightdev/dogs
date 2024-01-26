/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

import 'package:dogs_core/dogs_core.dart';

import 'dogs_odm.dart';

export 'src/annotations.dart';
export 'src/analysis.dart';
export 'src/database.dart';
export 'src/odm.dart';
export 'src/pagination.dart';
export 'src/query.dart';
export 'src/repository.dart';


void installOdmConverters([DogEngine? engine]) {
  engine ??= DogEngine.instance;
  engine.registerTreeBaseFactory(Page, pageBaseFactory);
}