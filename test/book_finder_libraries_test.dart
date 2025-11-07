import 'package:catbiblio_app/services/book_finder_libraries.dart';
import 'package:test/test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    await dotenv.load();
  });

  group('BookFinderLibraries requests', () {
    test('getBookFinderLibrariesSet returns a set of library codes', () async {
      final libraries = await BookFinderLibraries.getBookFinderLibrariesSet();
      print(libraries);

      expect(libraries, isA<Set<String>>());
    });
    
  });
}
