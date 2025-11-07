import 'package:catbiblio_app/services/library_services.dart';
import 'package:test/test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    await dotenv.load();
  });

  group('LibraryServices requests', () {
    test('getLibraryCodeServicesMap returns a map of library codes to services', () async {
      final services = await LibraryServices.getLibraryCodeServicesMap();

      expect(services['USBI-X'], isA<List<LibraryService>>());
    });
    
  });
}