// SPDX-FileCopyrightText: 2026 Romain Pelletant
// SPDX-License-Identifier: Apache-2.0

#ifndef RUNNER_DIAGNOSTIC_H_
#define RUNNER_DIAGNOSTIC_H_

// Diagnostic mode, started by `UTD.exe --diagnostic` (the "UTD (diagnostic)"
// Start menu shortcut) or UTD_DIAGNOSTIC=1. From the very start, native steps,
// the Flutter engine output (stdout/stderr) and the Dart log (lib/app_log.dart,
// told the path through UTD_DIAGNOSTIC_LOG) go to
// %LOCALAPPDATA%\UTD\utd-diagnostic.log, for users to attach to bug reports.
// It must never contain the token or page contents.
namespace diagnostic {

// Starts the diagnostic mode when requested; call before creating the engine.
void Start();

// Appends a line to the log; does nothing outside the diagnostic mode.
void Log(const char* format, ...);

// The first Flutter frame was shown; logged if it does not come in time.
void MarkFirstFrame();

// Logs the exit and shows the log in File Explorer.
void Finish(int exit_code);

}  // namespace diagnostic

#endif  // RUNNER_DIAGNOSTIC_H_
