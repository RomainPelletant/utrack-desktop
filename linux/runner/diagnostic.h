// SPDX-FileCopyrightText: 2026 Romain Pelletant
// SPDX-License-Identifier: Apache-2.0

#ifndef RUNNER_DIAGNOSTIC_H_
#define RUNNER_DIAGNOSTIC_H_

#include <glib.h>

// Diagnostic mode, started by `utd --diagnostic` or UTD_DIAGNOSTIC=1. From the
// very start, native steps, the Flutter engine and GTK output (stdout/stderr)
// and the Dart log (lib/app_log.dart, told the path through
// UTD_DIAGNOSTIC_LOG) go to $XDG_STATE_HOME/utd/utd-diagnostic.log, for users
// to attach to bug reports. It must never contain the token or page contents.
namespace diagnostic {

// Starts the diagnostic mode when requested; call first in main().
void Start(int argc, char** argv);

// Appends a line to the log; does nothing outside the diagnostic mode.
void Log(const char* format, ...) G_GNUC_PRINTF(1, 2);

// Logs the exit and opens the log folder.
void Finish(int exit_code);

}  // namespace diagnostic

#endif  // RUNNER_DIAGNOSTIC_H_
