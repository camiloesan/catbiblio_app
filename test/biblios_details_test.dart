import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:catbiblio_app/models/biblios_details.dart';
import 'package:catbiblio_app/services/biblios_details.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    await dotenv.load();
  });

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

    test('getBibliosDetails handles invalid biblionumber gracefully', () async {
      const invalidBiblionumber = -1;
      BibliosDetails details = await BibliosDetailsService.getBibliosDetails(
        invalidBiblionumber,
      );

      // Empty details expected for invalid biblionumber
      debugPrint('Fetched biblios details for invalid biblionumber: $details');

      expect(details, isA<BibliosDetails>());
      expect(details.title.isEmpty, isTrue);
      expect(details.author.isEmpty, isTrue);
    });

    test(
      'getBibliosDetails handles not found biblionumber gracefully',
      () async {
        const invalidBiblionumber = 99999999;
        BibliosDetails details = await BibliosDetailsService.getBibliosDetails(
          invalidBiblionumber,
        );

        // Empty details expected for not found biblionumber
        debugPrint(
          'Fetched biblios details for not found biblionumber: $details',
        );

        expect(details, isA<BibliosDetails>());
        expect(details.title.isEmpty, isTrue);
        expect(details.author.isEmpty, isTrue);
      },
    );

    test(
      'getBibliosMarcPlainText returns MARC plain text for a valid biblionumber',
      () async {
        const testBiblionumber = 383061;
        String? marcPlainText =
            await BibliosDetailsService.getBibliosMarcPlainText(
              testBiblionumber,
            );

        debugPrint('Fetched MARC plain text: $marcPlainText');

        expect(marcPlainText, isA<String>());
        expect(marcPlainText!.isNotEmpty, isTrue);
        expect(marcPlainText.contains('LDR'), isTrue); // MARC Leader
        expect(marcPlainText.contains('999'), isTrue); // Control Number
      },
    );

    test(
      'getBibliosMarcPlainText handles invalid biblionumber gracefully',
      () async {
        const invalidBiblionumber = -1; // Assuming negative numbers are invalid
        String? marcPlainText =
            await BibliosDetailsService.getBibliosMarcPlainText(
              invalidBiblionumber,
            );

        debugPrint(
          'Fetched MARC plain text for invalid biblionumber: $marcPlainText',
        );

        expect(marcPlainText, isNull);
      },
    );

    test(
      'getBibliosMarcPlainText handles not found biblionumber gracefully',
      () async {
        const invalidBiblionumber = 99999999; // Assuming this number is not
        String? marcPlainText =
            await BibliosDetailsService.getBibliosMarcPlainText(
              invalidBiblionumber,
            );

        // MARC plain text is expected to be null for not found biblionumber
        debugPrint(
          'Fetched MARC plain text for not found biblionumber: $marcPlainText',
        );

        expect(marcPlainText, isNull);
      },
    );
  });
}
