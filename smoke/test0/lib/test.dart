import 'package:dogs_cbor/dogs_cbor.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_toml/dogs_toml.dart';
import 'package:dogs_yaml/dogs_yaml.dart';
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
  testCbor();
  testYaml();
  testToml();
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

void testCbor() {
  testEncoding(dogs.cborSerializer, ModelA.variant0, ModelA.variant1);
  testEncoding(dogs.cborSerializer, ModelB.variant0, ModelB.variant1);
  testEncoding(dogs.cborSerializer, ModelC.variant0, ModelC.variant1);
  testEncoding(dogs.cborSerializer, ModelD.variant0, ModelD.variant1);
  testEncoding(dogs.cborSerializer, ModelE.variant0, ModelE.variant1);
  testEncoding(dogs.cborSerializer, ModelF.variant0, ModelF.variant1);
  testEncoding(dogs.cborSerializer, Note.variant0, Note.variant1);
}

void testYaml() {
  testEncoding(dogs.yamlSerializer, ModelA.variant0, ModelA.variant1);
  testEncoding(dogs.yamlSerializer, ModelB.variant0, ModelB.variant1);
  testEncoding(dogs.yamlSerializer, ModelC.variant0, ModelC.variant1);
  testEncoding(dogs.yamlSerializer, ModelD.variant0, ModelD.variant1);
  testEncoding(dogs.yamlSerializer, ModelE.variant0, ModelE.variant1);
  testEncoding(dogs.yamlSerializer, ModelF.variant0, ModelF.variant1);
  testEncoding(dogs.yamlSerializer, Note.variant0, Note.variant1);
}

void testToml() {
  testEncoding(dogs.tomlSerializer, ModelA.variant0, ModelA.variant1);
  testEncoding(dogs.tomlSerializer, ModelB.variant0, ModelB.variant1);
  testEncoding(dogs.tomlSerializer, ModelC.variant0, ModelC.variant1);
  testEncoding(dogs.tomlSerializer, ModelD.variant0, ModelD.variant1);
  testEncoding(dogs.tomlSerializer, ModelE.variant0, ModelE.variant1);
  testEncoding(dogs.tomlSerializer, ModelF.variant0, ModelF.variant1);
  testEncoding(dogs.tomlSerializer, Note.variant0, Note.variant1);
}


void testEncoding<T>(DogSerializer serializer, T Function() a, T Function() b) {
  var va0 = a();
  var va1 = a();
  var vb0 = b();
  var vb1 = b();
  var ga = dogs.convertObjectToGraph(va0, T);
  var gb = dogs.convertObjectToGraph(vb0, T);
  var ea = serializer.serialize(ga);
  var eb = serializer.serialize(gb);
  var gda = serializer.deserialize(ea);
  var gdb = serializer.deserialize(eb);
  var da = dogs.convertObjectFromGraph(gda, T);
  var db = dogs.convertObjectFromGraph(gdb, T);
  if (va1 != da || va0 != da) throw Exception("Non-pure serialization");
  if (vb1 != db || vb0 != db) throw Exception("Non-pure serialization");
  if (ea == eb) throw Exception("Wrong equality");
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