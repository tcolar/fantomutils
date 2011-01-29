// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   28-Jan-2011  thibautc  Creation
//
using build

**
** Build: netColarImapServer
**
class Build : BuildPod
{
  new make()
  {
    podName = "netColarImapServer"
    summary = "IMAP server impl."
    depends = ["sys 1.0"]
    srcDirs = [`fan/`, `test/`]
  }
}
