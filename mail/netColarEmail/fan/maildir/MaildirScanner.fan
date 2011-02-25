// Artistic License 2.0
//
// History:
//   Feb 24, 2011 tcolar Creation
//

**
** MaildirScanner
**
class MaildirScanner
{

  const Uri testFolder := `/home/thibautc/backup/colar.net/home/tcolar/.maildir/`
  ** folderSepIsDot: If true subfolders are in maildir++ format: 
  ** Ex: .archives.2004.sent
  ** otherwise use "real" folders:  
  ** Ex: archives/2004/Sent/
  const Bool folderSepIsDot := true

  ** Scan a Maildir folder and return Inbox object with message count 
  Inbox scan(Str nm, File folder)
  {
    if(folder.exists && folder.isDir)
    {
      curDir := folder + `cur/`
      tmpDir := folder + `tmp/`
      newDir := folder + `new/`
      inbox := Inbox
      {
        name = nm
        dir = folder
        curCount = getMsgCount(curDir)
        tmpCount = getMsgCount(tmpDir)
        newCount = getMsgCount(newDir)
      }
      
      folderSepIsDot ? 
        scanFolderSubBoxes(inbox) 
        : scanDottedSubBoxes(inbox)
          
      return inbox
    }
    throw Err("The folder does not appear to be a valid maildir directory.");
  }

  ** SubBoxes mapped to plain folders
  Void scanFolderSubBoxes(Inbox inbox)
  {
    File(inbox.dir).listDirs.each |File sub| 
    {
      if( ! (sub.name == "cur" || sub.name == "tmp" || sub.name == "new"))
      {
        inbox.subBoxes.add(scan(sub.name, sub))
      }
    }
  }

  ** SubBoxes mapped in dotted format (maildir++)
  Void scanDottedSubBoxes(Inbox inbox)
  {
    //TODO: is listDir sorted alphabetically ?
    File(inbox.dir).listDirs.each |File sub| 
    {
      if(sub.name.startsWith("."))
      {
        parts := sub.name.split("/")
      }
    }
  }
      
  ** Count number of maildir messages in a folder
  Int getMsgCount(File dir) 
  { 
    return dir.listFiles.reduce(0) |obj, file, val -> Obj?| 
    {
      return val++
      }
  }

  Void main()
  {
    dir := File(testFolder);
    inbox := scan("Inbox", dir)
  }
}

class Inbox
{
  const Str name := "Inbox"
  const Uri dir := ``
  const Int curCount := 0
  const Int newCount := 0
  const Int tmpCount := 0
  Inbox[] subBoxes := [,]
}
