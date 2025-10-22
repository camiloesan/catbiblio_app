import 'package:catbiblio_app/models/config.dart';
import 'package:catbiblio_app/services/config.dart';
import 'package:test/test.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    await dotenv.load();
  });

  group('ConfigService requests', () {
    test('getConfig returns a list of enabled libraries', () async {
      final config = await ConfigService.getConfig();

      debugPrint('Fetched ${config.enabledLibrariesHome.length} libraries');

      expect(config, isA<Config>());
      expect(config.enabledLibrariesHome, isNotEmpty);
    });
    test('getConfig returns if selection section is enabled', () async {
      final config = await ConfigService.getConfig();

      expect(config, isA<Config>());
      expect(config.selectionsSectionState, isTrue);
    });
    
  });
}
