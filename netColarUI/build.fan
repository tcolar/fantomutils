// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Nov 11, 2009  thibautc  Creation
//
using build

**
** Build: netColarUI
**
class Build : BuildPod
{
  new make()
  {
    podName = "netColarUI"
    summary = "netColarUI: Various Custom Fantom UI components"
    depends = ["sys 1.0", "fwt 1.0", "gfx 1.0"]
    srcDirs = [`fan/`, `test/`]
  }
}
