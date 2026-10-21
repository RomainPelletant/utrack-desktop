// SPDX-FileCopyrightText: 2026 Romain Pelletant
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

import 'package:flutter/foundation.dart';

/// Diagnostic log for Windows, where the app has no console:
/// `%LOCALAPPDATA%\UTD\utd.log`. Users can attach it to bug reports, so it
/// must never contain the token or page contents.
class AppLog {
  static const _maxBytes = 512 * 1024;

  /// The log file, or null where nothing is written to disk.
  static final String? path = () {
    final localAppData = Platform.environment['LOCALAPPDATA'];
    if (!Platform.isWindows || localAppData == null) return null;
    return '$localAppData\\UTD\\utd.log';
  }();

  static void write(String message) {
    debugPrint(message);
    final path = AppLog.path;
    if (path == null) return;
    try {
      final file = File(path);
      if (file.existsSync() && file.lengthSync() > _maxBytes) {
        file.deleteSync(); // Starts over rather than growing forever.
      }
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(
        '${DateTime.now().toIso8601String()} $message\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (_) {
      // Logging must never break the app.
    }
  }
}
