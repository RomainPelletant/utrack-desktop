// SPDX-FileCopyrightText: 2026 Romain Pelletant
// SPDX-License-Identifier: Apache-2.0

import 'package:shared_preferences/shared_preferences.dart';

/// Persists the YouTrack server URL between launches.
class ServerStore {
  static const _key = 'youtrack_server_url';

  static Future<String?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> save(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, url);
  }

  /// Turns user input such as `youtrack.example.com/` into
  /// `https://youtrack.example.com`. Returns null if the input is not a
  /// usable http(s) URL.
  static String? normalize(String input) {
    var text = input.trim();
    if (text.isEmpty) return null;
    if (!text.contains('://')) text = 'https://$text';

    final uri = Uri.tryParse(text);
    if (uri == null || uri.host.isEmpty) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;

    var result = uri.replace(query: '', fragment: '').toString();
    result = result.replaceAll(RegExp(r'[?#]+$'), '');
    while (result.endsWith('/')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }

  /// Whether [url] is a page of the server at [serverUrl]: same scheme, host
  /// and port, no user info, and a path under the server's on a `/`
  /// boundary. A plain prefix check would accept look-alike hosts
  /// (`https://yt.example.com.evil.net`, `https://yt.example.com@evil.net`),
  /// and URLs come from other processes (notification clicks, macOS
  /// distributed notifications): the window has no address bar to tell them
  /// apart.
  static bool isOnServer(String url, String serverUrl) {
    final uri = Uri.tryParse(url);
    final server = Uri.tryParse(serverUrl);
    if (uri == null || server == null || !uri.hasScheme) return false;
    if (uri.scheme != server.scheme ||
        uri.host.isEmpty ||
        uri.host != server.host ||
        uri.port != server.port ||
        uri.userInfo.isNotEmpty) {
      return false;
    }
    final base = server.path.endsWith('/')
        ? server.path.substring(0, server.path.length - 1)
        : server.path;
    return base.isEmpty || uri.path == base || uri.path.startsWith('$base/');
  }
}
