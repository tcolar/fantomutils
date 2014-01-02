// Copyright : Teachscape
//
// History:
//   Apr 29, 2011  thibaut  Creation
//
using build

**
** Build: netColarUtils
**
class Build : BuildPod
{
  new make()
  {
    podName = "netColarUtils"
    summary = "Various reusable famtom utils"
    depends = ["sys 1.0+", "util 1.0+", "inet 1.0+"]
    version = Version("1.0.9")
    srcDirs = [`fan/`, `test/`]
    meta = ["license.name" : "MIT", "vcs.uri" : "https://bitbucket.org/tcolar/fantomutils/src/tip/netColarUtils"]
  }
}