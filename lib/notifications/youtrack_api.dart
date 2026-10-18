import 'dart:convert';

import 'package:http/http.dart' as http;

import 'http_client.dart';

/// Minimal YouTrack REST client for the notification center ("inbox").
///
/// `/api/inbox/*` is the API behind YouTrack's notification center. It is not
/// part of the documented public API but is the one used by the official
/// YouTrack Mobile app.
class YouTrackApi {
  YouTrackApi(this.serverUrl, this.token, {http.Client? client})
    : _client = client ?? createApiClient();

  final String serverUrl;
  final String token;
  final http.Client _client;

  static const _threadFields =
      'id,notified,'
      'subject(target(\$type,idReadable,summary,'
      'issue(\$type,idReadable,summary),article(\$type,idReadable,summary))),'
      'messages(id,timestamp,read,'
      'activities(\$type,author(fullName,login),comment(text),added(\$type,text)))';

  /// Full name of the token's owner. Throws [YouTrackApiException] if the
  /// token is rejected.
  Future<String> currentUserName() async {
    final json = await _get('/api/users/me', {
      'fields': 'fullName,login,guest',
    });
    final user = json as Map<String, dynamic>;
    // Instances with guest access answer anonymous requests as "guest".
    if (user['guest'] == true) throw YouTrackApiException(401);
    return (user['fullName'] ?? user['login'] ?? '') as String;
  }

  /// Unread notification threads, most recently notified first.
  Future<List<InboxThread>> unreadThreads({int top = 50}) async {
    final json = await _get('/api/inbox/threads', {
      'unreadOnly': 'true',
      'reverse': 'true',
      '\$top': '$top',
      'fields': _threadFields,
    });
    return [
      for (final item in json as List)
        ?InboxThread.fromJson(item as Map<String, dynamic>),
    ];
  }

  Future<Object?> _get(String path, Map<String, String> query) async {
    final uri = Uri.parse('$serverUrl$path').replace(queryParameters: query);
    final response = await _client
        .get(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw YouTrackApiException(response.statusCode);
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  void close() => _client.close();
}

class YouTrackApiException implements Exception {
  YouTrackApiException(this.statusCode);

  final int statusCode;

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;

  @override
  String toString() => 'YouTrackApiException(HTTP $statusCode)';
}

/// A notification thread: every notification about one issue or article.
class InboxThread {
  InboxThread({
    required this.id,
    required this.notified,
    required this.idReadable,
    required this.summary,
    required this.isArticle,
    required this.latest,
  });

  final String id;

  /// Time of the latest notification in the thread (ms since epoch).
  final int notified;
  final String idReadable;
  final String summary;
  final bool isArticle;

  /// Most recent unread message, if any.
  final InboxMessage? latest;

  /// Path of the issue or article in the YouTrack web app.
  String get webPath =>
      isArticle ? '/articles/$idReadable' : '/issue/$idReadable';

  static InboxThread? fromJson(Map<String, dynamic> json) {
    final subject = json['subject'] as Map<String, dynamic>?;
    var target = subject?['target'] as Map<String, dynamic>?;
    // Comment notifications target the comment; use its issue or article.
    target =
        (target?['issue'] ?? target?['article'] ?? target)
            as Map<String, dynamic>?;
    final idReadable = target?['idReadable'] as String?;
    if (target == null || idReadable == null) return null;

    final messages = [
      for (final m in (json['messages'] as List? ?? const []))
        InboxMessage.fromJson(m as Map<String, dynamic>),
    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return InboxThread(
      id: json['id'] as String,
      notified: (json['notified'] as num?)?.toInt() ?? 0,
      idReadable: idReadable,
      summary: (target['summary'] as String?) ?? '',
      isArticle: (target[r'$type'] as String?)?.contains('Article') ?? false,
      latest:
          messages.where((m) => !m.read).firstOrNull ?? messages.firstOrNull,
    );
  }
}

class InboxMessage {
  InboxMessage({
    required this.id,
    required this.timestamp,
    required this.read,
    this.author,
    this.commentText,
  });

  final String id;
  final int timestamp;
  final bool read;
  final String? author;
  final String? commentText;

  factory InboxMessage.fromJson(Map<String, dynamic> json) {
    String? author;
    String? comment;
    for (final a in (json['activities'] as List? ?? const [])) {
      final activity = a as Map<String, dynamic>;
      final user = activity['author'] as Map<String, dynamic>?;
      author ??= (user?['fullName'] ?? user?['login']) as String?;
      comment ??= _commentText(activity);
    }
    return InboxMessage(
      id: json['id'] as String? ?? '',
      timestamp: (json['timestamp'] as num?)?.toInt() ?? 0,
      read: json['read'] as bool? ?? false,
      author: author,
      commentText: comment,
    );
  }

  static String? _commentText(Map<String, dynamic> activity) {
    final comment = activity['comment'];
    if (comment is Map && comment['text'] is String) {
      return comment['text'] as String;
    }
    final added = activity['added'];
    if (added is List) {
      for (final item in added) {
        if (item is Map &&
            (item[r'$type'] as String?)?.contains('Comment') == true &&
            item['text'] is String) {
          return item['text'] as String;
        }
      }
    }
    return null;
  }
}
