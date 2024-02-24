/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

import 'package:dogs_core/dogs_core.dart';

export 'src/analysis.dart';
export 'src/annotations.dart';
export 'src/database.dart';
export 'src/odm.dart';
export 'src/query.dart';
export 'src/repository.dart';
export 'src/sort.dart';

void installOdmConverters([DogEngine? engine]) {
  engine ??= DogEngine.instance;
  // Currently does nothing as pagination is now moved to the core package
}