import 'package:smoke_test_openapi/test.slib.g.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:smoke_test_openapi/test.slib.g.dart' as gen0;
export 'package:smoke_test_openapi/test.slib.g.dart';

Future initialiseDogs() async {
  var engine = DogEngine.hasValidInstance ? DogEngine.instance : DogEngine();
  engine.registerAllConverters([
    gen0.DateConverter(),
    gen0.ApiResponseConverter(),
    gen0.CategoryConverter(),
    gen0.OrderConverter(),
    gen0.PetConverter(),
    gen0.TagConverter(),
    gen0.UserConverter()
  ]);
  engine.setSingleton();
}
