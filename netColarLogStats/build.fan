// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Jun 8, 2010  thibautc  Creation
//
using build

**
** Build: netColarLogStats
**
class Build : BuildPod
{
  new make()
  {
    podName = "netColarLogStats"
	summary = "netColarLogStats"
    depends = ["sys 1.0", "netColarDb 1.0", "sql 1.0"]
    srcDirs = [`fan/`, `test/`]
  }
}
