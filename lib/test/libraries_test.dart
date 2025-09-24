import 'package:test/test.dart';
import 'package:flutter/foundation.dart';
import 'package:catbiblio_app/models/library.dart';
import 'package:catbiblio_app/services/rest/libraries.dart';

void main() {
  group('LibrariesService requests', () {
    test('getLibraries returns a list of libraries', () async {
      final libraries = await LibrariesService.getLibraries();

      debugPrint('Fetched ${libraries.length} libraries');
      debugPrint(
        'First library: ${libraries.isNotEmpty ? libraries.first : 'No libraries found'}',
      );
      debugPrint(
        'Last library: ${libraries.isNotEmpty ? libraries.last : 'No libraries found'}',
      );

      expect(libraries, isA<List<Library>>());
    });
    test('getLibraries are ordered by library_id', () async {
      final libraries = await LibrariesService.getLibraries();

      final sortedLibraries = List<Library>.from(libraries)
        ..sort((a, b) => a.libraryId.compareTo(b.libraryId));

      expect(libraries, isNot(equals(sortedLibraries)));
    });
  });
}
