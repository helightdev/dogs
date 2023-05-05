import 'package:dogs_core/dogs_core.dart';
import 'package:logging/logging.dart';
import 'package:smoke_test_0/dogs.g.dart';
import 'package:smoke_test_0/validation.dart';

import 'conformities.dart';
import 'models.dart';

Future main() async {
  await initialiseDogs();
  testModels();
  testConformities();
  testValidators();
  print("All tests passed");
}

void testValidators() {
  testValidation(ValidateA.trues, ValidateA.falses);
  testValidation(ValidateB.trues, ValidateB.falses);
  testValidation(ValidateC.trues, ValidateC.falses);
  testValidation(ValidateD.trues, ValidateD.falses);
  testValidation(ValidateE.trues, ValidateE.falses);
  testValidation(ValidateF.trues, ValidateF.falses);
}

void testModels() {
  testSingleModel(ModelA.variant0, ModelA.variant1);
  testSingleModel(ModelB.variant0, ModelB.variant1);
  testSingleModel(ModelC.variant0, ModelC.variant1);
  testSingleModel(ModelD.variant0, ModelD.variant1);
  testSingleModel(ModelE.variant0, ModelE.variant1);
  testSingleModel(ModelF.variant0, ModelF.variant1);
  testSingleModel(Note.variant0, Note.variant1);
}

void testConformities() {
  testSimple(ConformityBasic.variant0, ConformityBasic.variant1);
  testSimple(ConformityData.variant0, ConformityData.variant1);
  testSimple(ConformityBean.variant0, ConformityBean.variant1);
}

void testValidation<T extends Dataclass<T>>(List<T> Function() trues, List<T> Function() falses) {
  trues().forEach((element) {
    if (!element.isValid) {
      throw Exception("Valid input is marked as invalid ${element}");
    }
  });

  falses().forEach((element) {
    if (element.isValid) {
      throw Exception("Invalid input is marked as valid ${element}");
    }
  });
}

void testSimple<T>(T Function() a, T Function() b) {
  var va0 = a();
  var vb0 = b();
  var ea = dogs.jsonEncode<T>(va0);
  var eb = dogs.jsonEncode<T>(vb0);
  var da = dogs.jsonDecode<T>(ea);
  var db = dogs.jsonDecode<T>(eb);
}

void testSingleModel<T>(T Function() a, T Function() b) {
  var va0 = a();
  var va1 = a();
  var vb0 = b();
  var vb1 = b();
  var ea = dogs.jsonEncode<T>(va0);
  var eb = dogs.jsonEncode<T>(vb0);
  var da = dogs.jsonDecode<T>(ea);
  var db = dogs.jsonDecode<T>(eb);
  if (va1 != da || va0 != da) throw Exception("Non-pure serialization");
  if (vb1 != db || vb0 != db) throw Exception("Non-pure serialization");
  if (ea == eb) throw Exception("Wrong equality");
}