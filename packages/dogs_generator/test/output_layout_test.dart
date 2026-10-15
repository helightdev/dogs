import 'package:build/build.dart';
import 'package:dogs_generator/integrations.dart';
import 'package:dogs_generator/output_layout.dart';
import 'package:lyell_gen/lyell_gen.dart';
import 'package:test/test.dart';

void main() {
  group('output_directory', () {
    test('leaves the existing converter and reactor layout unchanged by default', () {
      const layout = DogsOutputLayout();
      final model = AssetId('app', 'lib/orders/order.dart');
      expect(layout.converterAsset(model).path, 'lib/orders/order.conv.g.dart');
      expect(expectedOutputs(dogsConverters(BuilderOptions.empty), model).single.path,
          'lib/orders/order.conv.g.dart');
      expect(
          expectedOutputs(dogsReactor(BuilderOptions.empty), AssetId('app', r'lib/$lib$'))
              .single
              .path,
          'lib/dogs.g.dart');
    });

    test('preserves source subdirectories and avoids equal-basename collisions', () {
      final options = BuilderOptions({'output_directory': 'generated/models'});
      final layout = DogsOutputLayout.fromOptions(options);
      final left = AssetId('app', 'lib/city/model.dart');
      final right = AssetId('app', 'lib/order/model.dart');
      expect(layout.converterAsset(left).path, 'lib/generated/models/city/model.conv.g.dart');
      expect(layout.converterAsset(right).path, 'lib/generated/models/order/model.conv.g.dart');
      expect(expectedOutputs(dogsConverters(options), left).single, layout.converterAsset(left));
      expect(expectedOutputs(dogsConverters(options), right).single, layout.converterAsset(right));
      expect(expectedOutputs(dogsReactor(options), AssetId('app', r'lib/$lib$')).single.path,
          'lib/generated/models/dogs.g.dart');
    });

    test('keeps cached bindings and custom-link descriptors beside their source assets', () {
      final options = BuilderOptions({'output_directory': 'generated'});
      final model = AssetId('app', 'lib/models/order.dart');
      expect(
          expectedOutputs(dogsBindings(options), model).single.path, 'lib/models/order.conv.dogs');
      expect(
          expectedOutputs(dogsLinking(options), model).single.path, 'lib/models/order.link.dogs');
    });

    test('rejects directories that escape lib or do not name a relative directory', () {
      for (final value in [
        '',
        '.',
        '..',
        '../generated',
        'generated/../other',
        '/tmp/generated',
        'generated/',
        'generated//models',
        r'generated\models',
        'C:/generated',
        1,
        true
      ]) {
        expect(() => DogsOutputLayout.fromOptions(BuilderOptions({'output_directory': value})),
            throwsArgumentError,
            reason: '$value');
      }
    });

    test('detects inconsistent binding and reactor settings without changing custom links', () {
      const layout = DogsOutputLayout(directory: 'generated');
      final relocated = SubjectDescriptor(
          uri: 'package:app/generated/order.conv.g.dart', meta: {'outputDirectory': 'generated'});
      final adjacent =
          SubjectDescriptor(uri: 'package:app/order.conv.g.dart', meta: {'outputDirectory': null});
      final linked = SubjectDescriptor(uri: 'package:app/custom.dart');
      expect(() => layout.validateDescriptor(relocated), returnsNormally);
      expect(() => layout.validateDescriptor(linked), returnsNormally);
      expect(() => layout.validateDescriptor(adjacent), throwsStateError);
      expect(() => const DogsOutputLayout().validateDescriptor(relocated), throwsStateError);
    });
  });
}
