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
    depends = ["sys 1.0"]
    srcDirs = [`fan/`, `test/`]
  }
}
