// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   Dec 15, 2009  thibautc  Creation
//
using build

**
** Build: helloWorld
**
class Build : BuildPod
{
  new make()
  {
    podName = "helloworld"
    summary = ""
    depends = ["sys 1.0+", "concurrent 1.0+"]
    srcDirs = [`fan/`]
  }
}