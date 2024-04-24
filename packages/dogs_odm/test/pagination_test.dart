import 'package:dogs_core/dogs_core.dart';
import 'package:dogs_odm/dogs_odm.dart';
import 'package:dogs_odm/memory/database.dart';
import 'package:dogs_odm/memory/odm.dart';
import 'package:dogs_odm/memory/repository.dart';
import 'package:dogs_odm/query_dsl.dart';
import 'package:test/test.dart';

import 'person_test.dart';


void main() {
  var engine = DogEngine();
  engine.setSingleton();
  engine.registerAutomatic(DogStructureConverterImpl<Person>(personStructure));
  personMatrixGroup((systemFactory, repositoryFactory) {
    group("Basic Tests", () {
      late OdmSystem system;
      late dynamic personRepository;
      setUp(() {
        system = systemFactory();
        personRepository = repositoryFactory();
      });

      test('Pagination', () async {
        await personRepository.saveAll([mary, john, henry]);
        var page = await personRepository.findPaginated(PageRequest.of(0, 2));
        expect(page.meta.totalElements, 3);
        expect(page.meta.totalPages, 2);
        expect(page.meta.number, 0);
        expect(page.meta.size, 2);
        expect(page.content, containsAll([mary, john]));

        var restrictedPage = await personRepository.findPaginatedByQuery(
            gte("age", 30),
            PageRequest.of(0, 1),
            Sorted.byField("age")
        );
        expect(restrictedPage.meta.totalElements, 2);
        expect(restrictedPage.meta.totalPages, 2);
        expect(restrictedPage.meta.number, 0);
        expect(restrictedPage.meta.size, 1);
        expect(restrictedPage.content, containsAllInOrder([john]));
      });
    });
  });
}
