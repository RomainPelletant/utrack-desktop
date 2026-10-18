import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores one YouTrack permanent token per server in the OS keychain.
class TokenStore {
  // The legacy macOS keychain needs no keychain-access-groups entitlement,
  // and therefore no provisioning profile.
  static const _storage = FlutterSecureStorage(
    mOptions: MacOsOptions(usesDataProtectionKeychain: false),
  );

  static String _key(String serverUrl) => 'token:$serverUrl';

  /// Returns null when no token is stored. Throws a [PlatformException] when
  /// the keychain cannot be read: no Secret Service on Linux, or on macOS an
  /// item written by a differently signed build of the app.
  static Future<String?> load(String serverUrl) =>
      _storage.read(key: _key(serverUrl));

  /// Throws a [PlatformException] if the keychain is unavailable.
  static Future<void> save(String serverUrl, String? token) {
    if (token == null || token.isEmpty) {
      return _storage.delete(key: _key(serverUrl));
    }
    return _storage.write(key: _key(serverUrl), value: token);
  }
}
