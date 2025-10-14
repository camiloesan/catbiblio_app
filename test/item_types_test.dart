import 'package:test/test.dart';
import 'package:flutter/foundation.dart';
import 'package:catbiblio_app/models/item_type.dart';
import 'package:catbiblio_app/services/item_types.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    await dotenv.load();
  });

  group('ItemTypesService requests', () {
    test('getItemTypes returns a list of item types', () async {
      final items = await ItemTypesService.getItemTypes();

      debugPrint('Fetched ${items.length} item types');
      debugPrint(
        'First item: ${items.isNotEmpty ? items.first : 'No items found'}',
      );
      debugPrint(
        'Last item: ${items.isNotEmpty ? items.last : 'No items found'}',
      );

      expect(items, isA<List<ItemType>>());
      expect(items.isNotEmpty, isTrue);
      expect(items.length, greaterThan(0));
    });
  });
}
