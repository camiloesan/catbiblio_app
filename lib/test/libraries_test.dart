import 'package:test/test.dart';
import 'package:flutter/foundation.dart';
import 'package:catbiblio_app/models/library.dart';
import 'package:catbiblio_app/models/region.dart';
import 'package:catbiblio_app/services/libraries.dart';

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
    test('getLibraries at least one library for each region', () async {
      final libraries = await LibrariesService.getLibraries();

      final regionsFound = <String>{};
      for (var library in libraries) {
        regionsFound.add(library.region);
      }

      debugPrint('Regions found: $regionsFound');

      for (var region in regions.values) {
        expect(
          regionsFound.contains(region),
          isTrue,
          reason: 'No library found for region: $region',
        );
      }
    });

    test('getLibraries returns libraries with valid regions', () async {
      final libraries = await LibrariesService.getLibraries();

      debugPrint('Found regions in libraries:');

      for (var library in libraries) {
        debugPrint(' - ${library.name}: ${library.region}');
        expect(
          regions.containsValue(library.region),
          isTrue,
          reason:
              'Library ${library.name} has an invalid region: ${library.region}',
        );
      }
    });
  });
}
