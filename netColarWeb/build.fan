// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 17, 2010  thibautc  Creation
//
using build

**
** Build: netColarWeb
**
class Build : BuildPod
{
  new make()
  {
    podName = "netColarWeb"
	summary = "netColarWeb"
    depends = ["sys 1.0"]
    srcDirs = [`fan/`, `test/`]
  }
}
