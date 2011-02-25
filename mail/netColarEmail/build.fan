// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   28-Jan-2011  thibautc  Creation
//
using build

**
** Build: netColarEmail
**
class Build : BuildPod
{
  new make()
  {
    podName = "netColarEmail"
    summary = "Mail server"
    depends = ["sys 1.0", /*"netColarSmtpServer 1.0", "netColarImapServer 1.0"*/]
    srcDirs = [`fan/`, `fan/maildir/`, `test/`]
  }
}
