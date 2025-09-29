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

    // TODO: Add more test cases
  });
}
