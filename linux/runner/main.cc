#include "diagnostic.h"
#include "my_application.h"

int main(int argc, char** argv) {
  // `utd --diagnostic`: logs every step to utd-diagnostic.log.
  diagnostic::Start(argc, argv);
  g_autoptr(MyApplication) app = my_application_new();
  int exit_code = g_application_run(G_APPLICATION(app), argc, argv);
  diagnostic::Finish(exit_code);
  return exit_code;
}
