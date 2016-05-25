#include "backup.h"
#include "config.h"

int main(int argc, char *argv[])
{
  Backup *backup = new Backup();
  Config *config = new Config(SYSCONFDIR"/pkgbackup.conf");
}
