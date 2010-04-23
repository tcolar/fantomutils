// History:
//   Dec 15, 2009  thibautc  Creation
//
using javaBuilder
**
** buildHelloApp
**
class BuildHelloApp : BuildJar
{
  override Void setup()
  {
    podName  := "helloWorld"
    destFile = scriptDir+`${podName}.jar`
    pods = [podName]
	
	// Console version ~ 1MB jar
	appMain = podName

	// FWT version ~ 3MB jar (1 platform swt.jar)
	//appMain = "${podName}::Main.mainFwt"
	//extLibs = [`lib/java/ext/linux-x86_64/swt.jar`]
  }
}


