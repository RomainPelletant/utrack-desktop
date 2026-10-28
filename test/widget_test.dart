// SPDX-FileCopyrightText: 2026 Romain Pelletant
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter_test/flutter_test.dart';
import 'package:utrack_desktop/server_store.dart';

void main() {
  group('ServerStore.normalize', () {
    test('adds https and strips trailing slashes', () {
      expect(
        ServerStore.normalize(' foo.youtrack.cloud/ '),
        'https://foo.youtrack.cloud',
      );
    });

    test('keeps explicit scheme, port and path', () {
      expect(
        ServerStore.normalize('http://intranet:8080/youtrack/'),
        'http://intranet:8080/youtrack',
      );
    });

    test('drops query and fragment', () {
      expect(
        ServerStore.normalize('https://yt.example.com/?a=1#x'),
        'https://yt.example.com',
      );
    });

    test('rejects invalid input', () {
      expect(ServerStore.normalize(''), isNull);
      expect(ServerStore.normalize('ftp://yt.example.com'), isNull);
      expect(ServerStore.normalize('https://'), isNull);
    });
  });

  group('ServerStore.isOnServer', () {
    const server = 'https://yt.example.com';

    test('accepts pages of the server', () {
      expect(ServerStore.isOnServer('$server/issue/UTD-1', server), isTrue);
      expect(ServerStore.isOnServer(server, server), isTrue);
      expect(ServerStore.isOnServer('HTTPS://YT.example.com/', server), isTrue);
      expect(
        ServerStore.isOnServer('https://yt.example.com:443/x', server),
        isTrue,
      );
    });

    test('rejects look-alike hosts and user info', () {
      for (final url in [
        'https://yt.example.com.evil.net/login',
        'https://yt.example.com@evil.net/',
        'https://evil.net@yt.example.com/',
        'https://evil.net/?https://yt.example.com',
        'http://yt.example.com/',
        'https://yt.example.com:8443/',
        '//yt.example.com/',
        'javascript:alert(1)',
        'not a url',
      ]) {
        expect(ServerStore.isOnServer(url, server), isFalse, reason: url);
      }
    });

    test('checks the server path on a / boundary', () {
      const sub = 'http://intranet:8080/youtrack';
      expect(ServerStore.isOnServer('$sub/issue/X-1', sub), isTrue);
      expect(ServerStore.isOnServer(sub, sub), isTrue);
      expect(ServerStore.isOnServer('${sub}evil/', sub), isFalse);
      expect(ServerStore.isOnServer('http://intranet:8080/', sub), isFalse);
      expect(ServerStore.isOnServer('http://intranet/youtrack/', sub), isFalse);
    });
  });
}
