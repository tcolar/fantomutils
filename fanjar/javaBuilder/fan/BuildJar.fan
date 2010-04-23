// History:
//   Dec 15, 2009  thibautc  Creation
//
using build

**
** Build standalone Java jars (TODO: JNLP, wars).
** It basically build a jar with a minimal Fantom runtime and some pods
** The jar contains a Java launcher that does the following:
** - When the jar is run, it copies the Fantom runtime into a dir
** - Then the launcher starts a given Fantom program using that runtime.
**
abstract class BuildJar : BuildScript
{
  ** Required: Destination file
  File? destFile

  ** Required: Pod names to include, dependant pods will be resolved
  ** and added as well
  Str[]? pods

  ** Required: Main class/method
  ** Ex: 'mypod::Main.main'
  ** Ex: 'mypod::Main' same as 'mypod::Main.main'
  ** Ex: 'mypod' same as 'mypod::Main.main'
  Str? appMain

  ** By default the files in lib/java/ext/* are not includes (ex: swt) since they can be large
  ** If you want to add some, list them here
  ** Use the URI relative to fan home. Example: `lib/java/ext/linux-x86/swt.jar`
  Uri[]? extLibs

  ** Constructor
  new make() : super()
  {
    checkFields
  }

  **
  ** Validate subclass constructor setup required meta-data.
  ** Have to do my own since validateFields() in BuildScript is 'internal'
  **
  internal Void checkFields()
  {
    ok := true
    ok = ok && checkReqField("pods")
    ok = ok && checkReqField("destFile")
    ok = ok && checkReqField("appMain")
    if (!ok)
    throw FatalBuildErr.make
  }

  internal Bool checkReqField(Str field)
  {
    val := type.field(field).get(this)
    if (val != null) return true
    log.error("Required field not set: '$field' [$toStr]")
    return false
  }

  ** Default target is 'Jar'
  override Target defaultTarget() { return target("jar") }

  ** Build a standalone Jar (sontaining a minima Fantom runtime)
  Void jar()
  {
    File temp     := scriptDir + `temp/`
    File tempFantom     := temp + `fantom/`
    File tempLib    := tempFantom + `lib/`
    File tempFan    := tempLib + `fan/`
    File tempJava    := tempLib + `java/`
    File tempExt    := tempJava + `ext/`
    File tempLauncher    := temp + `fanjarlauncher/`
    File tempEtcSys    := tempFantom + `etc/sys/`
    jdk      := JdkTask(this)
    jarExe   := jdk.jarExe
    manifest := temp + `Manifest.mf`

    // make temp dirs
    temp.delete
    CreateDir(this, temp).run
    CreateDir(this, tempLib).run
    CreateDir(this, tempFan).run
    CreateDir(this, tempExt).run
    CreateDir(this, tempEtcSys).run
    
    // Add fan runtime
    log.info("Adding Fantom binaries: $binDir")
    binDir.copyInto(tempFantom)
    // etc/sys files needed for runtime
    File tz := devHomeDir + `etc/sys/timezones.ftz`
    tz.copyInto(tempEtcSys)
    // java libs
    log.info("Adding Fantom Java libraries $libJavaDir")
    libJavaDir.listFiles.each |File f| {f.copyInto(tempJava)}
    // add other libs requested by the user
    extLibs?.each |Uri uri|
    {
      File src := devHomeDir + uri
      File dest := tempFantom + uri
      if(src.exists)
        {
        log.info("Adding External Lib: $src")
        src.copyTo(dest)
      }
      else
        {
        throw Err("Ext file not found! : $src")
      }
    }
    // Add pods and their dependencies (recursively))
    buildPodList.each |Str podName|
    {
      log.info("Adding Fantom Pod: $podName")
      podFile := libFanDir + `${podName}.pod`
      podFile.copyInto(tempFan)
    }
    // Copy custom Java Launcher code
    File javaLauncherDir := scriptDir+`java/fanjarlauncher/`
    javaLauncherDir.listFiles().each() |File f|
    {
      if(f.ext().equals("class")){f.copyInto(tempLauncher)}
    }

    // write manifest
    log.info("Write Manifest [${manifest.osPath}]")
    out := manifest.out
    out.printLine("Manifest-Version: 1.0")

    // Custom entry for the app "Main""
    out.printLine("Fantom-Main: $appMain")
    out.printLine("Main-Class: fanjarlauncher.Launcher")
    out.close

    // ensure jar target directory exists
    CreateDir(this, destFile.parent).run

    // jar up temp directory
    log.info("Jar [${destFile.osPath}]")
    Exec(this, [jarExe.osPath, "cfm", destFile.osPath, manifest.osPath, "-C", temp.osPath, "."], temp).run
  }
  
  // TODO: target for JNLP
  // TODO: war target (any use without a servlet API ?))

  ** Build the list of pods required for this jar
  ** It starts with the pods listed in the "pods" array and adds all dependencies as well.
  internal Str[] buildPodList()
  {
    // always want the sys pod
    Str[] resPods := ["sys"]
    // Then add user specified pods and their dependencies
    pods.each |Str podName|
    {
      pod := Pod.find(podName)
      if(pod == null)
        {
        throw Err("Pod not found $podName")
      }
      else
        {
        // no duplicates
        if( ! resPods.contains(podName))
          {
          resPods.add(podName)
          resolveDeps(resPods, pod)
        }
      }
    }
    return resPods
  }

  ** Finds a pod Dependencies (other pods) and add them to results
  ** - Recursive
  internal Void resolveDeps(Str[] results, Pod pod)
  {
    pod.depends.each |Depend dep|
    {
      depPod := Pod.find(dep.name)
      if(depPod == null)
        {
        throw Err("Pod not found $pod.name")
      }
      else if( ! dep.match(depPod.version))
        {
        throw Err("Pod version mismatch for $pod.name . Required: $dep.version , Found: $depPod.version")
      }
      else
        {
        // No duplicates
        if( ! results.contains(dep.name))
          {
          results.add(dep.name)
          // recurse into pod dependencies
          resolveDeps(results, depPod)
        }
      }
    }
  }
}


