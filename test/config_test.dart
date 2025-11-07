import 'package:catbiblio_app/models/config.dart';
import 'package:catbiblio_app/services/config.dart';
import 'package:test/test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    await dotenv.load();
  });

  group('ConfigService requests', () {
    test('getConfig returns if selection section is enabled', () async {
      final config = await ConfigService.getAppConfig();

      expect(config, isA<Config>());
    });
    
  });
}
