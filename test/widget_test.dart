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
}
