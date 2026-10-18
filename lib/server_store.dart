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
}
