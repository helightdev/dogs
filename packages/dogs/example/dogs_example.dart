import 'package:dogs/dogs.dart';

void main() {
  var value = DogMap({
    DogString("hello"): DogString("world"),
    DogString("list"): DogList([DogString("a"), DogInt(1), DogDouble(2.0)]),
    DogString("nullable"): DogNull()
  });

  print(value.coerceString());
  print(value.coerceNative());
  print(DogJsonSerializer().serialize(value));
  print(DogJsonVisitor().visit(value));
}

class DogJsonVisitor extends DogVisitor<String> {
  @override
  String visitMap(DogMap m) {
    var inner = m.value.entries
        .map((e) => "${visit(e.key)}:${visit(e.value)}")
        .join(",");
    return "{$inner}";
  }

  @override
  String visitList(DogList l) {
    var inner = l.value.map((e) => visit(e)).join(",");
    return "[$inner]";
  }

  // This does ignore escapes, since this just an example and im way to lazy to
  // actually implement the full json specification
  @override
  String visitString(DogString s) {
    return "\"${s.value}\"";
  }

  @override
  String visitInt(DogInt i) => i.coerceString();
  @override
  String visitDouble(DogDouble d) => d.coerceString();
  @override
  String visitBool(DogBool b) => b.coerceString();
  @override
  String visitNull(DogNull n) => "null";
}
