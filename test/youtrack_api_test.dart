import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:utrack_desktop/notifications/youtrack_api.dart';

void main() {
  const server = 'https://yt.example.com';

  YouTrackApi apiReturning(Object body, {int status = 200}) {
    return YouTrackApi(
      server,
      'perm:token',
      client: MockClient((request) async {
        expect(request.headers['Authorization'], 'Bearer perm:token');
        return http.Response.bytes(utf8.encode(jsonEncode(body)), status);
      }),
    );
  }

  test('parses a comment notification on an issue', () async {
    final api = apiReturning([
      {
        'id': 't1',
        'notified': 2000,
        'subject': {
          'target': {
            r'$type': 'IssueComment',
            'issue': {
              r'$type': 'Issue',
              'idReadable': 'UTD-42',
              'summary': 'Crash on start',
            },
          },
        },
        'messages': [
          {
            'timestamp': 1000,
            'read': true,
            'activities': [
              {
                'author': {'fullName': 'Old'},
              },
            ],
          },
          {
            'timestamp': 2000,
            'read': false,
            'activities': [
              {
                r'$type': 'CommentActivityItem',
                'author': {'fullName': 'Jane Doe', 'login': 'jane'},
                'added': [
                  {r'$type': 'IssueComment', 'text': 'Fixed in **main**'},
                ],
              },
            ],
          },
        ],
      },
    ]);

    final threads = await api.unreadThreads();
    expect(threads, hasLength(1));
    final thread = threads.single;
    expect(thread.idReadable, 'UTD-42');
    expect(thread.summary, 'Crash on start');
    expect(thread.notified, 2000);
    expect(thread.webPath, '/issue/UTD-42');
    expect(thread.latest?.author, 'Jane Doe');
    expect(thread.latest?.commentText, 'Fixed in **main**');
  });

  test('uses the article path for article notifications', () async {
    final api = apiReturning([
      {
        'id': 't2',
        'notified': 1,
        'subject': {
          'target': {
            r'$type': 'Article',
            'idReadable': 'KB-A-7',
            'summary': 'Onboarding',
          },
        },
        'messages': <Object>[],
      },
    ]);

    final thread = (await api.unreadThreads()).single;
    expect(thread.webPath, '/articles/KB-A-7');
    expect(thread.latest, isNull);
  });

  test('skips threads without a readable target', () async {
    final api = apiReturning([
      {'id': 't3', 'notified': 1, 'subject': null},
    ]);
    expect(await api.unreadThreads(), isEmpty);
  });

  test('reports rejected tokens as unauthorized', () async {
    final api = apiReturning({'error': 'Unauthorized'}, status: 401);
    await expectLater(
      api.currentUserName(),
      throwsA(
        isA<YouTrackApiException>().having(
          (e) => e.isUnauthorized,
          'isUnauthorized',
          true,
        ),
      ),
    );
  });
}
