import 'dart:math';

import 'package:dogs_cbor/dogs_cbor.dart';
import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_toml/dogs_toml.dart';
import 'package:dogs_yaml/dogs_yaml.dart';
import 'package:logging/logging.dart';
import 'package:smoke_test_0/dogs.g.dart';
import 'package:smoke_test_0/validation.dart';
import 'dart:io';

import 'conformities.dart';
import 'models.dart';

Future main() async {
  try {
    await initialiseDogs();
    testModels();
    print("-- Model test passed");
    testOperations();
    print("-- Operations test passed");
    testConformities();
    print("-- Conformity test passed");
    testValidators();
    print("-- Validator test passed");
    testTrees();
    print("-- TypeTree test passed");
    testCbor();
    print("-- Cbor test passed");
    testYaml();
    print("-- Yaml test passed");
    testToml();
    print("-- Toml test passed");
    testProjection();
    print("-- Projection test passed");
    print("All tests passed");
  } catch(ex,st) {
    print("$ex: $st");
    exit(1);
  }
}

void testProjection() {
  var result = dogs.project<Note>(Note.variant0(), {
    "tags": {"new"},
  }, [{
    "content": "AABBCC"
  }]);
  if (result.title != Note.variant0().title) throw Exception("Object to FieldMap doesn't work");
  if (result.tags.first != "new") throw Exception("Properties don't work");
  if (result.content != "AABBCC") throw Exception("Iterables don't work");
}

void testOperations() {
  testOperation(ModelA, ModelA.variant0(), deepEquality.equals);
  testOperation(ModelA, ModelA.variant1(), deepEquality.equals);
  testOperation(ModelB, ModelB.variant0(), deepEquality.equals);
  testOperation(ModelB, ModelB.variant1(), deepEquality.equals);
  testOperation(ModelC, ModelC.variant0(), deepEquality.equals);
  testOperation(ModelC, ModelC.variant1(), deepEquality.equals);
  testOperation(ModelD, ModelD.variant0(), deepEquality.equals);
  testOperation(ModelD, ModelD.variant1(), deepEquality.equals);
  testOperation(ModelE, ModelE.variant0(), deepEquality.equals);
  testOperation(ModelE, ModelE.variant1(), deepEquality.equals);
  testOperation(ModelF, ModelF.variant0(), deepEquality.equals);
  testOperation(ModelF, ModelF.variant1(), deepEquality.equals);
  testOperation(ModelG, ModelG.variant0(), deepEquality.equals);
  testOperation(ModelG, ModelG.variant1(), deepEquality.equals);
}

void testTrees() {
  // Iterable
  testTypeTree(QualifiedTypeTree.iterable<ModelA>(), [ModelA.variant0(), ModelA.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.iterable<ModelB>(), [ModelB.variant0(), ModelB.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.iterable<ModelC>(), [ModelC.variant0(), ModelC.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.iterable<ModelD>(), [ModelD.variant0(), ModelD.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.iterable<ModelE>(), [ModelE.variant0(), ModelE.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.iterable<ModelF>(), [ModelF.variant0(), ModelF.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.iterable<ModelG>(), [ModelG.variant0(), ModelG.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.iterable<dynamic>(), [ModelA.variant0(), ModelA.variant1()], deepEquality.equals);
  // Lists
  testTypeTree(QualifiedTypeTree.list<ModelA>(), [ModelA.variant0(), ModelA.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.list<ModelB>(), [ModelB.variant0(), ModelB.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.list<ModelC>(), [ModelC.variant0(), ModelC.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.list<ModelD>(), [ModelD.variant0(), ModelD.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.list<ModelE>(), [ModelE.variant0(), ModelE.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.list<ModelF>(), [ModelF.variant0(), ModelF.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.list<ModelG>(), [ModelG.variant0(), ModelG.variant1()], deepEquality.equals);
  testTypeTree(QualifiedTypeTree.list<dynamic>(), [ModelA.variant0(), ModelA.variant1()], deepEquality.equals);
  // Sets
  testTypeTree(QualifiedTypeTree.set<ModelA>(), {ModelA.variant0(), ModelA.variant1()}, deepEquality.equals);
  testTypeTree(QualifiedTypeTree.set<ModelB>(), {ModelB.variant0(), ModelB.variant1()}, deepEquality.equals);
  testTypeTree(QualifiedTypeTree.set<ModelC>(), {ModelC.variant0(), ModelC.variant1()}, deepEquality.equals);
  testTypeTree(QualifiedTypeTree.set<ModelD>(), {ModelD.variant0(), ModelD.variant1()}, deepEquality.equals);
  testTypeTree(QualifiedTypeTree.set<ModelE>(), {ModelE.variant0(), ModelE.variant1()}, deepEquality.equals);
  testTypeTree(QualifiedTypeTree.set<ModelF>(), {ModelF.variant0(), ModelF.variant1()}, deepEquality.equals);
  testTypeTree(QualifiedTypeTree.set<ModelG>(), {ModelG.variant0(), ModelG.variant1()}, deepEquality.equals);
  testTypeTree(QualifiedTypeTree.set<dynamic>(), {ModelA.variant0(), ModelA.variant1()}, deepEquality.equals);

  testTypeTree(QualifiedTypeTree.map<String, int>(), {"Hello": 12, "value": 35}, deepEquality.equals);
  testTypeTree(
      QualifiedTypeTreeN<Map<dynamic, List<dynamic>>, Map>([
        QualifiedTypeTree.terminal<dynamic>(),
        QualifiedTypeTree.list<dynamic>(),
      ]),
      {
        ModelA.variant0(): [ModelB.variant0()],
        ModelA.variant1(): [ModelB.variant1()],
      },
      deepEquality.equals);
  testTypeTree(
      QualifiedTypeTree.map<ModelA, ModelB>(),
      {
        ModelA.variant0(): ModelB.variant0(),
        ModelA.variant1(): ModelB.variant1(),
      },
      deepEquality.equals);
  testTypeTree(
      QualifiedTypeTree.map<ModelC, ModelD>(),
      {
        ModelC.variant0(): ModelD.variant0(),
        ModelC.variant1(): ModelD.variant1(),
      },
      deepEquality.equals);
  testTypeTree(
      QualifiedTypeTree.map<ModelE, ModelF>(),
      {
        ModelE.variant0(): ModelF.variant0(),
        ModelE.variant1(): ModelF.variant1(),
      },
      deepEquality.equals);
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
  testSingleModel<ModelA>(ModelA.variant0, ModelA.variant1);
  testSingleModel<ModelB>(ModelB.variant0, ModelB.variant1);
  testSingleModel<ModelC>(ModelC.variant0, ModelC.variant1);
  testSingleModel<ModelD>(ModelD.variant0, ModelD.variant1);
  testSingleModel<ModelE>(ModelE.variant0, ModelE.variant1);
  testSingleModel<ModelF>(ModelF.variant0, ModelF.variant1);
  testSingleModel<ModelG>(ModelG.variant0, ModelG.variant1);
  testSingleModel<Note>(Note.variant0, Note.variant1);
  testSingleModel<DeepPolymorphic>(DeepPolymorphic.variant0, DeepPolymorphic.variant1);
}

void testConformities() {
  testSimple(ConformityBasic.variant0, ConformityBasic.variant1);
  testSimple(ConformityData.variant0, ConformityData.variant1);
  testSimple(ConformityDataArg.variant0, ConformityDataArg.variant1);
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

void testTypeTree(TypeTree tree, dynamic initialValue, bool Function(dynamic a, dynamic b) comparator) {
  var converter = dogs.getTreeConverter(tree);
  GraphSerializerMode graphMode = converter.resolveOperationMode(GraphSerializerMode)! as GraphSerializerMode;
  NativeSerializerMode nativeMode = converter.resolveOperationMode(NativeSerializerMode)! as NativeSerializerMode;
  graphMode.initialise(dogs);
  nativeMode.initialise(dogs);
  var resultGraph = graphMode.serialize(initialValue, dogs);
  var resultNative = nativeMode.serialize(initialValue, dogs);
  //print(resultNative);
  //print(resultGraph.coerceString());
  var reGraph = graphMode.deserialize(resultGraph, dogs);
  var reNative = nativeMode.deserialize(resultNative, dogs);
  if (!comparator(reGraph, initialValue)) throw Exception("Graph result not equal");
  if (!comparator(reNative, initialValue)) throw Exception("Native result not equal");
}

void testOperation(Type type, dynamic initialValue, bool Function(dynamic a, dynamic b) comparator) {
  var nativeOperation = dogs.modeRegistry.nativeSerialization.forType(type, dogs);
  var graphOperation = dogs.modeRegistry.graphSerialization.forType(type, dogs);
  nativeOperation.initialise(dogs);
  graphOperation.initialise(dogs);
  var resultGraph = graphOperation.serialize(initialValue, dogs);
  var resultNative = nativeOperation.serialize(initialValue, dogs);
  //print(resultNative);
  //print(resultGraph.coerceString());
  var reGraph = graphOperation.deserialize(resultGraph, dogs);
  var reNative = nativeOperation.deserialize(resultNative, dogs);
  if (!comparator(reGraph, initialValue)) throw Exception("Graph result not equal: $reGraph != $initialValue");
  if (!comparator(reNative, initialValue)) throw Exception("Native result not equal: $reNative != $initialValue");
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
  if (va1 != da || va0 != da) throw Exception("Non-pure serialization.md");
  if (vb1 != db || vb0 != db) throw Exception("Non-pure serialization.md");
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
  //print(ea);
  //print(eb);
  if (va1 != da || va0 != da) throw Exception("Non-pure serialization.md: $T");
  if (vb1 != db || vb0 != db) throw Exception("Non-pure serialization.md: $T");
  if (ea == eb) throw Exception("Wrong equality: $T");
}
