// SPDX-FileCopyrightText: 2026 Romain Pelletant
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores one YouTrack permanent token per server in the OS keychain.
///
/// On Linux without a Secret Service (no GNOME Keyring or KWallet, or a
/// locked keyring), tokens are kept in memory until UTD quits: never in a
/// file.
class TokenStore {
  // The legacy macOS keychain needs no keychain-access-groups entitlement,
  // and therefore no provisioning profile.
  static const _storage = FlutterSecureStorage(
    mOptions: MacOsOptions(usesDataProtectionKeychain: false),
  );

  /// Whether a keychain error falls back to [_sessionTokens].
  @visibleForTesting
  static bool sessionFallback = Platform.isLinux;

  /// Tokens saved while the keychain was unavailable.
  static final _sessionTokens = <String, String>{};

  /// True once the keychain failed and the session fallback is in use.
  static final keychainUnavailable = ValueNotifier(false);

  static String _key(String serverUrl) => 'token:$serverUrl';

  /// Returns null when no token is stored. Throws a [PlatformException] when
  /// the keychain cannot be read: no Secret Service on Linux, or on macOS an
  /// item written by a differently signed build of the app.
  static Future<String?> load(String serverUrl) async {
    final sessionToken = _sessionTokens[serverUrl];
    if (sessionToken != null) return sessionToken;
    try {
      return await _storage.read(key: _key(serverUrl));
    } on PlatformException {
      if (sessionFallback) keychainUnavailable.value = true;
      rethrow;
    }
  }

  /// Throws a [PlatformException] if the keychain is unavailable, unless the
  /// session fallback is in use.
  static Future<void> save(String serverUrl, String? token) async {
    _sessionTokens.remove(serverUrl);
    try {
      if (token == null || token.isEmpty) {
        await _storage.delete(key: _key(serverUrl));
      } else {
        await _storage.write(key: _key(serverUrl), value: token);
      }
      keychainUnavailable.value = false;
    } on PlatformException {
      if (!sessionFallback) rethrow;
      keychainUnavailable.value = true;
      if (token != null && token.isNotEmpty) {
        _sessionTokens[serverUrl] = token;
      }
    }
  }

  @visibleForTesting
  static void reset() {
    _sessionTokens.clear();
    keychainUnavailable.value = false;
    sessionFallback = Platform.isLinux;
  }
}
