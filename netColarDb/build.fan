// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   May 24, 2010  thibautc  Creation
//
using build

**
** Build: netColarDb
**
class Build : BuildPod
{
  new make()
  {
    podName = "netColarDb"
	summary = "netColarDb"
    depends = ["sys 1.0", "sql 1.0"]
    srcDirs = [`fan/`, `test/`]
  }
}
