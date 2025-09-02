import 'package:dogs_flutter/dogs_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  configureDogs(plugins: [DogsFlutterPlugin()]);

  group("Flutter Converter Tests", () {
    test("Serialize Offset", () {
      final offset = Offset(10, 20);
      final encoded = dogs.toJson<Offset>(offset);
      final decoded = dogs.fromJson<Offset>(encoded);
      expect(decoded, offset);
      dogs.describe<Offset>();
    });

    test("Serialize Size", () {
      final size = Size(100, 200);
      final encoded = dogs.toJson<Size>(size);
      final decoded = dogs.fromJson<Size>(encoded);
      expect(decoded, size);
      dogs.describe<Size>();
    });

    test("Serialize Rect", () {
      final rect = Rect.fromLTWH(10, 20, 30, 40);
      final encoded = dogs.toJson<Rect>(rect);
      final decoded = dogs.fromJson<Rect>(encoded);
      expect(decoded, rect);
      dogs.describe<Rect>();

      final authored = [0, 10, 20, 25.5];
      final decodedAuthored = dogs.fromNative<Rect>(authored);
      expect(decodedAuthored, Rect.fromLTRB(0, 10, 20, 25.5));
    });

    test("Serialize EdgeInsets", () {
      final edgeInsets = EdgeInsets.only(left: 10, top: 20, right: 30, bottom: 40);
      final encoded = dogs.toJson<EdgeInsets>(edgeInsets);
      final decoded = dogs.fromJson<EdgeInsets>(encoded);
      expect(decoded, edgeInsets);
      dogs.describe<EdgeInsets>();

      final authored = [10, 20, 30, 40.5];
      final decodedAuthored = dogs.fromNative<EdgeInsets>(authored);
      expect(decodedAuthored, EdgeInsets.fromLTRB(10, 20, 30, 40.5));
    });

    test("Serialize RRect", () {
      final rrect = RRect.fromLTRBR(10, 20, 30, 40, Radius.circular(5));
      final encoded = dogs.toJson<RRect>(rrect);
      final decoded = dogs.fromJson<RRect>(encoded);
      expect(decoded, rrect);
      dogs.describe<RRect>();
    });

    test("Serialize Radius", () {
      final radius = Radius.circular(10);
      final encoded = dogs.toJson<Radius>(radius);
      final decoded = dogs.fromJson<Radius>(encoded);
      expect(decoded, radius);
      dogs.describe<Radius>();
    });

    test("Serialize BorderRadius", () {
      final borderRadius = BorderRadius.circular(10);
      final encoded = dogs.toJson<BorderRadius>(borderRadius);
      final decoded = dogs.fromJson<BorderRadius>(encoded);
      expect(decoded, borderRadius);
      dogs.describe<BorderRadius>();
    });

    test("Serialize BoxConstraints", () {
      final constraints = BoxConstraints(
        minWidth: 10,
        maxWidth: 100,
        minHeight: 20,
        maxHeight: 200,
      );
      final encoded = dogs.toJson<BoxConstraints>(constraints);
      final decoded = dogs.fromJson<BoxConstraints>(encoded);
      expect(decoded, constraints);
      dogs.describe<BoxConstraints>();
    });

    test("Serialize Alignment", () {
      var alignment = Alignment(0.5, -0.5);
      final encoded = dogs.toJson<Alignment>(alignment);
      final decoded = dogs.fromJson<Alignment>(encoded);
      expect(decoded, alignment);
      dogs.describe<Alignment>();
    });

    test("Serialize Matrix4", () {
      final matrix = Matrix4.identity();
      matrix.translateByDouble(10, 20, 30, 0);
      matrix.rotateZ(0.5);
      final encoded = dogs.toJson<Matrix4>(matrix);
      final decoded = dogs.fromJson<Matrix4>(encoded);
      expect(decoded, matrix);
      dogs.describe<Matrix4>();
    });

    test("Serialize Color", () {
      final color = Color(0xFF123456);
      final encoded = dogs.toJson<Color>(color);
      final decoded = dogs.fromJson<Color>(encoded);
      expect(decoded, color);
      dogs.describe<Color>();
    });

    test("Serialize Logical Key", () {
      final key = LogicalKeyboardKey.keyA;
      final encoded = dogs.toJson<LogicalKeyboardKey>(key);
      final decoded = dogs.fromJson<LogicalKeyboardKey>(encoded);
      expect(decoded, key);
      dogs.describe<LogicalKeyboardKey>();
    });

    test("Serialize Single Activator", () {
      var activator = SingleActivator(LogicalKeyboardKey.keyA, control: true, shift: true);
      final encoded = dogs.toJson<SingleActivator>(activator);
      final decoded = dogs.fromJson<SingleActivator>(encoded);
      expect(decoded.trigger, activator.trigger);
      expect(decoded.control, activator.control);
      expect(decoded.shift, activator.shift);
      expect(decoded.alt, activator.alt);
      expect(decoded.meta, activator.meta);
      expect(decoded.includeRepeats, activator.includeRepeats);
      expect(decoded.numLock, activator.numLock);
      dogs.describe<SingleActivator>();
    });
  });
}
