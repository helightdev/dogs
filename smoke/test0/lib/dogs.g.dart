import 'package:smoke_test_0/models.conv.g.dart';
import 'package:smoke_test_0/conformities.conv.g.dart';
import 'package:smoke_test_0/validation.conv.g.dart';
import 'package:smoke_test_0/special.conv.g.dart';
import 'package:smoke_test_0/special.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:smoke_test_0/models.conv.g.dart' as gen0;
import 'package:smoke_test_0/conformities.conv.g.dart' as gen1;
import 'package:smoke_test_0/validation.conv.g.dart' as gen2;
import 'package:smoke_test_0/special.conv.g.dart' as gen3;
import 'package:smoke_test_0/special.dart' as gen4;
export 'package:smoke_test_0/models.conv.g.dart';
export 'package:smoke_test_0/conformities.conv.g.dart';
export 'package:smoke_test_0/validation.conv.g.dart';
export 'package:smoke_test_0/special.conv.g.dart';
export 'package:smoke_test_0/special.dart';

Future initialiseDogs() async {
  var engine = DogEngine.hasValidInstance ? DogEngine.instance : DogEngine();
  engine.registerAllConverters([
    gen0.ModelAConverter(),
    gen0.ModelBConverter(),
    gen0.ModelCConverter(),
    gen0.ModelDConverter(),
    gen0.ModelEConverter(),
    gen0.ModelFConverter(),
    gen0.NoteConverter(),
    gen1.ConformityBeanConverter(),
    gen1.ConformityBasicConverter(),
    gen1.ConformityDataConverter(),
    gen2.ValidateAConverter(),
    gen2.ValidateBConverter(),
    gen2.ValidateCConverter(),
    gen2.ValidateDConverter(),
    gen2.ValidateEConverter(),
    gen2.ValidateFConverter(),
    gen3.EnumAConverter(),
    gen4.ConvertableAConverter()
  ]);
  engine.setSingleton();
}
