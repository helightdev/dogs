/// Support for doing something awesome.
///
/// More dartdocs go here.
library dogs_cbor;

import 'package:cbor/cbor.dart';
import 'package:dogs_core/dogs_core.dart';

class DogCborSerializer extends DogSerializer {
  @override
  DogGraphValue deserialize(value) {
    var decoded = cborDecode(value);
    return CborGraphVisitor.visitCbor(decoded);
  }

  @override
  dynamic serialize(DogGraphValue value) {
    var visitor = DogCborVisitor();
    var cborGraph = visitor.visit(value);
    return cborEncode(cborGraph);
  }
}

class DogCborVisitor extends DogVisitor<CborValue> {
  @override
  CborValue visitMap(DogMap m) => CborMap(
      m.value.map((key, value) => MapEntry(visit(key), (visit(value)))));
  @override
  CborValue visitList(DogList l) =>
      CborList(l.value.map((e) => visit(e)).toList());
  @override
  CborValue visitString(DogString s) => CborString(s.value);
  @override
  CborValue visitInt(DogInt i) => CborSmallInt(i.value);
  @override
  CborValue visitDouble(DogDouble d) => CborFloat(d.value);
  @override
  CborValue visitBool(DogBool b) => CborBool(b.value);
  @override
  CborValue visitNull(DogNull n) => CborNull();
}

class CborGraphVisitor {
  static DogGraphValue visitCbor(CborValue cbor) {
    if (cbor is CborString) {
      return DogString((cbor).toString());
    } else if (cbor is CborSmallInt) {
      return DogInt((cbor).value);
    } else if (cbor is CborFloat) {
      return DogDouble((cbor).value);
    } else if (cbor is CborBool) {
      return DogBool((cbor).value);
    } else if (cbor is CborNull) {
      return DogNull();
    } else if (cbor is CborList) {
      return DogList((cbor).map((e) => visitCbor(e)).toList());
    } else if (cbor is CborMap) {
      return DogMap((cbor)
          .map((key, value) => MapEntry(visitCbor(key), visitCbor(value))));
    }
    throw Exception("Unsupported Cbor value: ${cbor.runtimeType}");
  }
}

extension DogCborExtension on DogEngine {
  static final _cborSerializer = DogCborSerializer();

  DogCborSerializer get cborSerializer => _cborSerializer;

  /// Encodes this [value] to json, using the [DogConverter] associated with [T].
  List<int> cborEncode<T>(T value) {
    var graph = convertObjectToGraph(value, T);
    return _cborSerializer.serialize(graph);
  }

  /// Decodes this [encoded] json to an [T] instance,
  /// using the [DogConverter] associated with [T].
  T cborDecode<T>(List<int> encoded) {
    var graph = _cborSerializer.deserialize(encoded);
    return convertObjectFromGraph(graph, T);
  }
}
