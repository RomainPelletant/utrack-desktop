// SPDX-FileCopyrightText: 2026 Romain Pelletant
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_desktop/notifications/token_store.dart';

const _channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
const _server = 'https://yt.example.com';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  /// A keychain that stores values, or fails every call like libsecret
  /// without a Secret Service.
  void mockKeychain({required bool available}) {
    final values = <String, String>{};
    messenger.setMockMethodCallHandler(_channel, (call) async {
      if (!available) {
        throw PlatformException(code: 'Libsecret error', message: 'No D-Bus');
      }
      final args = call.arguments as Map;
      final key = args['key'] as String;
      switch (call.method) {
        case 'write':
          values[key] = args['value'] as String;
        case 'read':
          return values[key];
        case 'delete':
          values.remove(key);
      }
      return null;
    });
  }

  tearDown(() {
    messenger.setMockMethodCallHandler(_channel, null);
    TokenStore.reset();
  });

  test('stores tokens in the keychain', () async {
    mockKeychain(available: true);
    await TokenStore.save(_server, 'perm:abc');
    expect(await TokenStore.load(_server), 'perm:abc');
    expect(TokenStore.keychainUnavailable.value, isFalse);
  });

  test('without a keychain, keeps the token for the session', () async {
    mockKeychain(available: false);
    TokenStore.sessionFallback = true;

    await expectLater(
      TokenStore.load(_server),
      throwsA(isA<PlatformException>()),
    );
    expect(TokenStore.keychainUnavailable.value, isTrue);

    await TokenStore.save(_server, 'perm:abc');
    expect(await TokenStore.load(_server), 'perm:abc');

    await TokenStore.save(_server, null);
    await expectLater(
      TokenStore.load(_server),
      throwsA(isA<PlatformException>()),
    );
  });

  test('without the session fallback, keychain errors are thrown', () async {
    mockKeychain(available: false);
    TokenStore.sessionFallback = false;

    await expectLater(
      TokenStore.save(_server, 'perm:abc'),
      throwsA(isA<PlatformException>()),
    );
    expect(TokenStore.keychainUnavailable.value, isFalse);
  });
}
