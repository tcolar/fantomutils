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
    summary = "Generic common utils"
    depends = ["sys 1.0"]
    srcDirs = [`fan/`, `test/`]
  }
}
