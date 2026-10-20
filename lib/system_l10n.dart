// SPDX-FileCopyrightText: 2026 Romain Pelletant
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/widgets.dart';

import 'l10n/app_localizations.dart';

/// Supported locales with English first: Flutter falls back to the first
/// entry when the system language is not supported, and the generated list is
/// alphabetical (it would start with Arabic).
final List<Locale> appSupportedLocales = [
  const Locale('en'),
  ...AppLocalizations.supportedLocales.where((l) => l != const Locale('en')),
];

/// Localized strings for the system language, for code that runs outside any
/// widget (notifications, native menus). Resolves the locale the same way
/// MaterialApp does.
AppLocalizations systemLocalizations() {
  final locale = basicLocaleListResolution(
    WidgetsBinding.instance.platformDispatcher.locales,
    appSupportedLocales,
  );
  return lookupAppLocalizations(locale);
}
