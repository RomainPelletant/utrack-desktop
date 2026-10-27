// SPDX-FileCopyrightText: 2026 Romain Pelletant
// SPDX-License-Identifier: Apache-2.0

import 'dart:io';

import 'package:flutter/foundation.dart';

/// Diagnostic log for Windows, where the app has no console:
/// `%LOCALAPPDATA%\UTD\utd.log`. Users can attach it to bug reports, so it
/// must never contain the token or page contents.
///
/// In diagnostic mode (`--diagnostic` or `UTD_DIAGNOSTIC=1`, on every
/// platform), the native runner creates `utd-diagnostic.log`, logs its own
/// steps there and passes its path in `UTD_DIAGNOSTIC_LOG`: the log goes to
/// that file instead, with the [trace] steps.
class AppLog {
  static const _maxBytes = 512 * 1024;

  static final String? _diagnosticPath =
      Platform.environment['UTD_DIAGNOSTIC_LOG'];

  /// Whether the app runs in diagnostic mode.
  static bool get diagnostic => _diagnosticPath != null;

  /// The log file, or null where nothing is written to disk.
  static final String? path =
      _diagnosticPath ??
      () {
        final localAppData = Platform.environment['LOCALAPPDATA'];
        if (!Platform.isWindows || localAppData == null) return null;
        return '$localAppData\\UTD\\utd.log';
      }();

  static void write(String message) {
    // In diagnostic mode, stdout already goes to the log file (macOS, Linux).
    if (!diagnostic) debugPrint(message);
    final path = AppLog.path;
    if (path == null) return;
    try {
      final file = File(path);
      if (!diagnostic && file.existsSync() && file.lengthSync() > _maxBytes) {
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

  /// Writes a step (startup, lifecycle…) in diagnostic mode only.
  static void trace(String message) {
    if (diagnostic) write(message);
  }
}
