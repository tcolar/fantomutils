// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Sep 2, 2011  thibaut  Creation
//
using build

**
** Build: netColarOrientDb
**
class Build : BuildPod
{
  new make()
  {
    podName = "netColarOrientDb"
	summary = "netColarOrientDb"
    depends = ["sys 1.0", "web 1.0", "util 1.0"]
    srcDirs = [`fan/`, `fan/rest/`, `fan/ffi/`, `test/`]
  }
}
