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
    depends = ["sys 1.0", "netColarDb 1.0", "sql 1.0", "fwt 1.0", "gfx 1.0",
				"util 1.0", "web 1.0", "webmod 1.0", "wisp 1.0", "dom 1.0"]
    srcDirs = [`fan/`, `test/`]
  }
}
