// Artistic License 2.0
//
// History:
//   Feb 24, 2011 tcolar Creation
//

**
** MaildirScanner
** Utility to scan a Maildir box (and subbox) and getting infos about it
**
class MaildirBoxScanner
{
  ** folderSepIsDot: If true subfolders are in maildir++ format: 
  ** Ex: .archives.2004.sent
  ** otherwise use "real" folders:  
  ** Ex: archives/2004/Sent/
  Bool folderSepIsDot := true

  ** Scan a Maildir folder and return list of (sub)Boxes found 
  MaildirBox[] scan(Str[] path, File folder)
  {
    boxes := [,]
    if(folder.exists && folder.isDir)
    {
      curDir := folder + `cur/`
      tmpDir := folder + `tmp/`
      newDir := folder + `new/`
      inbox := MaildirBox
      {
        it.path = path
        it.dir = folder.uri
      }
      boxes.add(inbox)
      
      if( ! folderSepIsDot)
      {
        File(inbox.dir).listDirs.each |File sub| 
        {
          if( ! (sub.name == "cur" || sub.name == "tmp" || sub.name == "new"))
          {
            boxes.addAll(scan(path.dup.add(sub.name), sub))
          }
        }  
      }
      else
      {
        File(inbox.dir).listDirs.each |File sub| 
        {
          if(sub.name.startsWith("."))
          {
            parts := sub.name.split('.', true)
            boxes.addAll(scan(path.dup.addAll(parts[1..-1]), sub))
          }
        }
      }
          
      return boxes
    }
    throw Err("The folder does not appear to be a valid maildir directory : "+folder);
  }
}
