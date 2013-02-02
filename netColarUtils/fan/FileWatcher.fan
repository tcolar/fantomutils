// History:
//  Jan 24 13 tcolar Creation
//

**
** FileWatcher
** Use to more efficiently watch files(currently rather directories) for changes
** It's basically on demand scanning with caching at this point (no threaded polling)
**
** TODO: Maybe look into java 7 file watch API's that use native file watches
**
class FileWatcher
{
  static const Log log := FileWatcher#.pod.log

  ** Cache of File -> file last modif timestamp
  Uri:Int cache := [:]

  ** Whether to follow file links beaking outside of their base directory
  const Bool followBreakoutLinks

  ** Create the file watcher
  ** followBreakoutLinks : Whether to follow file links beaking outside of their base directory
  new make(Bool followBreakoutLinks := true)
  {
    this.followBreakoutLinks = followBreakoutLinks
  }

  ** Find directories that have changed since last run
  ** Note: The first time it is run it will return all dirs as changed
  ** It's a good idea to provide a maxDepth whenever possible, this can greatly improve performance
  Uri[] changedDirs(File dir, Int maxDepth := -1)
  {
    changed := Uri[,]
    // passing result list(changed) as a parameter rather than a result has it's more effcient in the recursion
    walkDir(changed, dir, maxDepth)
    return changed
  }

  ** private implemntation. Find changed directories recursively
  private Void walkDir(Uri[] changed, File dir, Int maxDepth:=-1,
                        Int curDepth := 0, Uri[] checked :=[,])
  {
    if(maxDepth > 0 && curDepth > maxDepth) return
    uri := dir.normalize.uri

    // cyclic link check
    if(checked.contains(uri))
      return

    checked.add(uri)
    ticks := dir.modified.ticks
    if(cache[uri] != ticks) // new or modified
    {
      changed.add(uri)
      cache[uri] = ticks
    }
    // recurse into subdirs
    dir.listDirs.each
    {
      if( ! it.normalize.uri.toStr.startsWith(uri.toStr))
      {
        if(followBreakoutLinks)
        {
          log.warn("Warning : Following a link breaking out of $uri into $ it !")
          walkDir(changed, it, maxDepth, curDepth + 1, checked)
        }
      }
      else
        walkDir(changed, it, maxDepth, curDepth + 1, checked)
    }
  }
}