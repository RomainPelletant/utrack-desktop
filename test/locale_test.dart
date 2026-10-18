import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_desktop/system_l10n.dart';

Locale resolve(List<Locale> system) =>
    basicLocaleListResolution(system, appSupportedLocales);

void main() {
  test('falls back to English for unsupported languages', () {
    expect(resolve([const Locale('sw')]), const Locale('en'));
    expect(resolve([]), const Locale('en'));
  });

  test('picks regional and script variants', () {
    expect(resolve([const Locale('fr', 'CA')]), const Locale('fr'));
    expect(resolve([const Locale('pt', 'PT')]), const Locale('pt', 'PT'));
    expect(
      resolve([
        const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hant',
          countryCode: 'TW',
        ),
      ]),
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    );
  });

  test('uses the first supported preferred language', () {
    expect(
      resolve([const Locale('sw'), const Locale('de')]),
      const Locale('de'),
    );
  });
}
