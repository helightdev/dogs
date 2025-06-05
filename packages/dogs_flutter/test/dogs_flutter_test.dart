import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dogs_flutter/dogs_flutter.dart';

void main() {
  configureDogs(plugins: [
    DogsFlutterPlugin()
  ]);

  group("Flutter Converter Tests", () {
    test("Serialize Offset", () {
      final offset = Offset(10, 20);
      final encoded = dogs.toJson<Offset>(offset);
      final decoded = dogs.fromJson<Offset>(encoded);
      expect(decoded, offset);
    });

    test("Serialize Size", () {
      final size = Size(100, 200);
      final encoded = dogs.toJson<Size>(size);
      final decoded = dogs.fromJson<Size>(encoded);
      expect(decoded, size);
    });

    test("Serialize Rect", () {
      final rect = Rect.fromLTWH(10, 20, 30, 40);
      final encoded = dogs.toJson<Rect>(rect);
      final decoded = dogs.fromJson<Rect>(encoded);
      expect(decoded, rect);
    });

    test("Serialize EdgeInsets", () {
      final edgeInsets = EdgeInsets.only(
        left: 10,
        top: 20,
        right: 30,
        bottom: 40,
      );
      final encoded = dogs.toJson<EdgeInsets>(edgeInsets);
      final decoded = dogs.fromJson<EdgeInsets>(encoded);
      expect(decoded, edgeInsets);
    });

    test("Serialize RRect", () {
      final rrect = RRect.fromLTRBR(10, 20, 30, 40, Radius.circular(5));
      final encoded = dogs.toJson<RRect>(rrect);
      final decoded = dogs.fromJson<RRect>(encoded);
      expect(decoded, rrect);
    });

    test("Serialize Radius", () {
      final radius = Radius.circular(10);
      final encoded = dogs.toJson<Radius>(radius);
      final decoded = dogs.fromJson<Radius>(encoded);
      expect(decoded, radius);
    });

    test("Serialize BorderRadius", () {
      final borderRadius = BorderRadius.circular(10);
      final encoded = dogs.toJson<BorderRadius>(borderRadius);
      final decoded = dogs.fromJson<BorderRadius>(encoded);
      expect(decoded, borderRadius);
    });

    test("Serialize Color", () {
      final color = Color(0xFF123456);
      final encoded = dogs.toJson<Color>(color);
      final decoded = dogs.fromJson<Color>(encoded);
      expect(decoded, color);
    });
  });
}
