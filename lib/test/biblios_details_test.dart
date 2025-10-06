import 'package:test/test.dart';
import 'package:flutter/foundation.dart';
import 'package:catbiblio_app/models/biblios_details.dart';
import 'package:catbiblio_app/services/rest/biblios_details.dart';

void main() {
  group('BibliosDetailsService requests', () {
    test(
      'getBibliosDetails returns biblios details for a valid biblionumber',
      () async {
        //const testBiblionumber = 383385;
        const testBiblionumber = 383061;
        BibliosDetails details = await BibliosDetailsService.getBibliosDetails(
          testBiblionumber,
        );

        debugPrint('Fetched biblios details: $details');

        expect(details, isA<BibliosDetails>());
        expect(details.title.isNotEmpty, isTrue);
        expect(details.author.isNotEmpty, isTrue);
      },
    );

    // TODO: test handling not found biblionumber
  });
}
