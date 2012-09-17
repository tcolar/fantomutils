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
    summary = "Mail client/server RFC implementation (Maildir, SMTP, IMAP)"
    depends = ["sys 1.0+", "concurrent 1.0+", "inet 1.0+", "util 1.0", "email 1.0", "netColarUtils 0.0.1+"]
    srcDirs =  [`test/`, `fan/`, `fan/maildir/`, `fan/imap/`, `fan/imap/client/`, `fan/message/`,
                `fan/smtp/`, `fan/smtp/consumers/`]
    version = Version("0.0.1")
    meta = ["license.name" : "MIT", "vcs.uri" : "https://bitbucket.org/tcolar/fantomutils/src/tip/mail/netColarEmail"]                                                                                                                                                                                
  }
}
