import 'package:catbiblio_app/services/book_selections.dart';
import 'package:test/test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    await dotenv.load();
  });

  group('BookSelectionsService requests', () {
    test('getBookSelections returns a list of book selections', () async {
      final selections = await BookSelectionsService.getBookSelections();
      
      expect(true, selections.isNotEmpty);
    });
    
  });
}
