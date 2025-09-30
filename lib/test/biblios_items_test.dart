import 'package:test/test.dart';
import 'package:flutter/foundation.dart';
import 'package:catbiblio_app/models/biblio_item.dart';
import 'package:catbiblio_app/services/rest/biblios_items.dart';

void main() {
  group('BibliosItemsService requests', () {
    test('getBiblioItems returns a list of biblio items', () async {
      const testBiblionumber = 383385;
      final items = await BibliosItemsService.getBiblioItems(testBiblionumber);

      debugPrint('Fetched ${items.length} biblio items');
      debugPrint(
        'First item: ${items.isNotEmpty ? items.first : 'No items found'}',
      );
      debugPrint(
        'Last item: ${items.isNotEmpty ? items.last : 'No items found'}',
      );

      expect(items, isA<List<BiblioItem>>());
      expect(items.isNotEmpty, isTrue);
      expect(items.length, greaterThan(0));
    });

    test(
      'getBiblioItems returns a list of biblio items for a not for loan item',
      () async {
        const testBiblionumber = 383061;
        final items = await BibliosItemsService.getBiblioItems(
          testBiblionumber,
        );

        debugPrint('Fetched ${items.length} biblio items');
        debugPrint(
          'First item: ${items.isNotEmpty ? items.first : 'No items found'}',
        );

        expect(items, isA<List<BiblioItem>>());
        expect(items.isNotEmpty, isTrue);
        expect(items.length, greaterThan(0));
      },
    );

    test('getBiblioItems handles invalid biblionumber', () async {
      const invalidBiblionumber = -1;
      final items = await BibliosItemsService.getBiblioItems(
        invalidBiblionumber,
      );

      debugPrint(
        'Fetched ${items.length} biblio items for invalid biblionumber',
      );

      expect(items, isA<List<BiblioItem>>());
      expect(items.isEmpty, isTrue);
    });

    test('getBiblioItems handles non-existent biblionumber', () async {
      const nonExistentBiblionumber = 999999999;
      final items = await BibliosItemsService.getBiblioItems(
        nonExistentBiblionumber,
      );

      debugPrint(
        'Fetched ${items.length} biblio items for non-existent biblionumber',
      );

      expect(items, isA<List<BiblioItem>>());
      expect(items.isEmpty, isTrue);
    });

    test('getBiblioItems handles string biblionumber', () async {
      const invalidBiblionumber = "383385";
      final items = await BibliosItemsService.getBiblioItems(
        int.tryParse(invalidBiblionumber) ?? -1,
      );
      debugPrint(
        'Fetched ${items.length} biblio items for string biblionumber',
      );

      expect(items, isA<List<BiblioItem>>());
      expect(items.isNotEmpty, isTrue);
      expect(items.length, greaterThan(0));
    });
  });
}
