// SPDX-FileCopyrightText: 2026 Romain Pelletant
// SPDX-License-Identifier: Apache-2.0

#include "diagnostic.h"

#include <gio/gio.h>
#include <gtk/gtk.h>
#include <signal.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <sys/utsname.h>
#include <unistd.h>

#include <initializer_list>

namespace diagnostic {
namespace {

bool enabled = false;
gchar* log_path = nullptr;

bool Requested(int argc, char** argv) {
  for (int i = 1; i < argc; i++) {
    if (g_strcmp0(argv[i], "--diagnostic") == 0) {
      return true;
    }
  }
  const gchar* value = g_getenv("UTD_DIAGNOSTIC");
  return value != nullptr && *value != '\0' && g_strcmp0(value, "0") != 0;
}

// Native crashes never reach the Dart log. Only async-signal-safe calls here.
void OnFatalSignal(int signal_number) {
  const char* message = signal_number == SIGSEGV ? "[native] Crash: SIGSEGV\n"
                        : signal_number == SIGBUS ? "[native] Crash: SIGBUS\n"
                        : signal_number == SIGILL ? "[native] Crash: SIGILL\n"
                        : signal_number == SIGFPE ? "[native] Crash: SIGFPE\n"
                                                  : "[native] Crash: SIGABRT\n";
  ssize_t unused = write(STDERR_FILENO, message, strlen(message));
  (void)unused;
  signal(signal_number, SIG_DFL);
  raise(signal_number);
}

void LogSystem() {
  g_autofree gchar* exe = g_file_read_link("/proc/self/exe", nullptr);
  Log("Executable: %s", exe != nullptr ? exe : "?");
  struct utsname system;
  if (uname(&system) == 0) {
    Log("Kernel: %s %s %s", system.sysname, system.release, system.machine);
  }
  g_autofree gchar* os = g_get_os_info(G_OS_INFO_KEY_PRETTY_NAME);
  Log("System: %s", os != nullptr ? os : "?");
  Log("GTK %u.%u.%u", gtk_get_major_version(), gtk_get_minor_version(),
      gtk_get_micro_version());
  const gchar* flatpak = g_getenv("FLATPAK_ID");
  Log("Flatpak: %s", flatpak != nullptr ? flatpak : "no");
  for (const gchar* name :
       {"XDG_SESSION_TYPE", "XDG_CURRENT_DESKTOP", "WAYLAND_DISPLAY",
        "DISPLAY", "GDK_BACKEND", "LIBGL_ALWAYS_SOFTWARE"}) {
    const gchar* value = g_getenv(name);
    Log("%s=%s", name, value != nullptr ? value : "");
  }
}

}  // namespace

void Start(int argc, char** argv) {
  if (!Requested(argc, argv)) {
    return;
  }
  g_autofree gchar* dir =
      g_build_filename(g_get_user_state_dir(), "utd", nullptr);
  g_mkdir_with_parents(dir, 0700);
  log_path = g_build_filename(dir, "utd-diagnostic.log", nullptr);
  // Where to find it, before stderr goes to the file.
  fprintf(stderr, "UTD diagnostic log: %s\n", log_path);

  // A new log at each launch. Both streams then append, so that they do not
  // overwrite each other (nor the Dart log, written to the same file).
  FILE* file = fopen(log_path, "w");
  if (file == nullptr) {
    return;
  }
  fclose(file);
  if (freopen(log_path, "a", stdout) == nullptr ||
      freopen(log_path, "a", stderr) == nullptr) {
    return;
  }
  setvbuf(stdout, nullptr, _IONBF, 0);
  setvbuf(stderr, nullptr, _IONBF, 0);
  enabled = true;

  // Read by lib/app_log.dart.
  g_setenv("UTD_DIAGNOSTIC_LOG", log_path, TRUE);
  for (int signal_number : {SIGSEGV, SIGBUS, SIGILL, SIGFPE, SIGABRT}) {
    signal(signal_number, OnFatalSignal);
  }

  Log("UTD diagnostic mode");
  LogSystem();
}

void Log(const char* format, ...) {
  if (!enabled) {
    return;
  }
  va_list args;
  va_start(args, format);
  g_autofree gchar* message = g_strdup_vprintf(format, args);
  va_end(args);
  g_autoptr(GDateTime) now = g_date_time_new_now_local();
  g_autofree gchar* time = g_date_time_format(now, "%Y-%m-%dT%H:%M:%S");
  fprintf(stderr, "%s.%03d [native] %s\n", time,
          g_date_time_get_microsecond(now) / 1000, message);
}

void Finish(int exit_code) {
  if (!enabled) {
    return;
  }
  Log("Exit (code %d)", exit_code);
  // Shows users which file to attach to their bug report.
  g_autofree gchar* dir = g_path_get_dirname(log_path);
  g_autofree gchar* uri = g_filename_to_uri(dir, nullptr, nullptr);
  if (uri != nullptr) {
    g_app_info_launch_default_for_uri(uri, nullptr, nullptr);
  }
}

}  // namespace diagnostic
