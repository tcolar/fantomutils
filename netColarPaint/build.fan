// Artistic License 2.0
//
// History:
//   Oct 1, 2010  thibautc  Creation
//
using build

**
** Build: netColarPaint
**
class Build : BuildPod
{
  new make()
  {
    podName = "netColarPaint"
	summary = "netColarPaint"
    depends = ["sys 1.0", "util 1.0", "web 1.0", "webmod 1.0", "wisp 1.0", "compiler 1.0", "compilerJs 1.0"]
    srcDirs = [`fan/`, `test/`]
  }
}
